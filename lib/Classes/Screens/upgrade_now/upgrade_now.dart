// import 'package:calculator/Classes/Utils/drawer.dart';
// import 'package:calculator/Classes/Utils/resources.dart';
// import 'package:calculator/Classes/Utils/reusable/resuable.dart';
// import 'package:calculator/Classes/Utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';

// class UpgradeNowScreen extends StatefulWidget {
//   const UpgradeNowScreen({super.key});

//   @override
//   State<UpgradeNowScreen> createState() => _UpgradeNowScreenState();
// }

// class _UpgradeNowScreenState extends State<UpgradeNowScreen> {
//   // menu
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   // in app instance
//   final InAppPurchase _iap = InAppPurchase.instance;
//   // sb id
//   final Set<String> _kProductIds = {'ad_free_099'};

//   bool _available = false;
//   List<ProductDetails> _products = [];

//   @override
//   void initState() {
//     super.initState();

//     _initializeBilling();
//   }

//   Future<void> _initializeBilling() async {
//     // Check if Google Play Billing is available
//     _available = await _iap.isAvailable();
//     if (!_available) {
//       print("Google Play Billing is NOT available.");
//       return;
//     }

//     // Query available subscriptions
//     const Set<String> _productIds = {
//       'ad_free_099',
//     }; // Replace with your Product ID
//     ProductDetailsResponse response = await _iap.queryProductDetails(
//       _productIds,
//     );

//     if (response.notFoundIDs.isNotEmpty) {
//       print("Subscription not found: ${response.notFoundIDs}");
//     } else {
//       setState(() {
//         _products = response.productDetails;
//       });
//       print("Products found: $_products");
//     }
//   }

//   void _buySubscription(ProductDetails product) {
//     final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
//     _iap.buyNonConsumable(purchaseParam: purchaseParam);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         automaticallyImplyLeading: false,
//         leading: IconButton(
//           onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//           icon: const Icon(Icons.menu, color: Colors.white),
//         ),
//         title: customText(
//           "Upgrade account  ",
//           16.0,
//           context,
//           lightModeColor: AppColor().kWhite,
//         ),
//         centerTitle: true,
//       ),
//       drawer: CustomDrawer(),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: CustomBannerButton(
//               text: '1 Month [ \$0.99 per month ]',
//               textSize: 18.0,
//               bgColor: Colors.blue,
//               bgImage: AppImage().kPrimaryYellowImage,
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => UpgradeNowScreen()),
//                 );
//               },
//             ),
//           ),
//           SizedBox(height: 40),
//           Row(
//             children: [
//               SizedBox(width: 16.0),
//               customText(
//                 "IN PAID VERSION:",
//                 20.0,
//                 context,
//                 fontWeight: FontWeight.w800,
//                 lightModeColor: AppColor().kWhite,
//               ),
//             ],
//           ),
//           SizedBox(height: 40),
//           Row(
//             children: [
//               SizedBox(width: 16.0),
//               SizedBox(
//                 height: 30,
//                 width: 30,
//                 child: Image.asset('assets/images/tick@2x.png'),
//               ),
//               SizedBox(width: 8),
//               customText(
//                 "Ad-Free Experience",
//                 18.0,
//                 context,
//                 fontWeight: FontWeight.w600,
//                 lightModeColor: AppColor().kWhite,
//               ),
//             ],
//           ),
//           SizedBox(height: 40),
//           Row(
//             children: [
//               SizedBox(width: 16.0),
//               SizedBox(
//                 height: 30,
//                 width: 30,
//                 child: Image.asset('assets/images/tick@2x.png'),
//               ),
//               SizedBox(width: 8),
//               customText(
//                 "Customizable Incognito URL",
//                 18.0,
//                 context,
//                 fontWeight: FontWeight.w600,
//                 lightModeColor: AppColor().kWhite,
//               ),
//             ],
//           ),
//           SizedBox(height: 40),
//           Row(
//             children: [
//               SizedBox(width: 16.0),
//               SizedBox(
//                 height: 30,
//                 width: 30,
//                 child: Image.asset('assets/images/tick@2x.png'),
//               ),
//               SizedBox(width: 8),
//               Expanded(
//                 child: customText(
//                   "Photo Math API for solving equations and show step by step guidance.",
//                   18.0,
//                   context,
//                   fontWeight: FontWeight.w600,
//                   lightModeColor: AppColor().kWhite,
//                 ),
//               ),
//             ],
//           ),
//           Spacer(),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: CustomBannerButton(
//               text: 'Upgrade now',
//               textSize: 18.0,
//               bgColor: Colors.blue,
//               bgImage: AppImage().kPrimaryYellowImage,
//               onPressed: () => _buySubscription(product),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<List<ProductDetails>> fetchSubscriptions() async {
//     ProductDetailsResponse response = await _iap.queryProductDetails(
//       _kProductIds,
//     );
//     customLog(response);
//     if (response.notFoundIDs.isNotEmpty) {
//       print("Subscription not found: ${response.notFoundIDs}");
//       return [];
//     } else {
//       return response.productDetails;
//     }
//   }
// }
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionTestScreen extends StatefulWidget {
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
  }

  Future<void> _initializeBilling() async {
    // Check if Google Play Billing is available
    _available = await _iap.isAvailable();
    if (!_available) {
      customLog("Google Play Billing is NOT available.");
      return;
    }

    // Query available subscriptions
    const Set<String> _productIds = {
      'ad_free_099',
    }; // Replace with your Product ID
    ProductDetailsResponse response = await _iap.queryProductDetails(
      _productIds,
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

  void _buySubscription(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
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
                              onPressed: () => _buySubscription(product),
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
