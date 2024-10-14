import 'package:bridge/call_rust/native/system_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/root/controllers/root_controller.dart';
import 'package:cinarium/screens/settings/components/port_field.dart';

class HttpSetting extends StatelessWidget {
  const HttpSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(6),
          ),
          border: Border.all(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Column(
              children: [
                PortSetting(),
              ],
            ),
          ],
        ));
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Selector<RootController, bool>(
            builder: (selectorContext, httpRunning, __) {
              return AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: httpRunning
                    ? SizedBox(
                        key: const Key("httpRunning"),
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                                "The http file server is running and cannot be modified",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error)),
                            const SizedBox(
                              width: 10,
                            ),
                            TextButton(
                                onPressed: () {
                                  stopWebApi();
                                },
                                child: const Text("Stop Http File Server"))
                          ],
                        ))
                    : Container(
                        key: const Key("httpNotRunning"),
                      ),
              );
            },
            selector: (_, controller) => controller.httpStatus),
      ],
    );
  }

  /// 构建连接选项
  ///  1. 无控制 所有连接都允许
  ///  2. 服务端控制 连入后需要服务端确认
  ///  3. 密钥 连入需要密钥
  Widget _buildConnectionOptions(BuildContext context) {
    return Container();
  }
}
