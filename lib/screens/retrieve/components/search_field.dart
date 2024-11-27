import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../controllers/retrieve_controller.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  SearchFieldState createState() => SearchFieldState();
}

class SearchFieldState extends State<SearchField> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _showClearButton = false;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final searchText = context.read<RetrieveController>().textFilter;
    _textEditingController.text = searchText;
    if (searchText.isNotEmpty) {
      _showClearButton = true;
    }
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = _textEditingController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 35,
      child: TextField(
        controller: _textEditingController,
        cursorHeight: 22,
        cursorWidth: 2,
        autofocus: context.read<RetrieveController>().textFilter != "",
        cursorOpacityAnimates: true,
        style: const TextStyle(
          fontSize: 14,
        ),
        onChanged: (value) {
          context.read<RetrieveController>().textFilter = value;
          _onTextChanged();
        },
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(
              left: 10,
            ),
            border: const OutlineInputBorder(),
            label: Text(
              '',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
            suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _showClearButton
                    ? TextButton(
                        key: const Key('clearButton'),
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              // Change your radius here
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _textEditingController.clear();
                            _onTextChanged();
                            context.read<RetrieveController>().textFilter = '';
                          });
                        },
                        child: const Icon(Symbols.clear),
                      )
                    : const SizedBox(
                        key: Key('emptyContainer'),
                        width: 0,
                        height: 0,
                      ),
                transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    )),
            prefixIcon: Icon(
              Symbols.search,
              color: Theme.of(context).colorScheme.primary,
            )),
      ),
    );
  }
}
