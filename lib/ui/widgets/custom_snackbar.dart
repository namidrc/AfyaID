import 'package:flutter/material.dart';

import '../../domain/domain.dart';

void snackbarMessage(BuildContext context, {String text = "Error occurred!"}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: AdaptiveUtil.isNarrow(context)
          ? SnackBarBehavior.floating
          : SnackBarBehavior.fixed,
      content: Text(text),
      showCloseIcon: true,
    ),
  );
}
