import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveHelper {
  static bool isPortrait(BuildContext context) {
    return ScreenUtil().orientation == Orientation.portrait;
  }

  static double responsiveWidth(double value) {
    return value.w; // menyesuaikan dengan lebar layar
  }

  static double responsiveHeight(double value) {
    return value.h; // menyesuaikan dengan tinggi layar
  }

  static double responsiveFont(double value) {
    return value.sp; // scaling font
  }
}
