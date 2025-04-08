import 'dart:async';
// import 'dart:convert';
import 'dart:io';
// import 'dart:isolate';

import 'package:calculator/Classes/Screens/Maths/maths.dart';
import 'package:calculator/Classes/Screens/calculator/calculator.dart';
import 'package:calculator/Classes/Screens/home/subscription_checker.dart';
// import 'package:calculator/Classes/Screens/upgrade_now/ios.dart';
import 'package:calculator/Classes/Screens/upgrade_now/upgrade_now.dart';
import 'package:calculator/Classes/Utils/resources.dart';
import 'package:calculator/Classes/Utils/reusable/resuable.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isAvailable = false;
  bool _isSubscribed = false;
  final bool _available = false;
  // storage
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // screenloader
  String storeInAppProductId = '';
  bool screenLoader = false;

  @override
  void initState() {
    super.initState();
    // store id
    Set<String> kIds = {InAppProductId().productId};
    if (Platform.isAndroid) {
      customLog("In app product id in Android ======> $kIds");
      storeInAppProductId = kIds.toString();
      final purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        (purchases) {
          _handlePurchaseUpdates(purchases);
        },
        onDone: () {
          _subscription.cancel();
        },
        onError: (error) {
          // Handle error here.
          customLog(error);
        },
      );
      _initialize();
    } else if (Platform.isIOS) {
      customLog("In app product id in iOS ======> $kIds");
      storeInAppProductId = kIds.toString();
      // _listenToPurchaseUpdates();
    }
  }

  void checkSubStatus(context, type) async {
    showLoadingUI(context, "");
    if (Platform.isIOS) {
      bool isSubscribed = await SubscriptionHelper.checkIOSSubscription();

      if (isSubscribed) {
        customLog("✅ YES — User is subscribed");
        setState(() {
          _isSubscribed = true;
        });
        subscribed(true);
        await storage.write(key: 'isSubscribed', value: 'true');
        Navigator.pop(context);
        if (type == '1') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CalculatorScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MathsScreen()),
          );
        }
      } else {
        customLog("🚫 NO — User is not subscribed");
        setState(() {
          _isSubscribed = false;
        });
        subscribed(false);
        await storage.write(key: 'isSubscribed', value: 'false');
        Navigator.pop(context);
        if (type == '1') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CalculatorScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UpgradeNowScreen()),
          );
        }
      }
    } else {
      bool isSubscribed = await SubscriptionHelper.checkAndroidSubscription();
      if (isSubscribed) {
        customLog("✅ YES — User is subscribed: Android");
        Navigator.pop(context);
      } else {
        customLog("NO — User is not subscribed: Android");
        Navigator.pop(context);
      }
    }
  }

  /*Future<String?> _getReceiptData() async {
    if (!Platform.isIOS) return null;

    // Restore purchases to refresh receipts
    await InAppPurchase.instance.restorePurchases();

    // Get the LATEST purchase from the stream
    final List<PurchaseDetails> purchases =
        await InAppPurchase.instance.purchaseStream.first;

    if (purchases.isEmpty) return null;

    // Return the most recent receipt
    return purchases.last.verificationData.serverVerificationData;
  }*/

  /*void _listenToPurchaseUpdates() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;

    _subscription = purchaseUpdated.listen(
      (purchases) async {
        for (var purchase in purchases) {
          if (purchase.productID == InAppProductId().productId) {
            if (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored) {
              if (!purchase.pendingCompletePurchase) {
                InAppPurchase.instance.completePurchase(purchase);
              }

              

              customLog("🎉 Subscription is active in IOS!");

              setState(() {
                _isSubscribed = true;
              });
              subscribed(true);
              await storage.write(key: 'isSubscribed', value: 'true');

              // Complete the purchase
              if (purchase.pendingCompletePurchase) {
                _inAppPurchase.completePurchase(purchase);
              }

              // hasActiveSubscription = true;
            } else {
              setState(() async {
                _isSubscribed = false;
                subscribed(true);
                await storage.write(key: 'isSubscribed', value: 'true');
              });
            }
          }
        }
      },
      onDone: () {
        customLog("Cancelled");
        _subscription.cancel();
      },
      onError: (error) {
        customLog("❌ Purchase stream error: $error");
      },
    );
  }*/

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void initilize() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.write(key: 'isSubscribed', value: false.toString());
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchases) {
        _handlePurchaseUpdates(purchases);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        // Handle error here.
        customLog(error);
      },
    );
    _initialize();
  }

  Future<void> _initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (_isAvailable) {
      // Fetch products and past purchases here.
      await _fetchProducts();
      await _restorePurchases();
    }
  }

  Future<void> _fetchProducts() async {
    Set<String> kIds = {storeInAppProductId};

    if (Platform.isAndroid) {
      customLog("In app product id in Android ======> $kIds");
    } else if (Platform.isIOS) {
      customLog("In app product id in iOS ======> $kIds");
    }

    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails(kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error when the product is not found.
      customLog("Product not found");
      final FlutterSecureStorage storage = FlutterSecureStorage();
      await storage.write(key: 'isSubscribed', value: false.toString());
    } else {
      // Handle the valid products here.
      customLog("Product is valid");
    }
  }

  Future<void> _restorePurchases() async {
    customLog("🔄 Restoring purchases...");
    await _inAppPurchase.restorePurchases();

    // Wait for restored purchases to be processed
    await Future.delayed(Duration(seconds: 1));

    // Check if subscription was restored
    if (!_isSubscribed) {
      customLog("❌ No active subscription found.");
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    bool hasActiveSubscription = false;

    for (var purchase in purchases) {
      if (purchase.productID == storeInAppProductId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          customLog("✅ Subscription is active! in ${Platform.isIOS}");

          setState(() {
            _isSubscribed = true;
            screenLoader = false;
          });
          subscribed(true);
          await storage.write(key: 'isSubscribed', value: 'true');

          // Complete the purchase
          if (purchase.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchase);
          }

          hasActiveSubscription = true;
        } else if (purchase.status == PurchaseStatus.error) {
          customLog("❌ Subscription failed: ${purchase.error}");
          setState(() {
            screenLoader = false;
          });
        }
      }
    }

    if (!hasActiveSubscription) {
      customLog("❌ No active subscription detected.");
      setState(() {
        _isSubscribed = false;
        screenLoader = false;
      });
      subscribed(false);
      await storage.write(key: 'isSubscribed', value: 'false');
    }
  }

  subscribed(bool value) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.write(key: 'isSubscribed', value: value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor().kBlack,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: customText(AppText().kTextHome, 16.0, context),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            screenLoader == true
                ? SizedBox()
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      color: AppColor().kBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(AppImage().kAppLogo),
                      ),
                    ),
                  ),
                ),
            Spacer(),

            screenLoader == true
                ? SizedBox()
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      checkSubStatus(context, '1');
                    },
                    child: Container(
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: AppColor().kBlue,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: ExactAssetImage(AppImage().kPrimaryBlueImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: Image.asset(AppImage().kSmallAppLogo),
                          ),
                          customText(
                            'Calculator',
                            22,
                            context,
                            fontWeight: FontWeight.w800,
                            lightModeColor: AppColor().kWhite,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            screenLoader == true
                ? SizedBox()
                : Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      checkSubStatus(context, '2');
                    },
                    child: Container(
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: AppColor().kBlue,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: ExactAssetImage(
                            AppImage().kPrimaryYellowImage,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: Image.asset(AppImage().kMathLogo),
                          ),
                          SizedBox(width: 4),
                          customText(
                            'PHOTO MATH',
                            22,
                            context,
                            fontWeight: FontWeight.w800,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 24.0),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'By verifying yourself, you agree to our ',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      children: [
                        TextSpan(
                          text: 'Terms',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  _launchUrl(
                                    "https://incognitocalculator.com/terms-%26-conditions",
                                  );
                                },
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  _launchUrl(
                                    "https://incognitocalculator.com/privacy-policy",
                                  );
                                },
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
