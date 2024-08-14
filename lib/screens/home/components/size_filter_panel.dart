import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import 'bilateral_range_slider.dart';

class SizeFilterPanel extends StatelessWidget {
  const SizeFilterPanel({Key? key}) : super(key: key);

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
              Icons.photo_size_select_large_outlined,
              size: 20,
            ),
            const SizedBox(
              width: 10,
            ),
            Text('Size',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant))
          ],
        ),
        BilateralRangeSlider(0, 30, "Gb", onChanged: (min, max) {
          context.read<HomeController>().addSizeFilter(
              min != null ? BigInt.from((min * 1073741824).round()) : null,
              max != null ? BigInt.from((max * 1073741824).round()) : null);
        },
            initStart: context.read<HomeController>().sizeFilter.$1 == null
                ? 0
                : context.read<HomeController>().sizeFilter.$1!.toDouble() /
                    1073741824,
            initEnd: context.read<HomeController>().sizeFilter.$2 == null
                ? 30
                : context.read<HomeController>().sizeFilter.$2!.toDouble() /
                    1073741824,
            retainDecimals: 1)
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
