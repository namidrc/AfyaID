import 'package:flutter/material.dart';

class SizeUtil {
  static double sizeHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double sizeWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static Widget heightGap(double size) => SizedBox(height: size);

  static Widget widthGap(double size) => SizedBox(width: size);
}
