import 'dart:async';
import 'dart:io';

import 'package:calculator/Classes/Logic/logic.dart';
import 'package:calculator/Classes/Utils/drawer.dart';
import 'package:calculator/Classes/Utils/reusable/resuable.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
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
  /*String bannerLiveId = 'ca-app-pub-9800539067539365/1367212124';
  String bannerTestId = 'ca-app-pub-9800539067539365/1367212124';*/
  // 'ca-app-pub-3940256099942544/6300978111';

  // flutter secure storage
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool isSubscribed = false;
  // store firebase URL
  var firebaseSavePublicObject;
  String storeURL = '';

  bool screenLoader = true;

  // interstitial
  bool _hasShownInterstitial = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  /*String interstitialLiveId = 'ca-app-pub-9800539067539365/4146469422';
  String interstitialTestId = 'ca-app-pub-9800539067539365/4146469422';*/
  // 'ca-app-pub-3940256099942544/1033173712';

  String currentBannerAdType = 'none';
  String currentInterstitialAdType = 'none';

  // Ad Unit IDs
  String bannerLiveId = '';
  String bannerTestId = '';
  String interstitialLiveId = '';
  String interstitialTestId = '';

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

  /*void onButtonPressed(String label) {
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
  }*/
  void onButtonPressed(String label) {
    setState(() {
      if (label == '2nd') {
        isSecondFunctionActive = !isSecondFunctionActive;
        return;
      }

      // Handle memory operations
      if (label == 'MC') {
        calculatorLogic.memory = 0.0;
      } else if (label == 'M+') {
        try {
          String evaluated = calculatorLogic.evaluateExpression(result);
          double value = double.tryParse(evaluated) ?? 0.0;
          calculatorLogic.memory += value;
        } catch (e) {
          result = 'Error';
        }
      } else if (label == 'M-') {
        try {
          String evaluated = calculatorLogic.evaluateExpression(result);
          double value = double.tryParse(evaluated) ?? 0.0;
          calculatorLogic.memory -= value;
        } catch (e) {
          result = 'Error';
        }
      } else if (label == 'MR') {
        result = calculatorLogic.memory.toString();
      } else if (label == '=') {
        result = calculatorLogic.evaluateExpression(result);
      } else {
        result = calculatorLogic.processInput(label, result);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Platform-based assignment
    if (Platform.isIOS) {
      bannerLiveId = 'ca-app-pub-9800539067539365/1367212124';
      bannerTestId = 'ca-app-pub-3940256099942544/2934735716';

      interstitialLiveId = 'ca-app-pub-9800539067539365/4146469422';
      interstitialTestId = 'ca-app-pub-3940256099942544/4411468910';
    } else if (Platform.isAndroid) {
      bannerLiveId = 'ca-app-pub-9800539067539365/1367212124';
      bannerTestId = 'ca-app-pub-3940256099942544/6300978111';

      interstitialLiveId = 'ca-app-pub-9800539067539365/1328734392';
      interstitialTestId = 'ca-app-pub-3940256099942544/1033173712';
    }

    // load subscription
    getValue();

    // bottom ad
    // init banner
    _loadAd();
  }

  void _loadInterstitialAd({bool isFallback = false}) {
    final adUnitId = isFallback ? interstitialTestId : interstitialLiveId;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          currentInterstitialAdType = isFallback ? 'test' : 'live';
          debugPrint('✅ Interstitial Ad Loaded: $currentInterstitialAdType');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          _showInterstitialAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('❌ Interstitial failed to load ($adUnitId): $error');

          if (!isFallback) {
            debugPrint('🔁 Retrying with test ad...');
            _loadInterstitialAd(isFallback: true); // Fallback to test
          }
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          // ✅ DO NOT reload here
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          debugPrint('Ad failed to show: $error');
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdLoaded = false;
    }
  }

  getValue() async {
    bool isLoggedIn = await getBoolSecurely('isSubscribed');
    customLog("🔍 Retrieved: isLoggedIn = $isLoggedIn");
    // return;
    if (isLoggedIn) {
      isSubscribed = true;
      checkStoredUrl();
    } else {
      ensureUserDocumentExists();
      checkSubBeforeAd();
    }
  }

  void checkSubBeforeAd() async {
    await Future.delayed(Duration(milliseconds: 200)).then((v) {
      // full page ad
      // show full screen ad only once per open
      if (!_hasShownInterstitial) {
        _hasShownInterstitial = true;
        _loadInterstitialAd();
      }
    });
  }

  void ensureUserDocumentExists() async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection("Calculator_Incognito/Public_URL/Details")
        .doc("3zaZZcXgFDLisSlnBuUx");

    DocumentSnapshot userSnapshot = await userRef.get();
    if (!userSnapshot.exists) {
      debugPrint('NOT EXIST');
    } else {
      debugPrint('EXIST');
      firebaseSavePublicObject = userSnapshot.data();
      storeURL = firebaseSavePublicObject['public_url'].toString();
      initWebView();
    }
  }

  void checkStoredUrl() async {
    String? storedUrlMain = await getSavedUrl();
    storeURL = fixUrl(storedUrlMain.toString());
    customLog("Stored URL: $storeURL");

    if (storeURL == "No URL Found") {
      ensureUserDocumentExists();
    } else {
      initWebView();
    }
  }

  void initWebView() {
    customLog(storeURL);

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(storeURL)).then((v) {});
    setState(() {
      screenLoader = false;
    });
  }

  String fixUrl(String url) {
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      return "https://$url";
    }
    return url;
  }

  Future<bool> getBoolSecurely(String key) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    String? value = await storage.read(key: key);
    return value == "true";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
        title:
            isInCognito
                ? Text("Browser", style: TextStyle(color: Colors.white))
                : Text("Calculator", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      drawer: CustomDrawer(),
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
    return screenLoader == true
        ? SizedBox()
        : Column(
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
                    height: isSubscribed ? 0 : 60,
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

  void _loadAd({bool isFallback = false}) {
    final adUnitId = isFallback ? bannerTestId : bannerLiveId;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          currentBannerAdType = isFallback ? 'test' : 'live';
          debugPrint('✅ Banner Ad Loaded: $currentBannerAdType');
          debugPrint('✅ Banner Ad Loaded: $adUnitId');
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('❌ BannerAd failed to load ($adUnitId): $error');
          ad.dispose();

          if (!isFallback) {
            debugPrint('🔁 Retrying with test banner ad...');
            _loadAd(isFallback: true); // Retry with test ad
          }
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
