import 'package:flutter/material.dart';

class NavigationUtils {
  Future<dynamic> pagePush(BuildContext context, dynamic page) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
