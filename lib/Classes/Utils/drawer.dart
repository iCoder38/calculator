// custom_drawer.dart
// import 'dart:convert';

import 'package:calculator/Classes/Screens/upgrade_now/upgrade_now.dart';
import 'package:calculator/Classes/Utils/resources.dart';
import 'package:calculator/Classes/Utils/reusable/resuable.dart';
import 'package:calculator/Classes/Utils/utils.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  //
  String loginUserName = '';
  String loginUserAddress = '';
  var displayProfilePicture = '';
  bool isSubscribed = false;
  bool isScreenLoader = true;

  @override
  void initState() {
    //
    getValue();
    super.initState();
  }

  getValue() async {
    bool isLoggedIn = await getBoolSecurely('isSubscribed');
    customLog("🔍 Retrieved: isLoggedIn = $isLoggedIn");
    if (isLoggedIn) {
      isSubscribed = true;
      setState(() {
        isScreenLoader = false;
      });
    } else {
      setState(() {
        isScreenLoader = false;
      });
    }
  }

  Future<bool> getBoolSecurely(String key) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    String? value = await storage.read(key: key);
    return value == "true";
  }

  /*Future<Map<String, dynamic>?> getLoginResponse() async {
    final storage = FlutterSecureStorage();
    String? jsonString =
        await storage.read(key: AppResources.text.textSaveLoginResponseKey);
    if (jsonString != null) {
      // Decode the JSON string into a Map
      return jsonDecode(jsonString);
    }
    return null; // Return null if no data is found
  }*/

  /*localData() async {
    debugPrint('== LOCAL DATA ==');
    Map<String, dynamic>? loginData = await getLoginResponse();
    if (loginData != null) {
      // print("Login Data Retrieved: $loginData");
      customLog(loginData);
      loginUserName = loginData['data']['firstName'].toString();
      loginUserAddress = loginData['data']['address'].toString();
      setState(() {});
    } else {
      if (kDebugMode) {
        print("No login data found.");
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor().kBlack,
      child: isScreenLoader == true ? SizedBox() : _UIKit(context),
      // _UIKit(context),
    );
  }

  /*Container _UIBGImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppResources.colors.appNavigationColor,
      child: _UIKit(context),
    );
  }*/

  // ignore: non_constant_identifier_names
  Widget _UIKit(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 60),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(AppImage().kAppLogo),
              ),
            ),
          ),
          isSubscribed
              ? SizedBox()
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomBannerButton(
                  text: 'Upgrade to ads free'.toUpperCase(),
                  textSize: 18.0,
                  bgColor: AppColor().kBlue,
                ),
              ),

          buildListTile(title: "Zero ads", icon: Icons.check, onTap: () {}),
          buildListTile(
            title: "Edit incognito URL",
            icon: Icons.check,
            onTap: () {
              /*Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );*/
            },
          ),
          buildListTile(
            title: "Photo math for solving equations",
            icon: Icons.check,
            onTap: () {
              /*Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );*/
            },
          ),
          SizedBox(height: 8),
          isSubscribed
              ? SizedBox()
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomBannerButton(
                  text: 'UPGRADE NOW',
                  textSize: 18.0,
                  bgColor: Colors.blue,
                  bgImage: AppImage().kPrimaryYellowImage,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionTestScreen(),
                      ),
                    );
                  },
                ),
              ),

          isSubscribed
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomBannerButton(
                  text: 'EDIT URL',
                  textSize: 18.0,
                  bgColor: Colors.blue,
                  bgImage: AppImage().kPrimaryBlueImage,
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomBannerButton(
                  text: 'EDIT URL',
                  textSize: 18.0,
                  bgColor: Colors.blue,
                  bgImage: AppImage().kPrimaryBlueImage,

                  iconImage: "assets/images/lock@3x.png",
                ),
              ),
          isSubscribed
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomBannerButton(
                  text: 'PHOTO MATH',
                  textSize: 18.0,
                  bgColor: Colors.blue,
                  bgImage: AppImage().kPrimaryBlueImage,
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomBannerButton(
                  text: 'PHOTO MATH',
                  textSize: 18.0,
                  bgColor: Colors.blue,
                  bgImage: AppImage().kPrimaryBlueImage,
                  iconImage: "assets/images/lock@3x.png",
                ),
              ),
          Row(
            children: [
              SizedBox(width: 20),
              customText(
                'About',
                22.0,
                context,
                lightModeColor: AppColor().kWhite,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 20),
              customText(
                'Incognito calculator',
                14.0,
                context,
                lightModeColor: AppColor().kWhite,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: customText(
                  'hi@incognitocalculator.com',
                  14.0,
                  context,
                  lightModeColor: AppColor().kWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 20),
              customText(
                'Call: 1-88-471-5624',
                14.0,
                context,
                lightModeColor: AppColor().kWhite,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          /*customText(
            'v ${AppVersion().appVersion} (${AppVersion().appBuild})',
            12.0,
            context,
            lightModeColor: Colors.grey,
          ),*/
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.yellow, size: 18.0),
      title: customText(
        title,
        16.0,
        context,
        fontWeight: FontWeight.w600,
        lightModeColor: AppColor().kWhite,
      ),
      onTap: onTap,
    );
  }

  void showLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Delete account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Your account will be deleted account permanently.',
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
