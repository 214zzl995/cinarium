import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/home/controllers/home_controller.dart';

class SizeFilterEdits extends StatefulWidget {
  const SizeFilterEdits({super.key});

  @override
  SizeFilterEditsState createState() => SizeFilterEditsState();
}

class SizeFilterEditsState extends State<SizeFilterEdits> {
  final TextEditingController _minEditingController = TextEditingController();
  final TextEditingController _maxEditingController = TextEditingController();

  @override
  void initState() {
    final min = context.read<HomeController>().sizeFilter.$1;
    final max = context.read<HomeController>().sizeFilter.$2;
    _minEditingController.text = min == null ? "" : min.toString();
    _maxEditingController.text = max == null ? "" : max.toString();

    super.initState();
  }

  @override
  void dispose() {
    _minEditingController.dispose();
    _maxEditingController.dispose();
    super.dispose();
  }

  void _onSizeFilterChanged() {
    final min = _minEditingController.text.isEmpty
        ? null
        : BigInt.from(
            (double.parse(_minEditingController.text) * 1073741824).toInt());

    final max = _maxEditingController.text.isEmpty
        ? null
        : BigInt.from(
            (double.parse(_maxEditingController.text) * 1073741824).toInt());

    context.read<HomeController>().addSizeFilter(min, max);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 200,
          padding:
              const EdgeInsets.only(top: 20, right: 10, left: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: TextField(
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                  controller: _minEditingController,
                  cursorOpacityAnimates: true,
                  cursorWidth: 3,
                  cursorHeight: 20,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                        left: 10,
                      ),
                      border: const OutlineInputBorder(),
                      label: Text('Min',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 13))),
                  onChanged: (_) {
                    _onSizeFilterChanged();
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _maxEditingController,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    cursorOpacityAnimates: true,
                    cursorWidth: 3,
                    cursorHeight: 20,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5),
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                        left: 10,
                      ),
                      border: const OutlineInputBorder(),
                      label: Text('Max',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                    onChanged: (_) {
                      _onSizeFilterChanged();
                    },
                  )),
            ],
          ),
        ),
        Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            padding: const EdgeInsets.all(10),
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "(GB)",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<HomeController>()
                            .addSizeFilter(0 as BigInt, 0 as BigInt);
                        _minEditingController.text = "";
                        _maxEditingController.text = "";
                      },
                      child: const Text('Clear')),
                )
              ],
            )),
      ],
    );
  }
}
