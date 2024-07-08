import 'package:flutter/cupertino.dart';
import 'package:native_interface/native_listener.dart';
import 'package:native_interface/proto/hfs_msg.pb.dart';
import 'package:cinarium/ffi/ffi.io.dart';

class HfsController with ChangeNotifier, HfsNativeListener {
  //TODO: Implement SettingsController

  HfsController() {
    registerHfs();
    init();
  }

  void init() async {
    _hfsStatus = await systemApi.getHfsStatus() ? HfsStatus.Running : HfsStatus.Stop;
    updateIp();
    notifyListeners();
  }
  
  void updateIp() async {
    _localIp = await systemApi.getLocalIp();
    notifyListeners();
  }

  @override
  void dispose() {
    unregisterHfs();
    super.dispose();
  }

  HfsStatus _hfsStatus = HfsStatus.Stop;

  String _localIp = "";

  @override
  void onHfsStatusChange(HfsStatusChangeMsg hfsStatusMsg) {
    _hfsStatus = hfsStatusMsg.status;
    notifyListeners();
  }

  HfsStatus get hfsStatus => _hfsStatus;

  String get localIp => _localIp;
}
