import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EULAScreen extends StatefulWidget {
  const EULAScreen({super.key});

  @override
  State<EULAScreen> createState() => _EULAScreenState();
}

class _EULAScreenState extends State<EULAScreen> {
  // web view controller
  late final WebViewController _controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
        title: Text("Browser", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
    );
  }
}
