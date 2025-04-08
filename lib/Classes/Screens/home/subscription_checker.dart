import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class SubscriptionHelper {
  static Future<bool> checkIOSSubscription() async {
    if (!Platform.isIOS) {
      print("⚠️ Subscription check is only available on iOS.");
      return false;
    }

    try {
      final storeKitAddition =
          InAppPurchase.instance
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

      final PurchaseVerificationData? verificationData =
          await storeKitAddition.refreshPurchaseVerificationData();

      if (verificationData == null ||
          verificationData.serverVerificationData.isEmpty) {
        print("❌ No receipt found.");
        return false;
      }

      final String base64Receipt = verificationData.serverVerificationData;

      print("📦 Sending iOS receipt to server...");

      final response = await http.post(
        Uri.parse("https://thebluebamboo.in/validate_receipt.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'receipt_data': base64Receipt}),
      );

      final result = jsonDecode(response.body);
      print("📨 Server response: $result");

      return result['is_subscribed'] == true;
    } catch (e) {
      print("❌ Error checking iOS subscription: $e");
      return false;
    }
  }

  static Future<bool> checkAndroidSubscription() async {
    if (!Platform.isAndroid) {
      print("⚠️ Subscription check is only available on Android.");
      return false;
    }

    final Completer<bool> completer = Completer();

    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;

    // Listen only once
    final subscription = purchaseUpdated.listen((
      List<PurchaseDetails> purchases,
    ) async {
      for (final purchase in purchases) {
        if (purchase.productID == InAppProductId().productId &&
            purchase.status == PurchaseStatus.purchased) {
          final String purchaseToken =
              purchase.verificationData.serverVerificationData;

          print("📦 Sending Android purchase token to server...");

          final response = await http.post(
            Uri.parse("https://thebluebamboo.in/validate_android_receipt.php"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'package_name': 'com.calculator.prod',
              'product_id': purchase.productID,
              'purchase_token': purchaseToken,
            }),
          );

          final result = jsonDecode(response.body);
          print("📨 Server response: $result");

          completer.complete(result['is_subscribed'] == true);
          return;
        }
      }

      completer.complete(false); // No valid purchase found
    });

    // Trigger restoration of purchases
    await InAppPurchase.instance.restorePurchases();

    // Wait for the listener to complete
    final bool isSubscribed = await completer.future;

    // Clean up the stream
    await subscription.cancel();

    return isSubscribed;
  }
}
