import 'dart:async';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IOSSubscriptionTestScreen extends StatefulWidget {
  const IOSSubscriptionTestScreen({super.key});

  @override
  State<IOSSubscriptionTestScreen> createState() =>
      _IOSSubscriptionTestScreenState();
}

class _IOSSubscriptionTestScreenState extends State<IOSSubscriptionTestScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  final String _kProductId = 'per_month_099'; // iOS product ID

  List<ProductDetails> _products = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _available = false;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      customLog("❌ IAP not available");
      return;
    } else {
      customLog("IAP Availaible");
    }

    final response = await _iap.queryProductDetails({_kProductId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint("❌ Product not found: ${response.notFoundIDs}");
    } else {
      setState(() {
        _products = response.productDetails;
      });
    }

    final response2 = await InAppPurchase.instance.queryProductDetails({
      'per_month_099',
    });
    print(
      "Found: ${response2.productDetails.length}, Not Found: ${response2.notFoundIDs}",
    );

    _subscription = _iap.purchaseStream.listen(_handlePurchaseUpdates);

    // new
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.productID == _kProductId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        debugPrint("✅ Active subscription found");
        setState(() {
          _isSubscribed = true;
        });
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint("❌ Purchase error: ${purchase.error}");
      }
    }
  }

  Future<void> _subscribe() async {
    if (_products.isEmpty) return;

    final purchaseParam = PurchaseParam(productDetails: _products.first);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _restore() async {
    await _iap.restorePurchases();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("iOS Subscription Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Subscription Status: ${_isSubscribed ? 'Active ✅' : 'Inactive ❌'}",
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _products.isEmpty ? null : _subscribe,
              child: const Text("Subscribe (Sandbox)"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _restore,
              child: const Text("Restore Purchases"),
            ),
            const SizedBox(height: 20),
            const Text("🔁 Sandbox Auto-Renew Info:"),
            const Text("• 1 Month Plan = renews every 5 minutes (up to 6x)"),
            const Text("• Test cancellations by logging out of sandbox"),
          ],
        ),
      ),
    );
  }
}
