import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/home/controllers/home_controller.dart';

class DurationFilterEdits extends StatefulWidget {
  const DurationFilterEdits({super.key});

  @override
  DurationFilterEditsState createState() => DurationFilterEditsState();
}

class DurationFilterEditsState extends State<DurationFilterEdits> {
  final TextEditingController _minEditingController = TextEditingController();
  final TextEditingController _maxEditingController = TextEditingController();

  @override
  void initState() {
    final min = context.read<HomeController>().durationFilter.$1;
    final max = context.read<HomeController>().durationFilter.$2;
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

  void _onDurationFilterChanged() {
    final min = _minEditingController.text.isEmpty
        ? null
        : int.parse(_minEditingController.text);
    final max = _maxEditingController.text.isEmpty
        ? null
        : int.parse(_maxEditingController.text);

    context.read<HomeController>().addDurationFilter(min, max);
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
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  keyboardType: TextInputType.number,
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
                    _onDurationFilterChanged();
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
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    keyboardType: TextInputType.number,
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
                      _onDurationFilterChanged();
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
            child: SizedBox(
              width: 90,
              child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<HomeController>()
                        .addDurationFilter(null, null);
                    _minEditingController.text = "";
                    _maxEditingController.text = "";
                  },
                  child: const Text('Clear')),
            )),
      ],
    );
  }
}
