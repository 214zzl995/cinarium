import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/hfs_controller.dart';

class ServeIpBar extends StatelessWidget {
  const ServeIpBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildFlag(context),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
        Expanded(
          child: Container(),
        ),
        AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildQrPanel(context),
            transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                )),
      ],
    );
  }

  Widget _buildFlag(BuildContext context) {
    return Container(
        width: 100,
        alignment: Alignment.centerLeft,
        key: ValueKey<bool>(context.watch<HfsController>().httpStatus),
        child: Text(
          context.watch<HfsController>().httpStatus ? 'Running' : 'Stopped',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  Widget _buildQrPanel(BuildContext context) {
    return context.watch<HfsController>().httpStatus
        ? Center(
            child: Row(children: [
              _buildCopyButton(context),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                height: 30,
                child: TextButton(
                  onPressed: () {
                    final localIp = context.read<HfsController>().localIp;
                    _qrClick(
                        context,
                        localIp,
                        Theme.of(context).colorScheme.onSurface,
                        Theme.of(context).colorScheme.outline);
                  },
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        // Change your radius here
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    padding: WidgetStateProperty.all(const EdgeInsets.all(2)),
                  ),
                  child: const Icon(Icons.qr_code),
                ),
              ),
            ]),
          )
        : Container();
  }

  Widget _buildCopyButton(BuildContext context) {
    final ValueNotifier<bool> copy = ValueNotifier<bool>(false);
    return SizedBox(
      height: 30,
      child: TextButton(
          onPressed: () {
            FlutterClipboard.copy(context.read<HfsController>().localIp)
                .then((value) {
              copy.value = true;
              Future.delayed(const Duration(milliseconds: 2000), () {
                copy.value = false;
              });
            });
          },
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          child: Row(
            children: [
              ValueListenableBuilder<bool>(
                  valueListenable: copy,
                  builder: (context, value, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: value
                          ? const Icon(
                              key: ValueKey<String>('done'),
                              Icons.done,
                              size: 20)
                          : const Icon(
                              key: ValueKey<String>('copy'),
                              Icons.copy,
                              size: 20),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    );
                  }),
              const SizedBox(
                width: 5,
              ),
              Text(context.watch<HfsController>().localIp)
            ],
          )),
    );
  }

  Future _qrClick(BuildContext context, String localIp, Color primaryColor,
      Color dataModuleColor) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          content: Container(
              width: 280,
              height: 280,
              alignment: Alignment.center,
              child: QrImageView(
                data: localIp,
                version: 3,
                padding: const EdgeInsets.all(20),
                size: 500,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: primaryColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: dataModuleColor,
                ),
              )),
        );
      },
    );
  }
}
