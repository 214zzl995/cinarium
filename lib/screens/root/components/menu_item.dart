import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_pages.dart';
import '../controllers/root_controller.dart';
import 'menu_param.dart';

typedef MenuItemIconBuilder = Widget Function(
    BuildContext context, AnimationController controller);

class MenuItem extends StatefulWidget {
  final String? lottie;
  final int? index;
  final Routes route;
  final MenuItemIconBuilder? builder;

  const MenuItem({
    Key? key,
    required this.lottie,
    required this.index,
    required this.route,
  })  : builder = null,
        super(key: key);

  const MenuItem.build({
    Key? key,
    required this.index,
    required this.route,
    required this.builder,
  })  : lottie = null,
        super(key: key);

  @override
  MenuItemState createState() => MenuItemState();
}

class MenuItemState extends State<MenuItem>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;

  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _lottieController.duration = const Duration(milliseconds: 200);

    //针对第一次进入的情况直接状态改到最后
    if (widget.index == 0 &&
        context.read<RootController>().route == widget.route &&
        !_lottieController.isAnimating) {
      _lottieController.value = 1;
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var route = context.select<RootController, Routes>((value) {
      if (_lottieController.value > 0 &&
          widget.route != value.route &&
          widget.lottie != null) {
        _lottieController.reverse();
      }
      return value.route;
    });

    Color? color;

    if (_isHovering && route != widget.route) {
      color = Theme.of(context).colorScheme.onSurface.withOpacity(0.03);
    } else {
      color = route == widget.route
          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.1)
          : null;
    }

    return SizedBox(
        height: MenuParam.menuItemsHeight,
        width: MenuParam.menuItemsWidth,
        child: MouseRegion(
          onEnter: (event) {
            setState(() => _isHovering = true);
          },
          onExit: (event) {
            setState(() => _isHovering = false);
          },
          child: GestureDetector(
              onTap: () {
                _lottieController.value = 0;
                _lottieController.forward();
                context.read<RootController>().route = widget.route;
                //跳转到对应路由
                if (widget.route.initial != null) {
                  GoRouter.of(context).go(widget.route.initial!.router);
                  return;
                }
                GoRouter.of(context).go(widget.route.router);
              },
              child: Container(
                margin:
                    EdgeInsets.only(bottom: MenuParam.menuItemsMarginBottom),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.lottie != null)
                      Lottie.asset(
                        widget.lottie!,
                        controller: _lottieController,
                        width: MenuParam.menuItemsHeight / 2.3,
                        height: MenuParam.menuItemsHeight / 2.3,
                        frameRate: FrameRate.max,
                        onLoaded: (composition) {
                          _lottieController.duration =
                              const Duration(milliseconds: 500);
                        },
                        delegates: LottieDelegates(
                          values: [
                            if (Theme.of(context).brightness == Brightness.dark)
                              ValueDelegate.colorFilter(
                                const [
                                  '**',
                                ],
                                value: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.exclusion,
                                ),
                              ),
                            /*ValueDelegate.colorFilter(
                              const [
                                '**',
                              ],
                              value: ColorFilter.mode(
                                Theme.of(context).colorScheme.onSurface,
                                BlendMode.exclusion,
                              ),
                            ),*/
                          ],
                        ),
                      )
                    else
                      widget.builder!(context, _lottieController)
                  ],
                ),
              )),
        ));
  }
}
