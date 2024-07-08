import 'package:flutter/cupertino.dart';
import 'package:native_interface/native_listener.dart';
import 'package:native_interface/proto/hfs_msg.pb.dart';

class DebugController
    with ChangeNotifier, HfsNativeListener, PoolNativeListener {
  //TODO: Implement SettingsController

  DebugController() {
    registerHfs();
    registerPool();
  }

  @override
  void dispose() {
    unregisterHfs();
    unregisterPool();
    super.dispose();
  }

  late var count = 0;

  late var hfsStatus = HfsStatus.Stop;

  void increment() {
    count++;
    notifyListeners();
  }

  @override
  void onHfsStatusChange(HfsStatusChangeMsg hfsStatusMsg) {
    hfsStatus = hfsStatusMsg.status;
    notifyListeners();
  }
}
