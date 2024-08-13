import 'dart:ffi';

import 'package:flutter/material.dart';

typedef OnChangedCallback = void Function(int? min, int? max);

class BilateralRangeSlider extends StatefulWidget {
  const BilateralRangeSlider(this.start, this.end, this.unit,
      {super.key, required this.onChanged});

  final double start;
  final double end;
  final OnChangedCallback onChanged;
  final String unit;

  @override
  BilateralRangeSliderState createState() => BilateralRangeSliderState();
}

class BilateralRangeSliderState extends State<BilateralRangeSlider> {
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    _currentRangeValues = RangeValues(widget.start, widget.end);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.3),
              padding: const EdgeInsets.all(10),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 7, disabledThumbRadius: 7),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 10),
                ),
                child: RangeSlider(
                  values: _currentRangeValues,
                  min: widget.start,
                  max: widget.end,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentRangeValues = values;
                    });
                  },
                  onChangeEnd: (RangeValues values) {
                    final min = values.start.round() == widget.start
                        ? null
                        : values.start.round();

                    final max = values.end.round() == widget.end
                        ? null
                        : values.end.round();

                    widget.onChanged(min, max);
                  },
                ),
              )),
          Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currentRangeValues.start.round() == widget.start &&
                            _currentRangeValues.end == widget.end
                        ? 'All'
                        : "${_currentRangeValues.start.round().toString()} - ${_currentRangeValues.end.round().toString()} ${widget.unit}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentRangeValues = RangeValues(
                            widget.start.toDouble(), widget.end.toDouble());
                      });
                      widget.onChanged(null, null);
                    },
                    child: const Text('Reset'),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
