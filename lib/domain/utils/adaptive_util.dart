import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AdaptiveUtil {
  static bool get canHover {
    if (kIsWeb) return true; // Le web supporte le hover
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return true; // Desktop supporte le hover
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false; // Mobile ne supporte pas le hover
    }
  }

  static bool isMobile = kIsWeb ? false : Platform.isAndroid || Platform.isIOS;

  static bool isNarrow(BuildContext context) => kIsWeb
      ? isCompact(context)
      : Platform.isAndroid || Platform.isIOS || isCompact(context);

  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isMedium(BuildContext context) =>
      MediaQuery.of(context).size.width > 600 &&
      MediaQuery.of(context).size.width < 840;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.of(context).size.width > 840 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width > 1200 &&
      MediaQuery.of(context).size.width < 1600;

  static bool isExtraLarge(BuildContext context) =>
      MediaQuery.of(context).size.width > 1600;

  static bool isDesktop(BuildContext context) =>
      !isMobile &&
      !kIsWeb &&
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  static bool isWide(BuildContext context) =>
      isExpanded(context) || isLarge(context) || isExtraLarge(context);
}
