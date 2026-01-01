import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/constants/font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;
  final double? letterSpacing;
  final double? height;
  final int? maxLines;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextOverflow? overflow; // ✅ tambahan

  const CustomText(
    this.text, {
    super.key,
    this.color,
    this.fontSize = FontSizes.smallMedium,
    this.fontWeight,
    this.height,
    this.letterSpacing,
    this.fontFamily,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  const CustomText.title(
    this.text, {
    super.key,
    this.color,
    this.fontSize = FontSizes.base,
    this.fontWeight = FontWeight.w700,
    this.height,
    this.letterSpacing,
    this.fontFamily,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  const CustomText.subtitle(
    this.text, {
    super.key,
    this.color,
    this.fontSize = FontSizes.small,
    this.fontWeight,
    this.height,
    this.letterSpacing,
    this.fontFamily,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  const CustomText.small(
    this.text, {
    super.key,
    this.color,
    this.fontSize = FontSizes.superSmall,
    this.fontWeight,
    this.height,
    this.letterSpacing,
    this.fontFamily,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor =
        color ?? (Get.isDarkMode ? MasterColor.white : MasterColor.dark);

    return Text(
      text.tr,
      style: TextStyle(
        fontSize: fontSize,
        color: defaultColor,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        fontFamily: fontFamily,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow, // ✅ pasang disini
    );
  }
}

class CustomTranslatedText extends StatelessWidget {
  final String textEn;
  final String textAr;
  final Color? color;
  final double? fontSize;
  final double? letterSpacing;
  final double? height;
  final int? maxLines;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextOverflow? overflow; // ✅ tambahan

  const CustomTranslatedText({
    required this.textEn,
    required this.textAr,
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.letterSpacing,
    this.fontFamily,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor =
        color ?? (Get.isDarkMode ? MasterColor.white : MasterColor.dark);

    return Text(
      Get.locale?.languageCode == 'en' ? textEn : textAr,
      style: TextStyle(
        fontSize: fontSize,
        color: defaultColor,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        fontFamily: fontFamily,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow, // ✅ pasang disini juga
    );
  }
}
