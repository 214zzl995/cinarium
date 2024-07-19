import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/root_controller.dart';
import 'menu_param.dart';

class MenuIndicatorSticky extends StatefulWidget {
  final double parentHeight;

  const MenuIndicatorSticky({Key? key, required this.parentHeight})
      : super(key: key);

  @override
  MenuIndicatorStickyState createState() => MenuIndicatorStickyState();
}

enum Direction { up, down }

class MenuIndicatorStickyState extends State<MenuIndicatorSticky>
    with TickerProviderStateMixin {
  late double indicatorTop;
  late double indicatorBottom;
  late int index = 0;
  late Direction direction = Direction.down;
  late double topDistance = 0;
  late double bottomDistance = 0;
  late double topAdvanced = 0;
  late double bottomAdvanced = 0;

  late AnimationController topAnimationController;
  late AnimationController bottomAnimationController;
  late Animation<double> topAnimation;
  late Animation<double> bottomAnimation;

  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  @override
  void dispose() {
    topAnimationController.dispose();
    bottomAnimationController.dispose();
    super.dispose();
  }

  /// 如果需要实现微软商店的弹性效果 两个贝塞尔曲线不能相同
  void initAnimation() {
    //设置当前的路由下标
    //在initState中是可以使用read的 等效于 Provider.of() listen: false
    //官方例子 https://github.com/brianegan/flutter_architecture_samples/blob/41a033f6e67ec51bba2edf669cfcb857498db58c/change_notifier_provider/lib/edit_todo_screen.dart
    index = context.read<RootController>().route.index;

    //此代码的意思是在 渲染第一帧后执行 等效于
    // Future.delayed(Duration.zero,() {
    //   ... showDialog(context, ....)
    // });
    //但时间点不同
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RootController>().addListener(() {
        final conIndex = context.read<RootController>().route.index;
        //如果路由下标发生变化则执行动画
        if (index != conIndex) {
          final waitTime = ((MenuParam.indicatorLongMilliseconds -
                      MenuParam.indicatorShortMilliseconds) +
                  (MenuParam.indicatorLongMilliseconds *
                      MenuParam.indicatorDelayRate))
              .toInt();

          setDistance(conIndex);
          if (index < conIndex) {
            bottomAnimationController.duration =
                Duration(milliseconds: MenuParam.indicatorLongMilliseconds);

            bottomAnimationController.forward(from: 0);

            Future.delayed(Duration(milliseconds: waitTime), () {
              topAnimationController.duration =
                  Duration(milliseconds: MenuParam.indicatorShortMilliseconds);
              topAnimationController.forward(from: 0);
            });
          } else {
            topAnimationController.duration =
                Duration(milliseconds: MenuParam.indicatorLongMilliseconds);

            topAnimationController.forward(from: 0);

            Future.delayed(Duration(milliseconds: waitTime), () {
              bottomAnimationController.duration =
                  Duration(milliseconds: MenuParam.indicatorShortMilliseconds);

              bottomAnimationController.forward(from: 0);
            });
          }
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
    topAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: MenuParam.indicatorShortMilliseconds),
    );

    bottomAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: MenuParam.indicatorLongMilliseconds),
    );

    //对贝塞尔理解有限 暂时只能这样 如果需要微软商店效果 两个贝塞尔曲线需要不同
    bottomAnimation = CurvedAnimation(
      parent: bottomAnimationController,
      curve: const Cubic(1, -0.02, .57, 1),
    );

    topAnimation = CurvedAnimation(
      parent: topAnimationController,
      curve: const Cubic(1, -0.02, .57, 1),
    );

    topAnimation.addListener(() {
      final forward = topDistance * topAnimation.value;
      //定位到问题 第二次时movingDistance 为 -68.0
      final movingDistance = forward - topAdvanced;
      setState(() {
        indicatorTop = indicatorTop + movingDistance;
      });

      topAdvanced = forward;
    });

    bottomAnimation.addListener(() {
      final forward = bottomDistance * bottomAnimation.value;
      final movingDistance = forward - bottomAdvanced;
      setState(() {
        indicatorBottom = indicatorBottom - movingDistance;
      });
      bottomAdvanced = forward;
    });
  }

  void setDistance(int rootIndex) {
    final endTop = rootIndex * MenuParam.menuItemsHeight +
        (MenuParam.menuItemsHeight -
                MenuParam.indicatorHeight -
                MenuParam.menuItemsMarginBottom) /
            2;

    topDistance = endTop - indicatorTop;

    final endBottom = widget.parentHeight - endTop - MenuParam.indicatorHeight;

    bottomDistance = indicatorBottom - endBottom;

    topAdvanced = 0;
    bottomAdvanced = 0;
  }

  @override
  void didUpdateWidget(MenuIndicatorSticky oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.parentHeight != oldWidget.parentHeight) {
      setState(() {
        indicatorBottom =
            indicatorBottom + (widget.parentHeight - oldWidget.parentHeight);
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
