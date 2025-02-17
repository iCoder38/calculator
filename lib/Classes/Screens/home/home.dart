import 'package:calculator/Classes/Screens/Maths/maths.dart';
import 'package:calculator/Classes/Screens/calculator/calculator.dart';
import 'package:calculator/Classes/Utils/resources.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().kBlack,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: customText(AppText().kTextHome, 16.0, context),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: AppColor().kBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(AppImage().kAppLogo),
                ),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalculatorScreen()),
                );
              },
              child: Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppColor().kBlue,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: ExactAssetImage(AppImage().kPrimaryBlueImage),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Image.asset(AppImage().kSmallAppLogo),
                    ),
                    customText(
                      'Calculator',
                      22,
                      context,
                      fontWeight: FontWeight.w800,
                      lightModeColor: AppColor().kWhite,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MathsScreen()),
                );
              },
              child: Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppColor().kBlue,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: ExactAssetImage(AppImage().kPrimaryYellowImage),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Image.asset(AppImage().kMathLogo),
                    ),
                    SizedBox(width: 4),
                    customText(
                      'PHOTO MATH',
                      22,
                      context,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
