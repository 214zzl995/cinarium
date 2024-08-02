import 'package:flutter/material.dart';

typedef OnChangedCallback = void Function(int min, int max);

class RangeSliderExample extends StatefulWidget {
  const RangeSliderExample(this.start, this.end,
      {super.key, required this.onChanged});

  final double start;
  final double end;
  final OnChangedCallback onChanged;

  @override
  RangeSliderExampleState createState() => RangeSliderExampleState();
}

class RangeSliderExampleState extends State<RangeSliderExample> {
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    _currentRangeValues = RangeValues(widget.start, widget.end);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          RangeSlider(
            values: _currentRangeValues,
            min: 0,
            max: 100,
            divisions: 100,
            labels: RangeLabels(
              _currentRangeValues.start.round().toString(),
              _currentRangeValues.end.round().toString(),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
                widget.onChanged(_currentRangeValues.start.round(),
                    _currentRangeValues.end.round());
              });
            },
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
                    onPressed: () {}, child: const Text('Clear')),
              )),
        ],
      ),
    );
  }
}
