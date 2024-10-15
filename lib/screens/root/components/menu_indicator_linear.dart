import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_pages.dart';
import '../controllers/root_controller.dart';
import 'menu_param.dart';

class MenuIndicatorLinear extends StatefulWidget {
  final double parentHeight;

  const MenuIndicatorLinear({super.key, required this.parentHeight});

  @override
  MenuIndicatorLinearState createState() => MenuIndicatorLinearState();
}

enum Direction { up, down }

class MenuIndicatorLinearState extends State<MenuIndicatorLinear>
    with TickerProviderStateMixin {
  late double indicatorTop;
  late double indicatorBottom;
  late int index = 0;
  late Direction direction = Direction.down;
  late double topDistance = 0;
  late double bottomDistance = 0;
  late double topAdvanced = 0;
  late double bottomAdvanced = 0;

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  /// 如果需要实现微软商店的弹性效果 两个贝塞尔曲线不能相同
  void initAnimation() {
    index = context.read<RootController>().route.index;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RootController>().addListener(() {
        final conRouter = context.read<RootController>().route;

        final conIndex = conRouter.index;
        //如果路由下标发生变化则执行动画
        if (index != conIndex) {
          setDistance(conIndex, conRouter.isTop);

          if (!Routes.values[index].isTop || !Routes.values[conIndex].isTop) {
            // animationController.duration = Duration.zero;
            // 没动画太硬了 还是加一下
            animationController.duration =
                Duration(milliseconds: MenuParam.indicatorLongMilliseconds);
          } else {
            animationController.duration =
                Duration(milliseconds: MenuParam.indicatorLongMilliseconds);
          }
          animationController.forward(from: 0);
        }
        index = conIndex;
      });
    });

    //计算当前位置
    indicatorTop = index * MenuParam.menuItemsHeight +
        (MenuParam.menuItemsHeight -
                MenuParam.indicatorHeight -
                MenuParam.menuItemsMarginBottom) /
            2;

    //bottom 计算为 父布局高度 减 导航条top值
    indicatorBottom =
        widget.parentHeight - indicatorTop - MenuParam.indicatorHeight;

    //初始化动画
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: MenuParam.indicatorLongMilliseconds),
    );

    animation = CurvedAnimation(
      parent: animationController,
      curve: const Cubic(1, .19, 0, .81),
    );

    animation.addListener(() {
      final topForward = topDistance * animation.value;
      final topMovingDistance = topForward - topAdvanced;

      setState(() {
        indicatorTop = indicatorTop + topMovingDistance;
      });

      topAdvanced = topForward;

      final bottomForward = bottomDistance * animation.value;
      final bottomMovingDistance = bottomForward - bottomAdvanced;
      indicatorBottom = indicatorBottom - bottomMovingDistance;
      bottomAdvanced = bottomForward;
    });
  }

  void setDistance(int rootIndex, bool isTop) {
    if (isTop) {
      final endTop = rootIndex * MenuParam.menuItemsHeight +
          (MenuParam.menuItemsHeight -
                  MenuParam.indicatorHeight -
                  MenuParam.menuItemsMarginBottom) /
              2;

      topDistance = endTop - indicatorTop;

      final endBottom =
          widget.parentHeight - endTop - MenuParam.indicatorHeight;

      bottomDistance = indicatorBottom - endBottom;
    } else {
      //计算空白距离
      final blankHeight = widget.parentHeight -
          MenuParam.menuItemsHeight * Routes.values.length;

      final endTop = rootIndex * MenuParam.menuItemsHeight +
          (MenuParam.menuItemsHeight -
                  MenuParam.indicatorHeight -
                  MenuParam.menuItemsMarginBottom) /
              2 +
          blankHeight;

      topDistance = endTop - indicatorTop;

      final endBottom =
          widget.parentHeight - endTop - MenuParam.indicatorHeight;

      bottomDistance = indicatorBottom - endBottom;
    }

    topAdvanced = 0;
    bottomAdvanced = 0;
  }

  @override
  void didUpdateWidget(MenuIndicatorLinear oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.parentHeight != oldWidget.parentHeight) {
      setState(() {
        if (context.read<RootController>().route.isTop) {
          indicatorBottom =
              indicatorBottom + (widget.parentHeight - oldWidget.parentHeight);
        } else {
          indicatorTop =
              indicatorTop + (widget.parentHeight - oldWidget.parentHeight);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 0,
        top: indicatorTop,
        bottom: indicatorBottom,
        child: Container(
          width: MenuParam.indicatorWidth,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.all(
                Radius.circular(2),
              )),
        ));
  }
}
