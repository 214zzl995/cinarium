import 'package:cinarium/screens/home/components/duration_filter_edits.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/home_controller.dart';

class DurationFilterPanelMenu extends StatelessWidget {
  const DurationFilterPanelMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(0, 5),
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Selector<HomeController, (int?, int?)?>(
                  builder: (context, value, child) {
                    if (value != null &&
                        (value.$1 != null || value.$2 != null)) {
                      return Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            height: 16,
                            width: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                color: Theme.of(context).colorScheme.primary),
                          ));
                    } else {
                      return Container();
                    }
                  },
                  selector: (context, homeController) => homeController.loading
                      ? null
                      : homeController.durationFilter),
              TextButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                    return;
                  }
                  controller.open();
                },
                child: const Row(
                  children: [
                    Icon(Icons.timer_outlined),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Duration')
                  ],
                ),
              )
            ]);
      },
      menuChildren: const [DurationFilterEdits()],
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
