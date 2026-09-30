import 'dart:io';

import 'package:calculator/Classes/Screens/home/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preserve the existing backend's App Store receipt validation flow.
  if (Platform.isIOS) {
    // ignore: deprecated_member_use
    await InAppPurchaseStoreKitPlatform.enableStoreKit1();
  }

  // google ads
  (MobileAds.instance.initialize());

  // Initialize Firebase
  await Firebase.initializeApp();

  /*if (Platform.isIOS) {
    final iosPlatformAddition =
        InAppPurchase.instance
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

    await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());

    // Restore previous purchases to clear any stuck transactions
    await InAppPurchase.instance.restorePurchases();
  }*/

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen()));
}

/*class ExamplePaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() => false;
}*/
