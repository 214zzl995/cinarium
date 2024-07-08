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
  @override
  void initState() {
    final min = context.read<HomeController>().durationFilter.min;
    final max = context.read<HomeController>().durationFilter.max;
    _minEditingController.text = min == 0 ? "" : min.toString();
    _maxEditingController.text = max == 0 ? "" : max.toString();

    super.initState();
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
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context.read<HomeController>().addDurationFilter(0, null);
                      return;
                    }
                    context
                        .read<HomeController>()
                        .addDurationFilter(int.parse(value), null);
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
                    onChanged: (value) {
                      if (value.isEmpty) {
                        context
                            .read<HomeController>()
                            .addDurationFilter(null, 0);
                        return;
                      }
                      context
                          .read<HomeController>()
                          .addDurationFilter(null, int.parse(value));
                    },
                  )),
            ],
          ),
        ),
        Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            padding: const EdgeInsets.all(10),
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 90,
              child: ElevatedButton(
                  onPressed: () {
                    context.read<HomeController>().addDurationFilter(0, 0);
                    _minEditingController.text = "";
                    _maxEditingController.text = "";
                  },
                  child: const Text('Clear')),
            )),
      ],
    );
  }
}
