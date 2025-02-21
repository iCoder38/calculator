import 'package:calculator/Classes/Logic/logic.dart';
import 'package:calculator/Classes/Utils/resources.dart';
import 'package:calculator/Classes/Utils/utils.dart';
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

  // is incoginito ?
  bool isInCognito = false;

  // web view controller
  late final WebViewController _controller;

  // banner
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final List<String> buttons = [
    'C',
    '2nd',
    'MC',
    'M+',
    'M-',
    'MR',
    'sin',
    'cos',
    'tan',
    'sinh',
    'cosh',
    'tanh',
    'π',
    'e',
    '√',
    '()',
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

  void onButtonPressed(String label) {
    setState(() {
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
            isInCognito == true
                ? customText(AppText().kTextIncognito, 16.0, context)
                : customText(AppText().kTextCalculator, 16.0, context),
        centerTitle: true,
      ),
      body: _UIKit(context),
    );
  }

  // Widget: incoginito mode
  Widget wIncoginitoMode(BuildContext context) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: AppColor().kBlue,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _UIKit(BuildContext context) {
    return Column(
      children: [
        if (isInCognito == true) ...[
          wIncoginitoMode(context),
        ] else ...[
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
                        color:
                            isInCognito == true
                                ? Colors.grey[800]
                                : Colors.blue,
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
                        color:
                            isInCognito == false
                                ? Colors.grey[800]
                                : Colors.blue,
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
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                return CalculatorButton(buttons[index], onButtonPressed);
              },
            ),
          ),
          // SizedBox(height: 8),
          _isAdLoaded == false
              ? const SizedBox()
              : Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                color: AppColor().kBlue,
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
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Ad Unit ID
      size: AdSize.banner, // Standard 320x50 banner
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('=========================');
            print(ad);
            print('=========================');
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

    // Start loading the banner ad
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
                  ? Colors.red
                  : label == '='
                  ? Colors.orange
                  : Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
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
