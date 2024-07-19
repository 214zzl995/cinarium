import 'package:flutter/cupertino.dart';

class DebugController with ChangeNotifier {
  //TODO: Implement SettingsController

  late var count = 0;

  void increment() {
    count++;
    notifyListeners();
  }
}
