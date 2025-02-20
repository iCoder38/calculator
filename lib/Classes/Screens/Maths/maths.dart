// import 'dart:convert';
import 'dart:io';
import 'package:calculator/Classes/Utils/drawer.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:path_provider/path_provider.dart';

class MathsScreen extends StatefulWidget {
  const MathsScreen({super.key});

  @override
  State<MathsScreen> createState() => _MathsScreenState();
}

class _MathsScreenState extends State<MathsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  File? _image;
  bool _isUploading = false;
  String? mainEquation; // Store the main equation to display

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Scan Math Problem"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
      ),
      drawer: CustomDrawer(),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[900],
            ),
            child: Center(
              child:
                  _image == null
                      ? const Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.white30,
                      )
                      : Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.file(
                            _image!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          if (_isUploading)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: _buildButton(
                "Gallery",
                Icons.image,
                () => _pickImage(ImageSource.gallery),
              ),
            ),
            Expanded(
              child: _buildButton(
                "Camera",
                Icons.camera,
                () => _pickImage(ImageSource.camera),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  /// **Picks an image and uploads it**
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isUploading = true;
      });

      await _uploadImage(_image!);

      setState(() {
        _isUploading = false;
      });
    } else {
      debugPrint('No image selected.');
    }
  }

  /// **Upload Image to API**
  Future<void> _uploadImage(File imageFile) async {
    final dio = Dio();
    const String url =
        'https://photomath1.p.rapidapi.com/maths/v2/solve-problem';
    final headers = {
      'x-rapidapi-host': 'photomath1.p.rapidapi.com',
      'x-rapidapi-key': MathRapidApi().key,
    };

    try {
      File compressedFile = await _compressImage(imageFile);
      FormData formData = FormData.fromMap({
        'locale': 'en',
        'image': await MultipartFile.fromFile(
          compressedFile.path,
          filename: 'math_problem.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      Response response = await dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data; // ✅ No need to decode

        List<String> steps = [];
        if (data.containsKey("preview") &&
            data["preview"].containsKey("groups") &&
            data["preview"]["groups"].isNotEmpty) {
          var node =
              data["preview"]["groups"][0]["entries"][0]["command"]["node"];
          mainEquation = _getEquationString(node);
          _extractStepsRecursively(node, steps);
        }

        String solution = data["preview"]["solution"]["value"];
        _showStepsBottomSheet(
          context,
          mainEquation ?? "Unknown Equation",
          steps,
          solution,
        );
      }
    } catch (e) {
      debugPrint("❌ Upload failed: $e");
    }
  }

  /// **Extract Steps Dynamically**
  void _extractStepsRecursively(Map<String, dynamic> node, List<String> steps) {
    if (!node.containsKey("type")) return;

    String type = node["type"];
    String operationSymbol = "";

    if (type == "add") {
      operationSymbol = " + ";
    } else if (type == "sub") {
      operationSymbol = " - ";
    } else if (type == "mul") {
      operationSymbol = " × ";
    } else if (type == "div") {
      operationSymbol = " ÷ ";
    } else if (type == "frac") {
      operationSymbol = " / ";
    }

    if (node.containsKey("children")) {
      List<dynamic> children = node["children"];
      List<String> childValues = [];

      for (var child in children) {
        if (child["type"] == "const") {
          childValues.add(child["value"]);
        } else {
          _extractStepsRecursively(child, steps);
        }
      }

      if (childValues.isNotEmpty) {
        steps.add(childValues.join(operationSymbol));
      }
    }
  }

  /// **Get Full Equation as String**
  String _getEquationString(Map<String, dynamic> node) {
    if (node["type"] == "const") {
      return node["value"];
    }
    if (node.containsKey("children")) {
      List<String> parts =
          node["children"]
              .map<String>((child) => _getEquationString(child))
              .toList();
      String symbol =
          node["type"] == "add"
              ? " + "
              : node["type"] == "sub"
              ? " - "
              : node["type"] == "mul"
              ? " × "
              : node["type"] == "div"
              ? " ÷ "
              : " ";
      return parts.join(symbol);
    }
    return "";
  }

  void _showStepsBottomSheet(
    BuildContext context,
    String equation,
    List<String> steps,
    String solution,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Display the Main Equation
              Text(
                "Equation: $equation",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Divider(),

              // ✅ Steps Section
              const Text(
                "Solving Steps",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // ✅ Correctly format and display steps
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildStepWidgets(steps),
              ),

              const SizedBox(height: 12),

              // ✅ Display Final Step Before Solution (Properly Formatted)
              if (steps.isNotEmpty)
                /*Text(
                  "Final Step: ${steps.join(" ")}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),*/
                const SizedBox(height: 12),

              // ✅ Final Solution
              Text(
                "Solution: $solution",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 12),

              // ✅ Close Button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ✅ **Function to Format Steps with Step Numbers and "=" Result**
  List<Widget> _buildStepWidgets(List<String> steps) {
    List<Widget> stepWidgets = [];

    for (int i = 0; i < steps.length; i++) {
      String step = steps[i]; // ✅ Keep original step
      String result = _evaluateStep(step); // ✅ Calculate correct result

      stepWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Step ${i + 1}: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text("$step = $result"),
              ), // ✅ Show correct step result
            ],
          ),
        ),
      );
    }

    return stepWidgets;
  }

  /// ✅ **Function to Evaluate Each Step's Result Using a Math Parser**
  String _evaluateStep(String expression) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(
        expression.replaceAll('×', '*').replaceAll('÷', '/'),
      ); // ✅ Convert to correct math symbols
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      return result.toString();
    } catch (e) {
      return "?";
    }
  }
}

/// **Compress Image (Ensure it's under 500KB)**
Future<File> _compressImage(File file) async {
  final img.Image? image = img.decodeImage(file.readAsBytesSync());

  if (image == null) throw Exception("Invalid image format");

  // Resize the image to reduce file size
  final img.Image resizedImage = img.copyResize(image, width: 800);

  // Get a temporary directory
  final Directory tempDir = await getTemporaryDirectory();
  final File compressedFile = File('${tempDir.path}/compressed.jpg')
    ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 85));

  // Ensure it's under 500KB
  if (compressedFile.lengthSync() > 500 * 1024) {
    throw Exception("Image exceeds 500KB after compression.");
  }
  return compressedFile;
}
