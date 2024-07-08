import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controllers/retrieve_controller.dart';
import 'file_col.dart';

class CrawlNameField extends StatefulWidget {
  const CrawlNameField(this.index, {super.key});

  final int index;

  @override
  CrawlNameFieldState createState() => CrawlNameFieldState();
}

class CrawlNameFieldState extends State<CrawlNameField> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showConfirmButton = false;

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final crawlName =
        context.read<RetrieveController>().showFiles[widget.index].crawlName;
    _textEditingController.text = crawlName;

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant CrawlNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final crawlName =
        context.read<RetrieveController>().showFiles[widget.index].crawlName;
    _textEditingController.text = crawlName;
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    } else {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        checkCrawlName(context);
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        closeCrawlName(context);
      }
    }
    return true;
  }

  void _onTextChanged(String value) {
    if (value !=
        context.read<RetrieveController>().showFiles[widget.index].crawlName) {
      setState(() {
        _showConfirmButton = true;
      });
    } else {
      setState(() {
        _showConfirmButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /*final crawlName =
        context.read<RetrieveController>().showFiles[widget.index].crawlName;
    _textEditingController.text = crawlName;*/
    return FileCol(
        flex: 1,
        value: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 40,
                child: TextField(
                    cursorHeight: 22,
                    cursorWidth: 3,
                    focusNode: _focusNode,
                    style: const TextStyle(fontSize: 14),
                    controller: _textEditingController,
                    onChanged: _onTextChanged,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                        left: 10,
                      ),
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 0,
                        ),
                      ),
                      suffixIcon: _buildAction(context),
                    )))
          ],
        ));
  }

  Widget _buildAction(BuildContext context) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _showConfirmButton
            ? Row(
                key: const Key('change'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                      () => checkCrawlName(context),
                      const Icon(
                        Icons.check,
                      )),
                  _buildActionButton(
                      () => closeCrawlName(context),
                      const Icon(
                        Icons.close,
                      )),
                ],
              )
            : const SizedBox(key: Key('unChange'), width: 0, height: 0));
  }

  final _actionButtonStyle = ButtonStyle(
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        // Change your radius here
        borderRadius: BorderRadius.circular(0),
      ),
    ),
    iconSize: WidgetStateProperty.all(20),
    padding: WidgetStateProperty.all(const EdgeInsets.all(2)),
  );

  Widget _buildActionButton(VoidCallback onPressed, Widget child) {
    return SizedBox(
        width: 42,
        height: 40,
        child: TextButton(
            onPressed: onPressed, style: _actionButtonStyle, child: child));
  }

  void checkCrawlName(BuildContext context) {
    context.read<RetrieveController>().changeCrawlName(
        context.read<RetrieveController>().showFiles[widget.index].id,
        _textEditingController.text);
    setState(() {
      _showConfirmButton = false;
      _focusNode.unfocus();
    });
  }

  void closeCrawlName(BuildContext context) {
    _textEditingController.text =
        context.read<RetrieveController>().showFiles[widget.index].crawlName;
    setState(() {
      _showConfirmButton = false;
      _focusNode.unfocus();
    });
  }
}
