import 'dart:convert';
import 'dart:io';
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
      // Get iOS platform addition
      final storeKitAddition =
          InAppPurchase.instance
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

      // Refresh verification data to update receipt
      final PurchaseVerificationData? verificationData =
          await storeKitAddition.refreshPurchaseVerificationData();

      if (verificationData == null ||
          verificationData.serverVerificationData.isEmpty) {
        print("❌ No receipt found.");
        return false;
      }

      // This is the correct receipt to send to Apple
      final String base64Receipt = verificationData.serverVerificationData;

      print("📦 Sending receipt to server...");

      final response = await http.post(
        Uri.parse(
          "https://thebluebamboo.in/validate_receipt.php",
        ), // Replace with your server
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'receipt_data': base64Receipt}),
      );

      final result = jsonDecode(response.body);
      print("📨 Server response: $result");

      return result['is_subscribed'] == true;
    } catch (e) {
      print("❌ Error checking subscription: $e");
      return false;
    }
  }
}
