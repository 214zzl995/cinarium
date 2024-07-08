import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../util/port_util.dart';
import '../../root/controllers/root_controller.dart';
import '../controllers/settings_controller.dart';

class PortField extends StatefulWidget {
  const PortField({super.key});

  @override
  PortFieldState createState() => PortFieldState();
}

class PortFieldState extends State<PortField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();

  String _errorText = '';

  @override
  void initState() {
    _textEditingController.text =
        context.read<SettingsController>().httpConfig.port.toString();
    _focusNode.addListener(_handleFocusChange);
    super.initState();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    } else {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
      if (_errorText != '') {
        _textEditingController.text =
            context.read<SettingsController>().httpConfig.port.toString();
        setState(() {
          _errorText = '';
        });
      } else {
        context.read<SettingsController>().changePort(
            _textEditingController.text == ''
                ? 80
                : int.parse(_textEditingController.text));
      }
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _focusNode.unfocus();
      }
    }
    return true;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  checkPort(String port) async {
    var error = "";
    if (port == '') {
      error = 'Port is empty';
    } else {
      if (int.parse(port) < 0 || int.parse(port) > 65535) {
        error = 'Port is invalid,Please input 0-65535';
      } else {
        if (await isPortInUse(int.parse(port))) {
          error = 'Port is in use';
        }
      }
    }
    setState(() {
      _errorText = error;
    });
  }

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
                  Icons.wifi_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            key: ValueKey(_errorText),
            width: 500,
            child: Text(_errorText,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.red)),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 80,
          child: Selector<RootController, bool>(
              builder: (selectorContext, httpRunning, __) {
                return TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(5),
                  ],
                  focusNode: _focusNode,
                  enabled: !httpRunning,
                  controller: _textEditingController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Port',
                    border: const OutlineInputBorder(),
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onChanged: (value) {
                    checkPort(value);
                  },
                );
              },
              selector: (_, controller) => controller.httpStatus),
        ),
      ],
    );
  }
}
