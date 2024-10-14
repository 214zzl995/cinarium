import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../util/port_util.dart';
import '../../root/controllers/root_controller.dart';
import '../controllers/settings_controller.dart';

class PortSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.select((value) => value);
    return Row(
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
                  child: Text(
                    'Port',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            )),
        const SizedBox(width: 20),
        Selector<RootController, bool>(
            builder: (selectorContext, httpRunning, __) => TextButton(
                  onPressed: httpRunning
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (buildContext) {
                              var port = context
                                  .read<SettingsController>()
                                  .httpConfig
                                  .port;
                              final textEditingController =
                                  TextEditingController();

                              textEditingController.text = port.toString();

                              ValueNotifier<String> errorText =
                                  ValueNotifier('Please input 0-65535');

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
                                  errorText.value = 'Please input 0-65535';
                                  return true;
                                }
                              }

                              return AlertDialog(
                                title: const Text('Port'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: errorText,
                                      builder: (context, value, child) {
                                        return Text(value);
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TextField(
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]')),
                                        LengthLimitingTextInputFormatter(5),
                                      ],
                                      controller: textEditingController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: 'Port',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        checkPort(value);
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
                                      checkPort(port.toString()).then((ok) {
                                        if (ok) {
                                          context
                                              .read<SettingsController>()
                                              .changePort(int.parse(
                                                  textEditingController.text));
                                          Navigator.of(buildContext).pop();
                                        }
                                      });
                                    },
                                    child: const Text('OK'),
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
            selector: (_, controller) => controller.httpStatus),
        // SizedBox(
        //   width: 80,
        //   child: Selector<RootController, bool>(
        //       builder: (selectorContext, httpRunning, __) {
        //         return TextField(
        //           inputFormatters: [
        //             FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        //             LengthLimitingTextInputFormatter(5),
        //           ],
        //           focusNode: _focusNode,
        //           enabled: !httpRunning,
        //           controller: _textEditingController,
        //           keyboardType: TextInputType.number,
        //           decoration: InputDecoration(
        //             hintText: 'Port',
        //             border: const OutlineInputBorder(),
        //             hintStyle: TextStyle(
        //               color: Theme.of(context).colorScheme.onSurfaceVariant,
        //             ),
        //           ),
        //           onChanged: (value) {
        //             checkPort(value);
        //           },
        //         );
        //       },
        //       selector: (_, controller) => controller.httpStatus),
        // ),
      ],
    );
  }
}
