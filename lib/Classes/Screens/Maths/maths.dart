import 'package:calculator/Classes/Utils/drawer.dart';
import 'package:calculator/Classes/Utils/resources.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/material.dart';

class MathsScreen extends StatefulWidget {
  const MathsScreen({super.key});

  @override
  State<MathsScreen> createState() => _MathsScreenState();
}

class _MathsScreenState extends State<MathsScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: customText(AppText().kScanQuestion, 16.0, context),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
      ),
      drawer: CustomDrawer(),
      // body: _UIKit(context),
    );
  }
}
