import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomBannerButton extends StatelessWidget {
  final String text;
  final double textSize; // Customizable text size
  final String? iconImage; // Optional icon
  final Color bgColor;
  final String? bgImage; // Optional background image
  final double? height; // Optional height, default is 70
  final Widget? child; // Optional child widget
  final VoidCallback? onPressed; // Optional onPressed callback

  const CustomBannerButton({
    super.key,
    required this.text,
    this.textSize = 22, // Default text size
    this.iconImage, // Optional
    required this.bgColor,
    this.bgImage, // Optional
    this.height, // Optional height, default to 70 if not provided
    this.child, // Optional child widget
    this.onPressed, // Optional onPressed callback
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // Trigger onPressed if provided
      child: Container(
        height: height ?? 70, // Use the provided height or default to 70
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          image:
              bgImage != null
                  ? DecorationImage(
                    image: ExactAssetImage(bgImage!),
                    fit: BoxFit.cover,
                  )
                  : null,
        ),
        child:
            child ?? // If child is provided, use it, otherwise use the default layout
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconImage != null) // Show icon only if provided
                  Row(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Image.asset(iconImage!),
                      ),
                      SizedBox(width: 4), // Space between icon and text
                    ],
                  ),
                customText(
                  text.toUpperCase(),
                  textSize, // Dynamic text size
                  context,
                  fontWeight: FontWeight.w800,
                ),
              ],
            ),
      ),
    );
  }
}

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

void showUrlBottomSheet({
  required BuildContext context,
  required Function(String) onUpdate,
}) {
  TextEditingController urlController = TextEditingController();

  // Fetch stored URL before showing the bottom sheet
  getSavedUrl().then((storedUrl) {
    if (storedUrl != null) {
      urlController.text = storedUrl;
    }
  });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: "URL",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String url = urlController.text.trim();
                await saveUrlSecurely(url);
                onUpdate(url);
                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        ),
      );
    },
  );
}

// Save URL securely in Flutter Secure Storage
Future<void> saveUrlSecurely(String url) async {
  await secureStorage.write(key: "secure_url", value: url);
}

// Retrieve saved URL
Future<String?> getSavedUrl() async {
  return await secureStorage.read(key: "secure_url");
}
