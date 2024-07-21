import 'package:bridge/call_rust/native.dart';
import 'package:bridge/call_rust/native/system_api.dart';
import 'package:flutter/cupertino.dart';

class HttpController with ChangeNotifier {
  late ListenerHandle _listenerHandle;

  late bool _httpStatus;

  bool _switchLoading = false;

  HttpController() {
    try {
      _httpStatus = getHttpStatus();
    } catch (e) {
      debugPrint("Http Status Error: $e");
      _httpStatus = false;
    }

    initListener();
    updateIp();
  }

  void initListener() async {
    _listenerHandle = await listenerHttpStatus(
        dartCallback: (status) => {
              _switchLoading = false,
              _httpStatus = status,
              notifyListeners(),
            });
  }

  void switchHttp() async {
    if (_switchLoading) return;

    _switchLoading = true;
    if (_httpStatus) {
      await stopWebApi();
    } else {
      await runWebApi();
    }
  }

  void updateIp() {
    _localIp = getLocalIp();
    notifyListeners();
  }

  @override
  void dispose() {
    _listenerHandle.cancel();
    super.dispose();
  }

  String _localIp = "";

  bool get httpStatus => _httpStatus;

  String get localIp => _localIp;
}
