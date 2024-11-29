import 'package:bridge/call_rust/native/system_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/root/controllers/root_controller.dart';

import '../../../util/port_util.dart';
import '../controllers/settings_controller.dart';

class HttpPortSetting extends StatelessWidget {
  const HttpPortSetting({super.key});

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
            _buildPortField(context),
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
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                            key: const Key("httpRunning"),
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                    "The http file server is running and cannot be modified",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        )),
                                const SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                    onPressed: () {
                                      stopWebApi();
                                    },
                                    child: const Text("Stop Http File Server"))
                              ],
                            )),
                      )
                    : Container(
                        key: const Key("httpNotRunning"),
                      ),
              );
            },
            selector: (_, controller) => controller.httpStatus),
      ],
    );
  }

  Widget _buildPortField(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Row(
                children: [
                  Icon(
                    Symbols.wifi_tethering,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    weight: 300,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Selector<SettingsController, int>(
                          selector: (_, controller) =>
                              controller.httpConfig.port,
                          builder: (_, port, __) => Text(
                            'Port: $port',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          'The port number of the http file server',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          const SizedBox(width: 20),
          SizedBox(
            height: 25,
            child: _buildEditButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Selector<RootController, bool>(
        builder: (selectorContext, httpRunning, __) => TextButton(
              onPressed: httpRunning
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (buildContext) {
                          final textEditingController = TextEditingController();

                          textEditingController.text = context
                              .read<SettingsController>()
                              .httpConfig
                              .port
                              .toString();

                          ValueNotifier<String> errorText = ValueNotifier('');

                          Future<bool> checkPort(String port) async {
                            if (port == '') {
                              errorText.value = 'Port is empty';
                              return false;
                            } else {
                              if (int.parse(port) < 0 ||
                                  int.parse(port) > 65535) {
                                errorText.value =
                                    'Port is invalid,Please input 0-65535';
                                return false;
                              } else {
                                if (await isPortInUse(int.parse(port))) {
                                  errorText.value = 'Port is in use';
                                  return false;
                                }
                              }
                              errorText.value = '';
                              return true;
                            }
                          }

                          submitPort() {
                            final port = textEditingController.text;
                            checkPort(port).then((ok) {
                              if (ok) {
                                if (context.mounted) {
                                  context
                                      .read<SettingsController>()
                                      .changePort(int.parse(port));
                                  Navigator.of(buildContext).pop();
                                }
                              }
                            });
                          }

                          return AlertDialog(
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceContainer,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Http File Server Port',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                    'Please input the port number of the http file server',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 13,
                                    )),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ValueListenableBuilder(
                                    valueListenable: errorText,
                                    builder: (context, value, child) {
                                      return TextField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                            LengthLimitingTextInputFormatter(5),
                                          ],
                                          autofocus: true,
                                          controller: textEditingController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            hintText: 'Port',
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            checkPort(value);
                                          },
                                          onSubmitted: (_) {
                                            submitPort();
                                          });
                                    }),
                                ValueListenableBuilder(
                                  valueListenable: errorText,
                                  builder: (context, value, child) {
                                    return Text(value,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          fontSize: 13,
                                        ));
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(buildContext).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  submitPort();
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
              child: const Icon(
                Symbols.open_in_new,
                size: 20,
              ),
            ),
        selector: (_, controller) => controller.httpStatus);
  }

  /// 构建连接选项
  ///  1. 无控制 所有连接都允许
  ///  2. 服务端控制 连入后需要服务端确认
  ///  3. 密钥 连入需要密钥
  Widget _buildConnectionOptions(BuildContext context) {
    return Container();
  }
}
