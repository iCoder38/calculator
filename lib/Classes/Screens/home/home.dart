import 'dart:async';

import 'package:calculator/Classes/Screens/Maths/maths.dart';
import 'package:calculator/Classes/Screens/calculator/calculator.dart';
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

  @override
  void initState() {
    super.initState();
    //
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

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void initilize() {
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
    await _inAppPurchase.restorePurchases();
    // Restored purchases will be emitted on the purchaseStream with a status of PurchaseStatus.restored.
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.productID == InAppProductId().productId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          customLog("✅ Subscription purchased successfully!");

          // Mark user as subscribed
          setState(() {
            _isSubscribed = true;
          });
          subscribed(true);

          // Complete the purchase
          if (purchase.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchase);
          }
        } else if (purchase.status == PurchaseStatus.error) {
          customLog("❌ Subscription purchase failed: ${purchase.error}");
          subscribed(false);
        }
      }
    }
  }

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
      ),
      body: Column(
        children: [
          Padding(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalculatorScreen()),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MathsScreen()),
                );
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
