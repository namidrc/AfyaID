import 'package:flutter/material.dart';

class PatientProvider extends ChangeNotifier {
  void recharge(dynamic widget) {
    widget = widget;
    notifyListeners();
  }
}
