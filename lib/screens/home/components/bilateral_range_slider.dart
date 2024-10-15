import 'dart:math';

import 'package:flutter/material.dart';

typedef OnChangedCallback = void Function(double? min, double? max);

class BilateralRangeSlider extends StatefulWidget {
  const BilateralRangeSlider(this.start, this.end, this.unit,
      {super.key,
      required this.onChanged,
      this.initStart,
      this.initEnd,
      this.retainDecimals});

  final double start;
  final double end;

  final double? initStart;
  final double? initEnd;

  final int? retainDecimals;

  final OnChangedCallback onChanged;
  final String unit;

  @override
  BilateralRangeSliderState createState() => BilateralRangeSliderState();
}

class BilateralRangeSliderState extends State<BilateralRangeSlider> {
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    _currentRangeValues = RangeValues(
        widget.initStart ?? widget.start, widget.initEnd ?? widget.end);
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
                    final min = values.start== widget.start
                        ? null
                        : values.start;

                    final max = values.end == widget.end
                        ? null
                        : values.end;

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
                    _currentRangeValues.toStringB(widget.unit,
                        widget.retainDecimals, widget.start, widget.end),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentRangeValues = RangeValues(
                            widget.start.toDouble(), widget.end.toDouble());
                      });
                      widget.onChanged(null, null);
                    },
                    label: const Icon(Icons.restart_alt_outlined),
                  )
                ],
              )),
        ],
      ),
    );
  }
}

double roundToNDecimalPlaces(double value, int n) {
  if (n < 0) {
    throw ArgumentError.value(
        n, 'n', 'The number of decimal places cannot be negative.');
  }
  int magnified = (value * pow(10, n)).round();
  return magnified / pow(10, n);
}

extension RangeValuesExtension on RangeValues {
  String toStringB(String unit, int? retainDecimals, initialStart, initialEnd) {
    double nowStart = roundToNDecimalPlaces(start, retainDecimals ?? 0);
    double nowEnd = roundToNDecimalPlaces(end, retainDecimals ?? 0);

    String nowStartStr = nowStart == nowStart.truncate()
        ? nowStart.truncate().toString()
        : nowStart.toString();

    String nowEndStr = nowEnd == nowEnd.truncate()
        ? nowEnd.truncate().toString()
        : nowEnd.toString();

    String s = nowStart == initialStart && nowEnd == initialEnd
        ? 'All'
        : "$nowStartStr - $nowEndStr $unit";

    return s;
  }
}
