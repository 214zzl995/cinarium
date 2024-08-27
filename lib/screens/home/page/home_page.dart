import 'package:cinarium/components/scroll_animator.dart';
import 'package:cinarium/screens/home/components/attr_filter_panel_menu.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/home/components/video_card.dart';
import 'package:cinarium/screens/home/components/size_filter_panel.dart';
import 'package:cinarium/screens/home/controllers/home_controller.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../components/attr_filter_panel.dart';
import '../components/duration_filter_panel.dart';
import '../components/slide_fade_transition.dart';
import '../components/text_filter_edit.dart';

const filterPanelIndicatorHoverHeight = 25.0;

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> filterPanelVisible = ValueNotifier(false);
    ValueNotifier<bool> filterPanelIndicatorVisible = ValueNotifier(false);
    ValueNotifier<bool> filterPanelLock = ValueNotifier(false);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: Listener(
                onPointerDown: (event) {
                  if (!filterPanelLock.value) {
                    filterPanelVisible.value = false;
                    filterPanelIndicatorVisible.value = false;
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: _buildBody(),
                )),
          ),
          // _buildFilterBar(context),
          ValueListenableBuilder<bool>(
              valueListenable: filterPanelVisible,
              builder: (context, panelVisible, child) => AnimatedPositioned(
                  bottom: panelVisible
                      ? 0
                      : filterPanelIndicatorHoverHeight -
                          context.read<HomeController>().filterPanelHeight,
                  right: 0,
                  left: 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutQuart,
                  child: _buildFilterPanel(context, filterPanelVisible,
                      filterPanelIndicatorVisible, filterPanelLock)))
        ],
      ),
      floatingActionButton: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildScrollingView(BuildContext context) {
    return Selector<HomeController, int>(
        selector: (_, homeController) => homeController.ts,
        builder: (context, _, child) {
          final videoList = context.read<HomeController>().videoList;
          return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: WaterfallFlow.builder(
                key: ValueKey(videoList),
                padding: const EdgeInsets.all(15),
                itemCount: videoList.length,
                cacheExtent: 1500,
                gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 10.0,
                  collectGarbage: (List<int> garbages) {
                    for (final index in garbages) {
                      final mov = videoList[index];
                      clearMemoryImageCache(mov.name);
                    }
                  },
                  lastChildLayoutTypeBuilder: (index) =>
                      index == videoList.length
                          ? LastChildLayoutType.foot
                          : LastChildLayoutType.none,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final video = context.read<HomeController>().videoList[index];
                  return SlideFadeTransition(offset: 1, child: MovCard(video));
                },
              ));
        });
  }

  Widget _buildBody() {
    return Selector<HomeController, bool>(
        selector: (_, homeController) => (homeController.loading),
        builder: (selectorContext, loading, __) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: loading
                ? Center(
                    child: Lottie.asset(
                      'assets/lottie/loading_40_paperplane.json',
                      repeat: true,
                      animate: true,
                      reverse: false,
                      frameRate: FrameRate.max,
                      width: 500,
                      height: 500,
                    ),
                  )
                : Selector<HomeController, bool>(
                    builder: (selectorContext, empty, __) {
                      return empty
                          ? Lottie.asset(
                              'assets/lottie/home_empty.json',
                              repeat: true,
                              animate: true,
                              reverse: false,
                              frameRate: FrameRate.max,
                              width: 500,
                              height: 500,
                            )
                          : _buildScrollingView(selectorContext);
                    },
                    selector: (_, homeController) =>
                        homeController.videoList.isEmpty),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        });
  }

  Widget _buildFilterPanel(BuildContext context, filterPanelVisible,
      filterPanelIndicatorVisible, filterPanelLock) {
    return Selector<HomeController, bool>(
        selector: (_, homeController) => (homeController.loading),
        builder: (selectorContext, loading, __) {
          if (loading) {
            return const SizedBox();
          }
          return Selector<HomeController, double>(
            builder: (context, height, child) {
              return SizedBox(
                height: height,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.bounceInOut,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: filterPanelVisible.value
                        ? Theme.of(context).colorScheme.surfaceContainer
                        : Theme.of(context).colorScheme.surface,
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: filterPanelIndicatorVisible,
                    builder: (context, indicatorVisible, child) => Column(
                      children: [
                        _buildPanelIndicator(
                          context,
                          filterPanelVisible,
                          filterPanelIndicatorVisible,
                          filterPanelLock,
                          mergeGestures: true,
                        ),
                        const SizedBox(height: 10),
                        Expanded(child: child!),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Expanded(
                          flex: 8,
                          child: Row(
                            children: [
                              Expanded(
                                  child: AttrFilterPanel(FilterType.actor,
                                      Icons.account_circle_outlined)),
                              Expanded(
                                  child: AttrFilterPanel(FilterType.series,
                                      Icons.camera_alt_outlined)),
                              Expanded(
                                  child: AttrFilterPanel(
                                      FilterType.tag, Icons.tag_outlined)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              const TextFilterEdit(),
                              const SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                  child: ScrollAnimator(
                                scrollSpeed: 1,
                                builder: (BuildContext context,
                                    ScrollController controller,
                                    ScrollPhysics? physics) {
                                  return SingleChildScrollView(
                                      controller: controller,
                                      physics: physics,
                                      child: const Column(
                                        children: [
                                          DurationFilterPanel(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SizeFilterPanel(),
                                        ],
                                      ));
                                },
                              ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            selector: (context, homeController) =>
                homeController.filterPanelHeight,
          );
        });
  }

  Widget _buildPanelIndicator(BuildContext context, filterPanelVisible,
      filterPanelIndicatorVisible, filterPanelLock,
      {bool mergeGestures = true}) {
    Widget indicator(lock) {
      return Container(
        width: double.infinity,
        height: filterPanelIndicatorHoverHeight,
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 18,
                  height: 6,
                  child: AnimatedContainer(
                    decoration: BoxDecoration(
                      color: filterPanelIndicatorVisible.value
                          ? Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.8)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    duration: const Duration(milliseconds: 200),
                  ),
                ),
              ),
            ),
            if (filterPanelVisible.value)
              Positioned(
                left: 10,
                child: Row(
                  children: [
                    Text('Filters',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
            if (filterPanelVisible.value)
              Positioned(
                right: 10,
                child: SizedBox(
                  height: filterPanelIndicatorHoverHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            filterPanelLock.value = !filterPanelLock.value;
                          },
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.all(0)), // 使得按钮填充整个空间
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: lock
                                ? Icon(
                                    key: const ValueKey(true),
                                    Icons.lock_outline,
                                    size: 17,
                                    color: Theme.of(context).colorScheme.scrim,
                                    weight: 800,
                                  )
                                : const Icon(
                                    key: ValueKey(false),
                                    Icons.lock_open_outlined,
                                    size: 17,
                                    weight: 800,
                                  ),
                          ))
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    void onVerticalDragUpdate(DragUpdateDetails details) {
      if (filterPanelVisible.value && !filterPanelLock.value) {
        final maxHeight = Scaffold.of(context).context.size?.height;
        final minHeight = maxHeight! / 4;
        final beginHeight = context.read<HomeController>().filterPanelHeight;
        final endHeight = beginHeight - details.delta.dy;
        context.read<HomeController>().filterPanelHeight =
            endHeight.clamp(minHeight, maxHeight);
      }
    }

    Widget mergeGesturesWidget(lock) {
      return InkWell(
        mouseCursor: lock
            ? SystemMouseCursors.basic
            : filterPanelVisible.value
                ? SystemMouseCursors.move
                : SystemMouseCursors.click,
        onHover: (hover) {
          if (!filterPanelVisible.value && !filterPanelLock.value) {
            filterPanelIndicatorVisible.value = hover;
          }
        },
        onTap: () {
          if (!filterPanelLock.value) {
            filterPanelVisible.value = !filterPanelVisible.value;
          }
        },
        child: GestureDetector(
          onVerticalDragUpdate: onVerticalDragUpdate,
          child: indicator(lock), // 使用提取的indicator
        ),
      );
    }

    Widget unMergeGesturesWidget(lock) {
      return Column(
        children: [
          if (filterPanelVisible.value)
            MouseRegion(
              cursor: lock
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.resizeRow,
              child: GestureDetector(
                onVerticalDragUpdate: onVerticalDragUpdate,
                child: Container(
                  width: double.infinity,
                  height: 6,
                  color: Colors.transparent,
                ),
              ),
            ),
          InkWell(
            onHover: (hover) {
              if (!filterPanelVisible.value && !filterPanelLock.value) {
                filterPanelIndicatorVisible.value = hover;
              }
            },
            onTap: () {
              if (!filterPanelLock.value) {
                filterPanelVisible.value = !filterPanelVisible.value;
              }
            },
            child: indicator(lock), // 使用提取的indicator
          ),
        ],
      );
    }

    return ValueListenableBuilder<bool>(
        valueListenable: filterPanelLock,
        builder: (context, lock, child) {
          return mergeGestures
              ? mergeGesturesWidget(lock)
              : unMergeGesturesWidget(lock);
        });
  }

  Widget _buildFilterBar(BuildContext context) {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: const Row(
            children: [
              SizedBox(width: 10),
              AttrFilterPanelMenu(
                  FilterType.actor, Icons.account_circle_outlined),
              SizedBox(width: 10),
              AttrFilterPanelMenu(FilterType.series, Icons.camera_alt_outlined),
              SizedBox(width: 10),
              AttrFilterPanelMenu(FilterType.tag, Icons.tag_outlined),
              SizedBox(width: 10),
              DurationFilterPanel(),
              SizedBox(width: 10),
              SizeFilterPanel(),
              TextFilterEdit(),
            ],
          ),
        ));
  }
}
