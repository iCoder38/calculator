// WIDGET
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/web.dart';

final Logger logger = Logger(
  level: kReleaseMode ? Level.off : Level.debug,
  printer: PrettyPrinter(colors: true),
);
void customLog(dynamic message) {
  if (kDebugMode) {
    // print(message);
    logger.d(message);
  }
}

class AppConfig {
  String v = '0.0.1';
  String b = '1';

  AppConfig() {
    if (Platform.isAndroid) {
      v = '1.0.4';
      b = '4';
    } else if (Platform.isIOS) {
      v = '0.0.1';
      b = '8';
    } else {
      v = '0.0.1';
      b = '1';
    }
  }
}

class MathRapidApi {
  String url = "https://photomath1.p.rapidapi.com/maths/v2/solve-problem";
  String key = "b340a5889bmsha51af22247bdf7bp134354jsnb57156d6218c";
}

class InAppProductId {
  late String productId;

  InAppProductId() {
    if (Platform.isAndroid) {
      productId = "ad_free_099";
    } else if (Platform.isIOS) {
      productId = "ad_free_099_v2";
    } else {
      productId = "ad_free_099";
    }
  }
}

/*class InAppProductId {
  String productId = "ad_free_099";
}

void checkPlatform() {
  if (Platform.isAndroid) {
    print("Running on Android");
  } else if (Platform.isIOS) {
    print("Running on iOS");
  } else {
    print("Running on an unsupported platform");
  }
}*/

// FONTS
class FontFamiltyNameUtils {
  var fontOrbitron = 'o';
  var fontPoppins = 'p';
  var fontMont = 'm';
  var headerFont = 'p';
  var subHeaderFont = 'p';
}

Widget customText(
  String text,
  double fontSize,
  BuildContext context, {
  String? fontFamily,
  int? maxLines,
  FontWeight fontWeight = FontWeight.normal,
  Color? darkModeColor, // Optional dark mode color
  Color? lightModeColor, // Optional light mode color
}) {
  return textFont(
    text,
    maxLines,
    lightModeColor ?? Colors.black,
    fontSize,
    fontFamily ?? FontFamiltyNameUtils().fontPoppins,
    fontWeight: fontWeight,
  );
}

// WIDGET FONT
Widget textFont(text, maxLines, color, size, font, {FontWeight? fontWeight}) {
  if (font == 'p') {
    return Text(
      text.toString(),
      style: GoogleFonts.montserrat(
        color: color,
        fontSize: size,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
      maxLines: maxLines ?? 2,
    );
  } else if (font == 'o') {
    return Text(
      text.toString(),
      maxLines: maxLines,
      style: GoogleFonts.orbitron(
        color: color,
        fontSize: size,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  } else if (font == 'I') {
    return Text(
      text.toString(),
      maxLines: maxLines,
      style: GoogleFonts.inter(
        color: color,
        fontSize: size,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  } else {
    return Text(
      maxLines: maxLines,
      text.toString(),
      style: GoogleFonts.poppins(
        color: color,
        fontSize: size,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  }
}
