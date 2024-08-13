import 'package:bridge/call_rust/native.dart';
import 'package:bridge/call_rust/native/system_api.dart';
import 'package:flutter/cupertino.dart';

import '../../../routes/app_pages.dart';

class RootController with ChangeNotifier {
  RootController() {
    initListener();
  }

  initListener() async {
    _listenerHandle = await listenerHttpStatus(
        dartCallback: (status) => {
              _httpStatus = status,
              notifyListeners(),
            });
  }

  var _title = "Cinarium";
  late ListenerHandle _listenerHandle;

  bool _httpStatus = false;

  String get title => _title;

  Routes _route = Routes.home;

  Routes get route => _route;

  bool get httpStatus => _httpStatus;

  set route(Routes route) {
    _route = route;
    notifyListeners();
  }

  set title(String title) {
    _title = title;
    notifyListeners();
  }

  @override
  void dispose() {
    _listenerHandle.cancel();
    super.dispose();
  }
}
