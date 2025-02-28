import 'package:calculator/Classes/Utils/drawer.dart';
import 'package:calculator/Classes/Utils/resources.dart';
import 'package:calculator/Classes/Utils/reusable/resuable.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

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

  @override
  void initState() {
    super.initState();

    checkBillingAvailability();
  }

  Future<bool> checkBillingAvailability() async {
    final bool available = await _iap.isAvailable();
    customLog('availaible: $available');
    return available;
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
              text: '1 Month [ \$0.99 per month ]',
              textSize: 18.0,
              bgColor: Colors.blue,
              bgImage: AppImage().kPrimaryYellowImage,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UpgradeNowScreen()),
                );
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomBannerButton(
              text: 'Upgrade now',
              textSize: 18.0,
              bgColor: Colors.blue,
              bgImage: AppImage().kPrimaryYellowImage,
              onPressed: () {
                fetchSubscriptions();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<ProductDetails>> fetchSubscriptions() async {
    ProductDetailsResponse response = await _iap.queryProductDetails(
      _kProductIds,
    );
    customLog(response);
    if (response.notFoundIDs.isNotEmpty) {
      print("Subscription not found: ${response.notFoundIDs}");
      return [];
    } else {
      return response.productDetails;
    }
  }
}
