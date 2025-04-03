import 'dart:io';

import 'package:calculator/Classes/Screens/home/home.dart';
import 'package:calculator/Classes/Screens/upgrade_now/loading.dart';
import 'package:calculator/Classes/Utils/drawer.dart';
import 'package:calculator/Classes/Utils/resources.dart';
import 'package:calculator/Classes/Utils/reusable/resuable.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:url_launcher/url_launcher.dart';

class UpgradeNowScreen extends StatefulWidget {
  const UpgradeNowScreen({super.key});

  @override
  State<UpgradeNowScreen> createState() => _UpgradeNowScreenState();
}

class _UpgradeNowScreenState extends State<UpgradeNowScreen> {
  // menu
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // in app instance
  final InAppPurchase _iap = InAppPurchase.instance;
  // sb id
  //  final Set<String> _kProductIds = {'ad_free_099'};

  bool _available = false;
  List<ProductDetails> _products = [];

  String strPush = '0';

  String subscriptionPrice = '0';

  // is purchasing
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();

    // if (Platform.isIOS) {
    //   _completePendingTransactions(); // ✅ Call FIRST
    // }

    // _listenToPurchaseUpdates();
    // _initializeBilling();
    // fetchProductDetails();
    // _restorePastPurchases();
    _completePendingTransactions(); // Clear pending FIRST
    _listenToPurchaseUpdates(); // THEN listen updates
    _initializeBilling(); // Initialize billing
    fetchProductDetails(); // Load subscription details
  }

  Future<void> _completePendingTransactions() async {
    if (Platform.isIOS) {
      customLog("🚀 Completing Pending Transactions (iOS)...");

      final transactions = await SKPaymentQueueWrapper().transactions();
      for (var transaction in transactions) {
        customLog(
          "🔍 Found pending transaction: ${transaction.payment.productIdentifier} (${transaction.transactionState})",
        );

        if (transaction.transactionState ==
                SKPaymentTransactionStateWrapper.purchased ||
            transaction.transactionState ==
                SKPaymentTransactionStateWrapper.restored) {
          await SKPaymentQueueWrapper().finishTransaction(transaction);
          customLog(
            "✅ Transaction ${transaction.payment.productIdentifier} completed!",
          );
        } else if (transaction.transactionState ==
            SKPaymentTransactionStateWrapper.failed) {
          await SKPaymentQueueWrapper().finishTransaction(transaction);
          customLog(
            "❌ Transaction ${transaction.payment.productIdentifier} failed and cleared.",
          );
        }
      }
    }
  }

  /*Future<void> _checkPendingPurchases() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;

    purchaseUpdated.listen((List<PurchaseDetails> purchases) {
      purchases.forEach((purchase) async {
        customLog(
          "🔔 Checking purchase status: ${purchase.productID} - ${purchase.status}",
        );

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
          customLog("✅ Completed pending purchase for: ${purchase.productID}");
        }

        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            _pushToHomeScreen();
            break;
          case PurchaseStatus.error:
            customLog("❌ Error completing purchase: ${purchase.error}");
            break;
          case PurchaseStatus.canceled:
            customLog("❗️ User canceled the purchase: ${purchase.productID}");
            break;
          default:
            break;
        }
      });
    });
  }*/

  void fetchProductDetails() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      customLog("❌ In-App Purchase system is not available.");
      return;
    }

    Set<String> kIds = {InAppProductId().productId}; // Hardcoded for now

    if (Platform.isAndroid) {
      // customLog("📱 Product ID for Android: $kIds");
    } else if (Platform.isIOS) {
      // customLog("📱 Product ID for iOS: $kIds");
    }

    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails(kIds);

    if (response.notFoundIDs.isEmpty) {
      for (ProductDetails product in response.productDetails) {
        /*customLog("✅ Found Product:");
        customLog("ID: ${product.id}");
        customLog("Title: ${product.title}");
        customLog("Description: ${product.description}");
        customLog("Price: ${product.price}");*/
      }
      subscriptionPrice = response.productDetails.first.price.toString();
      setState(() {});
    } else {
      customLog("❌ Not Found IDs: ${response.notFoundIDs}");
    }
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
        title: customText(
          "Upgrade account  ",
          16.0,
          context,
          lightModeColor: AppColor().kWhite,
        ),
        centerTitle: true,
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomBannerButton(
              text:
                  //'1 Month \$0.99',
                  '1 Month [ $subscriptionPrice ]',
              textSize: 18.0,
              bgColor: Colors.blue,
              bgImage: AppImage().kPrimaryYellowImage,
              onPressed: () {},
            ),
          ),
          SizedBox(height: 40),
          Row(
            children: [
              SizedBox(width: 16.0),
              customText(
                "IN PAID VERSION:",
                20.0,
                context,
                fontWeight: FontWeight.w800,
                lightModeColor: AppColor().kWhite,
              ),
            ],
          ),
          SizedBox(height: 40),
          Row(
            children: [
              SizedBox(width: 16.0),
              SizedBox(
                height: 30,
                width: 30,
                child: Image.asset('assets/images/tick@2x.png'),
              ),
              SizedBox(width: 8),
              customText(
                "Ad-Free Experience",
                18.0,
                context,
                fontWeight: FontWeight.w600,
                lightModeColor: AppColor().kWhite,
              ),
            ],
          ),
          SizedBox(height: 40),
          Row(
            children: [
              SizedBox(width: 16.0),
              SizedBox(
                height: 30,
                width: 30,
                child: Image.asset('assets/images/tick@2x.png'),
              ),
              SizedBox(width: 8),
              customText(
                "Customizable Incognito URL",
                18.0,
                context,
                fontWeight: FontWeight.w600,
                lightModeColor: AppColor().kWhite,
              ),
            ],
          ),
          SizedBox(height: 40),
          Row(
            children: [
              SizedBox(width: 16.0),
              SizedBox(
                height: 30,
                width: 30,
                child: Image.asset('assets/images/tick@2x.png'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: customText(
                  "Photo Math API for solving equations and show step by step guidance.",
                  18.0,
                  context,
                  fontWeight: FontWeight.w600,
                  lightModeColor: AppColor().kWhite,
                ),
              ),
            ],
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This is a 1-month auto-renewable subscription for $subscriptionPrice.",
                  // "This is a 1-month auto-renewable subscription for \$0.99.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("auto-renewable", style: TextStyle(color: Colors.white)),
                Text(
                  "Length: 1 Month [$subscriptionPrice]",
                  style: TextStyle(color: Colors.white),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed:
                          () => launchUrl(
                            Uri.parse(
                              "https://incognitocalculator.com/privacy-policy",
                            ),
                          ),
                      child: Text("Privacy Policy"),
                    ),
                    TextButton(
                      onPressed:
                          () => launchUrl(
                            Uri.parse(
                              "https://incognitocalculator.com/terms-%26-conditions",
                            ),
                          ),
                      child: Text("Terms of Use"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_products.isEmpty)
                Column(
                  children: [
                    /*Text(
                      "Loading subscription details...",
                      style: TextStyle(color: Colors.grey),
                    ),*/
                    CustomBannerButton(
                      text: 'Upgrade Now',
                      textSize: 18.0,
                      bgColor: Colors.blue,
                      onPressed: () {
                        if (_products.isEmpty) {
                        } else {
                          // ✅ Initiate purchase when subscription is loaded
                          onSubscribePressed(_products.first);
                        }
                      },
                    ),
                  ],
                ),
              ..._products.map((product) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomBannerButton(
                    text: 'Upgrade now',
                    textSize: 18.0,
                    bgColor: Colors.blue,
                    bgImage: AppImage().kPrimaryYellowImage,
                    onPressed: () => onSubscribePressed(product),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _initializeBilling() async {
    // Check if Google Play Billing is available
    _available = await _iap.isAvailable();
    if (!_available) {
      customLog("Google Play Billing is NOT available.");
      return;
    }

    // Query available subscriptions
    Set<String> productIds = {InAppProductId().productId};
    customLog("Product Id is: ====> $productIds");
    // Replace with your Product ID
    ProductDetailsResponse response = await _iap.queryProductDetails(
      productIds,
    );

    if (response.notFoundIDs.isNotEmpty) {
      customLog("Subscription not found 2: ${response.notFoundIDs}");
    } else {
      setState(() {
        _products = response.productDetails;
      });
      // customLog("Products found: $_products");
    }
  }

  void onSubscribePressed(ProductDetails product) async {
    HapticFeedback.mediumImpact();
    if (_isPurchasing) return;
    _isPurchasing = true;

    showLoadingUI(context, "Processing your purchase...");

    bool success = await _buySubscription(product);

    Navigator.pop(context); // Close loading UI exactly once

    if (success) {
      customLog("🎉 Subscription initiated successfully!");
    } else {
      customLog("❌ Subscription initiation failed!");
      // Optionally, show a user-friendly alert here
    }

    _isPurchasing = false;
  }

  Future<bool> _buySubscription(ProductDetails product) async {
    customLog("🛒 _buySubscription() called for product: ${product.id}");

    final PurchaseParam param = PurchaseParam(productDetails: product);
    bool started = false;

    if (Platform.isIOS) {
      started = await _iap.buyNonConsumable(purchaseParam: param);
    } else {
      started = await _iap.buyConsumable(
        purchaseParam: param,
        autoConsume: false,
      );
    }

    if (!started) {
      customLog("❌ Purchase process did not start!");
      return false;
    }

    return true;
  }

  // listen

  void _listenToPurchaseUpdates() {
    _iap.purchaseStream.listen((List<PurchaseDetails> purchases) async {
      for (var purchase in purchases) {
        customLog("🔔 Purchase status: ${purchase.status}");

        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            if (purchase.pendingCompletePurchase) {
              customLog("✅ Completing purchase: ${purchase.productID}");
              await _iap.completePurchase(purchase);
            }
            _pushToHomeScreen();
            break;

          case PurchaseStatus.pending:
            customLog("⏳ Purchase pending...");
            showLoadingUI(context, "message");
            break;

          case PurchaseStatus.canceled:
          case PurchaseStatus.error:
            customLog(
              "❌ Purchase canceled or error: ${purchase.error?.message}",
            );
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
            break;
        }
      }
    });
  }

  /*Future<void> _restorePastPurchases() async {
    final bool available = await _iap.isAvailable();
    if (!available) return;

    if (Platform.isIOS) {
      await _iap
          .restorePurchases(); // This triggers purchaseStream with past purchases.
    }
  }*/

  void _pushToHomeScreen() {
    if (strPush == '0') {
      strPush = '1';
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }
}

class MyPaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
