import 'package:calculator/Classes/Utils/utils.dart';
import 'package:flutter/material.dart';

class CustomBannerButton extends StatelessWidget {
  final String text;
  final double textSize; // Customizable text size
  final String? iconImage; // Optional icon
  final Color bgColor;
  final String? bgImage; // Optional background image

  const CustomBannerButton({
    super.key,
    required this.text,
    this.textSize = 22, // Default text size
    this.iconImage, // Optional
    required this.bgColor,
    this.bgImage, // Optional
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        image:
            bgImage != null
                ? DecorationImage(
                  image: ExactAssetImage(bgImage!),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconImage != null) // Show icon only if provided
            Row(
              children: [
                SizedBox(width: 28, height: 28, child: Image.asset(iconImage!)),
                SizedBox(width: 4), // Space between icon and text
              ],
            ),
          customText(
            text.toUpperCase(),
            textSize, // Dynamic text size
            context,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}
