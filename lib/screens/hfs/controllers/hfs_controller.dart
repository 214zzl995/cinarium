import 'dart:io';

import 'package:bridge/call_rust/native.dart';
import 'package:bridge/call_rust/native/system_api.dart';
import 'package:flutter/cupertino.dart';

class HfsController with ChangeNotifier {
  late ListenerHandle _listenerHandle;

  HfsController() {
    _listenerHandle = listenerHttpStatus(
        dartCallback: (status) => {
              _httpStatus = status,
              notifyListeners(),
            });
  }

  void updateIp() async {
    _localIp = getLocalIp();
    notifyListeners();
  }

  @override
  void dispose() {
    _listenerHandle.dispose();
    super.dispose();
  }

  bool _httpStatus = getHttpStatus();

  String _localIp = "";

  bool get httpStatus => _httpStatus;

  String get localIp => _localIp;
}
