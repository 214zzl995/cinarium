import 'package:bridge/call_rust/native/system_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/root/controllers/root_controller.dart';
import 'package:cinarium/screens/settings/components/port_field.dart';

class HfsSetting extends StatelessWidget {
  const HfsSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            const Padding(
              padding: EdgeInsets.only(left: 40),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  PortField(),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Row(
          children: [
            Icon(
              Icons.upload_file_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Http File Server',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        )),
        SizedBox(
          height: 30,
          child: Selector<RootController, bool>(
              builder: (selectorContext, httpRunning, __) {
                if (httpRunning) {
                  return Row(
                    children: [
                      const Text(
                          "The http file server is running and cannot be modified",
                          style: TextStyle(color: Colors.red)),
                      const SizedBox(
                        width: 10,
                      ),
                      TextButton(
                          onPressed: () {
                            stopWebApi();
                          },
                          child: const Text("Stop Http File Server"))
                    ],
                  );
                } else {
                  return Container();
                }
              },
              selector: (_, controller) => controller.httpStatus),
        ),
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
