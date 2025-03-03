import 'package:calculator/Classes/Screens/home/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // google ads
  (MobileAds.instance.initialize());

  // init firebase
  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen()));
}
