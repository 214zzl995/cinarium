import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/root/components/menu_indicator_linear.dart';

import '../../../routes/app_pages.dart';
import '../controllers/root_controller.dart';
import 'menu_item.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(children: [
          Column(
            children: [
              ...List.of(Routes.values.where((e) => e.isTop).map((route) {
                switch (route) {
                  case Routes.http:
                    return Stack(
                      children: [
                        MenuItem(
                          lottie: 'assets/lottie/menu-item-${route.name}.json',
                          index: route.index,
                          route: route,
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: context
                                  .select<RootController, Color>((value) {
                                if (value.httpStatus) {
                                  return Theme.of(context).colorScheme.primary;
                                } else {
                                  return Colors.transparent;
                                }
                              }),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Container(),
                          ),
                        ),
                      ],
                    );

                  case Routes.debug:
                    if (kDebugMode) {
                      return MenuItem(
                        lottie: 'assets/lottie/menu-item-${route.name}.json',
                        index: route.index,
                        route: route,
                      );
                    } else {
                      return Container();
                    }
                  default:
                    return MenuItem(
                      lottie: 'assets/lottie/menu-item-${route.name}.json',
                      index: route.index,
                      route: route,
                    );
                }
              })),
              Expanded(
                child: Container(),
              ),
              ...List.of(Routes.values.where((e) => !e.isTop).map((route) {
                return MenuItem(
                  index: route.index,
                  route: route,
                  lottie: 'assets/lottie/menu-item-${route.name}.json',
                );
              })),
            ],
          ),
          Consumer<RootController>(builder: (context, cart, child) {
            return MenuIndicatorLinear(parentHeight: constraints.maxHeight);
          }),
        ]);
      }),
    );
  }
}
