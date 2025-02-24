import 'package:calculator/Classes/Logic/logic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// webview
import 'package:webview_flutter/webview_flutter.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // menu
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final CalculatorLogic calculatorLogic = CalculatorLogic();
  String result = '0';
  bool isSecondFunctionActive = false; // ✅ Toggle for `2nd` button

  // is incognito?
  bool isInCognito = false;

  // web view controller
  late final WebViewController _controller;

  // banner
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final List<String> primaryButtons = [
    'C',
    //'2nd',
    'MC',
    'M+',
    'M-',
    'MR',
    'π',
    'sin',
    'cos',
    'tan',
    'sinh',
    'cosh',
    'tanh',
    'e',
    '√',
    '(',
    ')',
    '%',
    '÷',
    'ln',
    'log₁₀',
    '7',
    '8',
    '9',
    '×',
    'x⁻¹',
    '∛',
    '4',
    '5',
    '6',
    '−',
    'x²',
    'xⁿ',
    '1',
    '2',
    '3',
    '+',
    'x!',
    'x³',
    '0',
    '.',
    '⌫',
    '=',
  ];

  final List<String> secondButtons = [
    'C',
    //'2nd',
    'MC',
    'M+',
    'M-',
    'MR',
    'π',
    'sin⁻¹',
    'cos⁻¹',
    'tan⁻¹',
    'sinh',
    'cosh',
    'tanh',

    'e',
    '√',
    '(',
    ')',
    'eⁿ',
    '÷',
    'log₁₀',
    '7',
    '8',
    '9',
    '×',
    'x⁻¹',
    '∛',
    '4',
    '5',
    '6',
    '−',
    '√',
    'xⁿ',
    '1',
    '2',
    '3',
    '+',
    'x!',
    '∛',
    '0',
    '.',
    '⌫',
    '=',
  ];

  void onButtonPressed(String label) {
    setState(() {
      if (label == '2nd') {
        isSecondFunctionActive = !isSecondFunctionActive; // ✅ Toggle 2nd mode
        return;
      }

      // ✅ Fixed `()` Handling (Keeps Brackets When Adding Numbers Inside)
      if (label == '()') {
        int openBrackets = result.split('(').length - 1;
        int closeBrackets = result.split(')').length - 1;

        if (openBrackets > closeBrackets) {
          result += ")"; // Close bracket only if an open bracket exists
        } else {
          if (result == "0" || result.isEmpty) {
            result = "("; // Start fresh with an open bracket
          } else if (RegExp(r'[0-9)]$').hasMatch(result)) {
            result += "×("; // Add multiplication before `(` if necessary
          } else {
            result += "("; // Otherwise, just add `(`
          }
        }
        return;
      }

      // ✅ Ensure Bracket Stays When Entering a Number Inside `()`
      if (RegExp(r'^\d$').hasMatch(label)) {
        // If number is entered
        if (result.endsWith("(")) {
          result += label; // Keep the opening bracket and add number
        } else {
          result = calculatorLogic.processInput(label, result);
        }
        return;
      }

      result = calculatorLogic.processInput(label, result);
    });
  }

  @override
  void initState() {
    super.initState();

    // init banner
    _loadAd();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse('https://google.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title:
            isInCognito
                ? Text("Browser", style: TextStyle(color: Colors.white))
                : Text("Calculator", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _UIKit(context),
    );
  }

  // Widget: Incognito mode
  Widget wIncognitoMode(BuildContext context) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.blue,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _UIKit(BuildContext context) {
    return Column(
      children: [
        if (isInCognito) ...[
          wIncognitoMode(context),
        ] else ...[
          // ✅ Restored Calculator & Incognito Buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(color: Colors.black),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isInCognito = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isInCognito ? Colors.grey[800] : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          "Calculator",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isInCognito = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isInCognito ? Colors.blue : Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_off,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Incognito",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(20),
              child: Text(
                result,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: primaryButtons.length,
              itemBuilder: (context, index) {
                String label =
                    isSecondFunctionActive
                        ? secondButtons[index]
                        : primaryButtons[index];
                return CalculatorButton(label, onButtonPressed);
              },
            ),
          ),
          _isAdLoaded == false
              ? const SizedBox()
              : Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                color: Colors.blue,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              ),
        ],
      ],
    );
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('Ad Loaded');
          }
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd!.load();
  }
}

class CalculatorButton extends StatelessWidget {
  final String label;
  final Function(String) onPressed;
  const CalculatorButton(this.label, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(label),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              label == 'C'
                  ? Colors
                      .redAccent // ✅ `C` button is now red accent
                  : label == '='
                  ? Colors
                      .orange // ✅ `=` button is now orange
                  : Colors.grey[900], // Default color for other buttons
          borderRadius: BorderRadius.circular(0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
