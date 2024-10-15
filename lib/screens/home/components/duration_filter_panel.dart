import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/home_controller.dart';
import 'bilateral_range_slider.dart';

class DurationFilterPanel extends StatelessWidget {
  const DurationFilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(right: 10),
      child: Column(children: [
        Row(
          children: [
            const Icon(
              Icons.timer_outlined,
              size: 20,
            ),
            const SizedBox(
              width: 10,
            ),
            Text('Duration',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant))
          ],
        ),
        BilateralRangeSlider(
          0,
          200,
          "Minutes",
          onChanged: (min, max) {
            context.read<HomeController>().addDurationFilter(min?.round(), max?.round());
          },
          initStart: context.read<HomeController>().durationFilter.$1 == null
              ? 0
              : context.read<HomeController>().durationFilter.$1!.toDouble(),
          initEnd: context.read<HomeController>().durationFilter.$2 == null
              ? 200
              : context.read<HomeController>().durationFilter.$2!.toDouble(),
        )
      ]),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}
