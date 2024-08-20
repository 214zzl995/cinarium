import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

class ThreadField extends StatefulWidget {
  const ThreadField({super.key});

  @override
  ThreadFieldState createState() => ThreadFieldState();
}

class ThreadFieldState extends State<ThreadField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  Timer? _clearErrorTimer;

  String _errorText = '';

  @override
  void initState() {
    _textEditingController.text =
        context.read<SettingsController>().taskConfig.thread.toString();
    _focusNode.addListener(_handleFocusChange);
    resetTimer();
    super.initState();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    } else {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
      checkThread(_textEditingController.text);
      if (_errorText != '') {
        _textEditingController.text =
            context.read<SettingsController>().taskConfig.thread.toString();

        setState(() {
          _errorText = '';
        });
      } else {
        context.read<SettingsController>().changeThread(
            _textEditingController.text == ''
                ? 1 as BigInt
                : BigInt.parse(_textEditingController.text));
        setState(() {
          _errorText = '';
        });
      }
    }
    resetTimer();
  }

  void resetTimer() {
    if (_clearErrorTimer != null && _clearErrorTimer!.isActive) {
      _clearErrorTimer!.cancel();
    }
    _clearErrorTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _errorText = '';
      });
    });
  }

  checkThread(String thread) async {
    var error = "";

    if (thread.isEmpty) {
      error = "Thread is required";
    } else {
      var threadInt = int.tryParse(thread);
      if (threadInt == null) {
        error = "Thread must be a number";
      } else if (threadInt < 1) {
        error = "Thread must be greater than 0";
      } else if (threadInt > 8) {
        error = "Thread must be less than 8";
      }
    }
    setState(() {
      _errorText = error;
    });
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
    _clearErrorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'ThreadCount',
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
          child: TextField(
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(1),
            ],
            focusNode: _focusNode,
            controller: _textEditingController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                isDense: true,
                contentPadding:
                const EdgeInsets.only(
                  left: 10,
                ),
                border: const OutlineInputBorder(),
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _buildSuffixIcon(context)),
            onChanged: checkThread,
          ),
        )
      ],
    );
  }

  Widget _buildSuffixIcon(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 30,
          height: 22,
          child: TextButton(
            onPressed: () async {
              if (_focusNode.hasFocus) {
                _focusNode.unfocus();
              }
              final nowThread = int.parse(_textEditingController.text);

              if (nowThread < 8) {
                setState(() {
                  _textEditingController.text =
                      (int.parse(_textEditingController.text) + 1).toString();
                  _errorText = '';
                });
                context.read<SettingsController>().changeThread(
                    _textEditingController.text == ''
                        ? 1 as BigInt
                        : BigInt.parse(_textEditingController.text));
              } else {
                setState(() {
                  _errorText = 'Max thread is 8';
                });

                resetTimer();
              }
            },
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                const EdgeInsets.all(0),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
            child: const Icon(Icons.arrow_drop_up_outlined),
          ),
        ),
        SizedBox(
          width: 30,
          height: 22,
          child: TextButton(
            onPressed: () async {
              if (_focusNode.hasFocus) {
                _focusNode.unfocus();
              }
              final nowThread = int.parse(_textEditingController.text);
              if (nowThread > 1) {
                setState(() {
                  _textEditingController.text =
                      (int.parse(_textEditingController.text) - 1).toString();
                  _errorText = '';
                });
                context.read<SettingsController>().changeThread(
                    _textEditingController.text == ''
                        ? 1 as BigInt
                        : BigInt.parse(_textEditingController.text));
              } else {
                setState(() {
                  _errorText = 'Min thread is 1';
                });
                resetTimer();
              }
            },
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                const EdgeInsets.all(0),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
            child: const Icon(Icons.arrow_drop_down_outlined),
          ),
        )
      ],
    );
  }
}
