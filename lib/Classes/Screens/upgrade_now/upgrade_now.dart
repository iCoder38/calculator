import 'package:calculator/Classes/Screens/home/home.dart';
import 'package:calculator/Classes/Utils/drawer.dart';
import 'package:calculator/Classes/Utils/resources.dart';
import 'package:calculator/Classes/Utils/reusable/resuable.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
  final Set<String> _kProductIds = {'ad_free_099'};

  bool _available = false;
  List<ProductDetails> _products = [];

  String strPush = '0';

  String subscriptionPrice = '0';
  @override
  void initState() {
    super.initState();

    _initializeBilling();
    _listenToPurchaseUpdates();
    //
    fetchProductDetails();
  }

  void fetchProductDetails() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) return;

    Set<String> _kIds = {InAppProductId().productId};
    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails(_kIds);

    if (response.notFoundIDs.isEmpty) {
      ProductDetails product = response.productDetails.first;
      customLog("Subscription Price: ${product.price}");
      subscriptionPrice = product.price.toString();
      setState(() {});
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
              text: '1 Month [ $subscriptionPrice ]',
              textSize: 18.0,
              bgColor: Colors.blue,
              bgImage: AppImage().kPrimaryYellowImage,
              onPressed: () {
                /*Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UpgradeNowScreen()),
                );*/
              },
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_products.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomBannerButton(
                    text: 'Upgrade now',
                    textSize: 18.0,
                    bgColor: Colors.blue,
                    bgImage: AppImage().kPrimaryYellowImage,
                    onPressed: () {
                      customLog(
                        "No subscription found, but upgrade button is still clickable.",
                      );
                      // You can also show a message or navigate to an info screen
                    },
                  ),
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
              }).toList(),
            ],
          ),

          /*Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomBannerButton(
              text: 'Upgrade now',
              textSize: 18.0,
              bgColor: Colors.blue,
              bgImage: AppImage().kPrimaryYellowImage,
              // onPressed: () => onSubscribePressed(product),
            ),
          ),*/
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
    Set<String> productIds = {
      InAppProductId().productId,
    }; // Replace with your Product ID
    ProductDetailsResponse response = await _iap.queryProductDetails(
      productIds,
    );

    if (response.notFoundIDs.isNotEmpty) {
      customLog("Subscription not found: ${response.notFoundIDs}");
    } else {
      setState(() {
        _products = response.productDetails;
      });
      customLog("Products found: $_products");
    }
  }

  Future<List<ProductDetails>> fetchSubscriptions() async {
    ProductDetailsResponse response = await _iap.queryProductDetails(
      _kProductIds,
    );
    customLog(response);
    if (response.notFoundIDs.isNotEmpty) {
      customLog("Subscription not found: ${response.notFoundIDs}");
      return [];
    } else {
      return response.productDetails;
    }
  }

  void onSubscribePressed(ProductDetails product) async {
    bool success = await _buySubscription(product);
    if (success) {
      customLog("🎉 Subscription Successful!");
    } else {
      customLog("❌ Subscription Failed!");
    }
  }

  Future<bool> _buySubscription(ProductDetails product) async {
    customLog("🛒 _buySubscription() called for product: ${product.id}");

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    bool started = await _iap.buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: false,
    );

    if (!started) {
      customLog("❌ Purchase process did not start!");
      return false;
    }

    // ✅ No need to listen to purchaseStream here, it’s already being handled in initState()
    return true;
  }

  // listen
  void _listenToPurchaseUpdates() {
    customLog("Listen");
    _iap.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (var purchase in purchases) {
        if (purchase.productID == InAppProductId().productId &&
            (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored)) {
          customLog("✅ Subscription detected in SubscriptionTestScreen!");
          customLog("🎉 Subscription Successfull!");
          _pushToHomeScreen();
        } else if (purchase.status == PurchaseStatus.error) {
          customLog("❌ Subscription Failed: ${purchase.error}");
        }
      }
    });
  }

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
/*
import 'package:calculator/Classes/Screens/calculator/calculator.dart';
import 'package:calculator/Classes/Screens/home/home.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionTestScreen extends StatefulWidget {
  const SubscriptionTestScreen({super.key});

  @override
  _SubscriptionTestScreenState createState() => _SubscriptionTestScreenState();
}

class _SubscriptionTestScreenState extends State<SubscriptionTestScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    _initializeBilling();
    _listenToPurchaseUpdates();
  }

  Future<void> _initializeBilling() async {
    // Check if Google Play Billing is available
    _available = await _iap.isAvailable();
    if (!_available) {
      customLog("Google Play Billing is NOT available.");
      return;
    }

    // Query available subscriptions
    Set<String> productIds = {
      InAppProductId().productId,
    }; // Replace with your Product ID
    ProductDetailsResponse response = await _iap.queryProductDetails(
      productIds,
    );

    if (response.notFoundIDs.isNotEmpty) {
      customLog("Subscription not found: ${response.notFoundIDs}");
    } else {
      setState(() {
        _products = response.productDetails;
      });
      customLog("Products found: $_products");
    }
  }

  void onSubscribePressed(ProductDetails product) async {
    bool success = await _buySubscription(product);
    if (success) {
      customLog("🎉 Subscription Successful!");
    } else {
      customLog("❌ Subscription Failed!");
    }
  }

  Future<bool> _buySubscription(ProductDetails product) async {
    customLog("🛒 _buySubscription() called for product: ${product.id}");

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    bool started = await _iap.buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: false,
    );

    if (!started) {
      customLog("❌ Purchase process did not start!");
      return false;
    }

    // ✅ No need to listen to purchaseStream here, it’s already being handled in initState()
    return true;
  }

  // listen
  void _listenToPurchaseUpdates() {
    _iap.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (var purchase in purchases) {
        if (purchase.productID == InAppProductId().productId &&
            (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored)) {
          customLog("✅ Subscription detected in SubscriptionTestScreen!");
          customLog("🎉 Subscription Successful!");
          _pushToHomeScreen();
        } else if (purchase.status == PurchaseStatus.error) {
          customLog("❌ Subscription Failed: ${purchase.error}");
        }
      }
    });
  }

  void _pushToHomeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subscription Test")),
      body: Center(
        child:
            _products.isEmpty
                ? Text("No Subscription Found")
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      _products.map((product) {
                        return Column(
                          children: [
                            Text(
                              product.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(product.description),
                            Text(
                              "Price: ${product.price}",
                              style: TextStyle(color: Colors.green),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => onSubscribePressed(product),
                              child: Text("Subscribe Now"),
                            ),
                            Divider(),
                          ],
                        );
                      }).toList(),
                ),
      ),
    );
  }
}
*/