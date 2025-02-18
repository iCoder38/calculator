import 'dart:io';

import 'package:calculator/Classes/Utils/drawer.dart';
import 'package:calculator/Classes/Utils/resources.dart';
import 'package:calculator/Classes/Utils/reusable/resuable.dart';
import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MathsScreen extends StatefulWidget {
  const MathsScreen({super.key});

  @override
  State<MathsScreen> createState() => _MathsScreenState();
}

class _MathsScreenState extends State<MathsScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // file
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: customText(
          AppText().kScanQuestion,
          16.0,
          context,
          lightModeColor: AppColor().kWhite,
        ),
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
      body: _UIKit(context),
    );
  }

  Widget _UIKit(context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomBannerButton(
            text: '',
            height: 280,
            textSize: 16.0,
            bgColor: Colors.transparent,
            bgImage: AppImage().kPrimaryBlueImage,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  _image == null
                      ? Image.asset(AppImage().kAppLogo, fit: BoxFit.contain)
                      : Image.file(
                        _image!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
            ),
          ),
        ),

        Spacer(),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomBannerButton(
                  text: 'Gallery',
                  textSize: 16.0,
                  bgColor: Colors.blue,
                  bgImage: AppImage().kPrimaryBlueImage,
                  onPressed: () {
                    _pickImage(context);
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomBannerButton(
                  text: 'Camera',
                  textSize: 16.0,
                  bgColor: Colors.blue,
                  bgImage: AppImage().kPrimaryYellowImage,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    // Pick an image from the gallery
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Store the selected image in _image
      });
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }
}
