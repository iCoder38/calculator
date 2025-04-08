import 'dart:convert';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:http/http.dart' as http;

Future<bool> validateAndroidSubscription({
  required String packageName,
  required String productId,
  required String purchaseToken,
}) async {
  const String endpoint =
      'https://thebluebamboo.in/validate_android_receipt.php';

  try {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'package_name': packageName,
        'product_id': productId,
        'purchase_token': purchaseToken,
      }),
    );

    final json = jsonDecode(response.body);
    customLog("✅ Server response: $json");

    return json['is_subscribed'] == true;
  } catch (e) {
    customLog("❌ Error during subscription check: $e");
    return false;
  }
}
