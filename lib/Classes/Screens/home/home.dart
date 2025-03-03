import 'dart:async';

import 'package:calculator/Classes/Screens/Maths/maths.dart';
import 'package:calculator/Classes/Screens/calculator/calculator.dart';
import 'package:calculator/Classes/Screens/upgrade_now/upgrade_now.dart';
import 'package:calculator/Classes/Utils/resources.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
  bool _available = false;
  // storage
  FlutterSecureStorage _storage = FlutterSecureStorage();
  // screenloader
  bool screenLoader = true;
  @override
  void initState() {
    super.initState();
    //
    /*_initializeBilling();
    _listenToPurchaseUpdates();
    checkSubscriptionStatus().then((isSubscribed) {
      setState(() {
        _isSubscribed = isSubscribed;
      });
    });*/
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
    //
    // _checkSubscriptionStatus();
  }

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

  /*Future<void> _initializeBilling() async {
    // Check if Google Play Billing is available
    _available = await _inAppPurchase.isAvailable();
    if (!_available) {
      customLog("❌ Google Play Billing is NOT available.");
      return;
    }

    // Query available subscriptions
    Set<String> productIds = {
      InAppProductId().productId, // Ensure this ID matches Play Console
    };

    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
      productIds,
    );

    if (response.notFoundIDs.isNotEmpty) {
      customLog("❌ Subscription not found: ${response.notFoundIDs}");
    } else {
      customLog("subs");
      setState(() {
        // _products = response.productDetails;
        customLog(response.productDetails);
      });
      // print("✅ Products found: $_products");
      customLog("✅ Products found: ${response.productDetails}");
    }
  }

  void _listenToPurchaseUpdates() {
    customLog("_listenToPurchaseUpdates");
    _inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (var purchase in purchases) {
        if (purchase.productID == InAppProductId().productId) {
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            customLog("✅ Subscription Activated!");

            // Unlock premium content here
            setState(() {
              _isSubscribed = true;
            });

            // Complete the purchase
            if (purchase.pendingCompletePurchase) {
              _inAppPurchase.completePurchase(purchase);
            }
          } else if (purchase.status == PurchaseStatus.error) {
            customLog("❌ Subscription Failed: ${purchase.error}");
          }
        }
      }
    });
  }

  Future<bool> checkSubscriptionStatus() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      print("❌ Google Play Billing is NOT available.");
      return false;
    }

    // Query past purchases
    final List<PurchaseDetails> pastPurchases =
        await _inAppPurchase.queryPastPurchases();

    for (var purchase in pastPurchases) {
      if (purchase.productID == InAppProductId().productId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        print("✅ User has an active subscription!");
        return true;
      }
    }

    print("❌ User's subscription is NOT active.");
    return false;
  }*/

  Future<void> _initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (_isAvailable) {
      // Fetch products and past purchases here.
      await _fetchProducts();
      await _restorePurchases();
    }
  }

  Future<void> _fetchProducts() async {
    Set<String> kIds = {InAppProductId().productId};
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
    await Future.delayed(Duration(seconds: 2));

    // Check if subscription was restored
    if (!_isSubscribed) {
      customLog("❌ No active subscription found.");
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    bool hasActiveSubscription = false;

    for (var purchase in purchases) {
      if (purchase.productID == InAppProductId().productId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          customLog("✅ Subscription is active!");

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

  // #2
  /// **Single Function to Check Subscription**
  /*Future<void> _checkSubscriptionStatus() async {
    // 1️⃣ Check if Google Play Billing is available
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      customLog("❌ Google Play Billing is NOT available.");
      return;
    }

    // 2️⃣ Restore purchases to check past subscriptions
    await _inAppPurchase.restorePurchases();

    // 3️⃣ Wait for purchases to update
    await Future.delayed(Duration(milliseconds: 400));

    // 4️⃣ Listen for past and restored purchases
    bool hasActiveSubscription = false;
    final subscription = _inAppPurchase.purchaseStream.listen((
      List<PurchaseDetails> purchases,
    ) {
      for (var purchase in purchases) {
        if (purchase.productID == InAppProductId().productId &&
            (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored)) {
          customLog("✅ User has an active subscription!");
          hasActiveSubscription = true;
        }
      }
    });

    // 5️⃣ Wait for stream to process and cancel listener
    await Future.delayed(Duration(milliseconds: 400));
    await subscription.cancel();

    // 6️⃣ Save and update subscription status
    await _storage.write(
      key: 'isSubscribed',
      value: hasActiveSubscription.toString(),
    );
    setState(() {
      _isSubscribed = hasActiveSubscription;
      screenLoader = false;
    });

    customLog(
      _isSubscribed ? "✅ User is subscribed." : "❌ User is NOT subscribed.",
    );
  }*/

  subscribed(bool value) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.write(key: 'isSubscribed', value: value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalculatorScreen(),
                      ),
                    );
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
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: GestureDetector(
                  onTap: () {
                    if (_isSubscribed == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MathsScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpgradeNowScreen(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: AppColor().kBlue,
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: ExactAssetImage(AppImage().kPrimaryYellowImage),
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
        ],
      ),
    );
  }
}
