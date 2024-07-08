import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ffi/ffi.io.dart';
import '../controllers/debug_controller.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => DebugController(),
        builder: (context, _) {
          return Scaffold(
            body: Column(children: [
              Row(
                children: [
                  const Text("系统api测试:"),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () => systemApi.appInit(),
                    child: const Text("App初始化"),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () => systemApi.initAppLog(),
                    child: const Text("初始化用户日志"),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () => systemApi.initDb(),
                    child: const Text("初始化数据库"),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text("系统HFSapi测试:"),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () => systemApi.runHfs(),
                    child: const Text("启动hfs"),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () => {systemApi.stopHfs()},
                    child: const Text("停止hfs"),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                      "当前hfs运行情况:${context.watch<DebugController>().hfsStatus}"),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text("多窗口测试:"),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final window =
                          await DesktopMultiWindow.createWindow(jsonEncode({
                        'args1': 'Sub window',
                        'args2': 100,
                        'args3': true,
                        'bussiness': 'bussiness_test',
                      }));
                      window
                        ..setFrame(const Offset(0, 0) & const Size(1280, 720))
                        ..center()
                        ..setTitle('Another window')
                        ..show();
                    },
                    child: const Text("打开新界面"),
                  ),
                ],
              )
            ]),
          );
        });
  }
}
