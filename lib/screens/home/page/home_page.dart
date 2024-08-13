import 'package:cinarium/components/scroll_animator.dart';
import 'package:cinarium/screens/home/components/attr_filter_panel_menu.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
              child: Listener(
            onPointerDown: (event) {
              filterPanelVisible.value = false;
              filterPanelIndicatorVisible.value = false;
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: _buildBody(),
            ),
          )),
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
                      filterPanelIndicatorVisible)))
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
                  if (index == videoList.length) {
                    return const SizedBox(
                      height: 0,
                    );
                  } else {
                    final video =
                        context.read<HomeController>().videoList[index];
                    return SlideFadeTransition(
                        offset: 0.1,
                        child: MovCard(video, video.thumbnailRatio));
                  }
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

  Widget _buildFilterPanel(
      BuildContext context, filterPanelVisible, filterPanelIndicatorVisible) {
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
                  ..._buildPanelIndicatorAmalgam(
                      context, filterPanelVisible, filterPanelIndicatorVisible),
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
                            child: AttrFilterPanel(
                                FilterType.series, Icons.camera_alt_outlined)),
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
      selector: (context, homeController) => homeController.filterPanelHeight,
    );
  }

  List<Widget> _buildPanelIndicatorSeparation(
      BuildContext context, filterPanelVisible, filterPanelIndicatorVisible) {
    return [
      if (filterPanelVisible.value)
        MouseRegion(
          cursor: SystemMouseCursors.resizeRow,
          child: GestureDetector(
            onVerticalDragUpdate: (DragUpdateDetails details) {
              if (filterPanelVisible.value) {
                final maxHeight = Scaffold.of(context).context.size?.height;
                final minHeight = maxHeight! / 4;
                final beginHeight =
                    context.read<HomeController>().filterPanelHeight;
                final endHeight = beginHeight - details.delta.dy;
                context.read<HomeController>().filterPanelHeight =
                    endHeight.clamp(minHeight, maxHeight);
              }
            },
            child: Container(
              width: double.infinity,
              height: 6,
              color: Colors.transparent,
            ),
          ),
        ),
      InkWell(
        onHover: (hover) {
          if (!filterPanelVisible.value) {
            filterPanelIndicatorVisible.value = hover;
          }
        },
        onTap: () {
          filterPanelVisible.value = !filterPanelVisible.value;
        },
        child: Container(
            width: double.infinity,
            height: filterPanelIndicatorHoverHeight,
            color: Colors.transparent,
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
            )),
      ),
    ];
  }

  List<Widget> _buildPanelIndicatorAmalgam(
      BuildContext context, filterPanelVisible, filterPanelIndicatorVisible) {
    return [
      InkWell(
        mouseCursor: filterPanelVisible.value
            ? SystemMouseCursors.allScroll
            : SystemMouseCursors.click,
        onHover: (hover) {
          filterPanelIndicatorVisible.value = hover;
        },
        onTap: () {
          filterPanelVisible.value = !filterPanelVisible.value;
        },
        child: GestureDetector(
          onVerticalDragUpdate: (DragUpdateDetails details) {
            if (filterPanelVisible.value) {
              final maxHeight = Scaffold.of(context).context.size?.height;
              final minHeight = maxHeight! / 4;
              final beginHeight =
                  context.read<HomeController>().filterPanelHeight;
              final endHeight = beginHeight - details.delta.dy;
              context.read<HomeController>().filterPanelHeight =
                  endHeight.clamp(minHeight, maxHeight);
            }
          },
          child: Container(
              width: double.infinity,
              height: filterPanelIndicatorHoverHeight,
              color: Colors.transparent,
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
              )),
        ),
      )
    ];
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
