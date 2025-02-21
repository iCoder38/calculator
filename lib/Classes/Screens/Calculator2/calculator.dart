import 'package:calculator/Classes/Utils/resources.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:math_expressions/math_expressions.dart';
// webview
import 'package:webview_flutter/webview_flutter.dart';

class ScientificCalculator extends StatefulWidget {
  // final VoidCallback toggleTheme;
  const ScientificCalculator({super.key});

  @override
  ScientificCalculatorState createState() => ScientificCalculatorState();
}

class ScientificCalculatorState extends State<ScientificCalculator> {
  String expression = '0';
  String result = '0';
  bool isScientificMode = false;

  // web view controller
  late final WebViewController _controller;

  // banner
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

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

  void onButtonPressed(String text) {
    setState(() {
      if (text == 'C') {
        expression = '0';
        result = '0';
      } else if (text == '=') {
        try {
          Parser p = Parser();
          Expression exp = p.parse(
            expression.replaceAll('×', '*').replaceAll('÷', '/'),
          );
          ContextModel cm = ContextModel();
          result = '${exp.evaluate(EvaluationType.REAL, cm)}';
        } catch (e) {
          result = 'Error';
        }
      } else {
        if (expression == '0') {
          expression = text;
        } else {
          expression += text;
        }
      }
    });
  }

  void toggleScientificMode() {
    setState(() {
      isScientificMode = !isScientificMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().kBlack,
      appBar: AppBar(
        title: const Text('Scientific Calculator 2'),
        centerTitle: true,
        actions: [
          // IconButton(
          // icon: Icon(Icons.brightness_6),
          // onPressed: widget.toggleTheme,
          // ),
          /*IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.pushNamed(context, '/conversion');
            },
          ),*/
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColor().kBlack,
              padding: EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  customText(
                    expression,
                    18.0,
                    context,
                    lightModeColor: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 10),
                  customText(
                    result,
                    24.0,
                    context,
                    lightModeColor: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: toggleScientificMode,
                    child: Text(isScientificMode ? 'Basic' : 'Scientific'),
                  ),
                ),
                Divider(),

                if (isScientificMode) _buildScientificKeyboard(),
                _buildBasicKeyboard(),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildBasicKeyboard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('7'),
            _buildButton('8'),
            _buildButton('9'),
            _buildButton('÷'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('4'),
            _buildButton('5'),
            _buildButton('6'),
            _buildButton('×'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('1'),
            _buildButton('2'),
            _buildButton('3'),
            _buildButton('-'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('0'),
            _buildButton('.'),
            _buildButton('='),
            _buildButton('+'),
          ],
        ),
      ],
    );
  }

  Widget _buildScientificKeyboard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('sin'),
            _buildButton('cos'),
            _buildButton('tan'),
            _buildButton('π'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('√'),
            _buildButton('^'),
            _buildButton('ln'),
            _buildButton('log'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('('),
            _buildButton(')'),
            _buildButton('%'),
            _buildButton('e'),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: () => onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
