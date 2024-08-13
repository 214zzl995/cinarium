import 'package:bridge/call_rust/model/video.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
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

const filterPanelIndicatorHoverHeight = 35.0;
const filterPanelHeight = 400.0;

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
                      : filterPanelIndicatorHoverHeight - filterPanelHeight,
                  right: 0,
                  left: 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.bounceInOut,
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
    return Selector<HomeController, List<HomeVideo>>(
        selector: (_, homeController) => homeController.videoList,
        builder: (context, movList, child) {
          return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: WaterfallFlow.builder(
                key: ValueKey(movList),
                padding: const EdgeInsets.all(15),
                itemCount: movList.length,
                cacheExtent: 1500,
                gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 10.0,
                  collectGarbage: (List<int> garbages) {
                    for (final index in garbages) {
                      final mov = movList[index];
                      clearMemoryImageCache(mov.name);
                    }
                  },
                  lastChildLayoutTypeBuilder: (index) => index == movList.length
                      ? LastChildLayoutType.foot
                      : LastChildLayoutType.none,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (index == movList.length) {
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.bounceInOut,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: filterPanelVisible.value ? 5 : 0,
            offset: const Offset(0, 3),
          ),
        ],
        color: filterPanelVisible.value
            ? Theme.of(context).colorScheme.surfaceContainer
            : Theme.of(context).colorScheme.surface,
      ),
      height: filterPanelHeight,
      child: ValueListenableBuilder<bool>(
        valueListenable: filterPanelIndicatorVisible,
        builder: (context, indicatorVisible, child) => Column(
          children: [
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
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: indicatorVisible ? 1 : 0,
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: filterPanelVisible.value ? 0.5 : 0,
                    child: const Icon(Icons.keyboard_double_arrow_up),
                  ),
                ),
              ),
            ),
            if (filterPanelVisible.value) child!,
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            TextFilterEdit(),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                AttrFilterPanel(
                    FilterType.actor, Icons.account_circle_outlined),
              ],
            )
          ],
        ),
      ),
    );
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
              AttrFilterPanel(FilterType.actor, Icons.account_circle_outlined),
              SizedBox(width: 10),
              AttrFilterPanel(FilterType.series, Icons.camera_alt_outlined),
              SizedBox(width: 10),
              AttrFilterPanel(FilterType.tag, Icons.tag_outlined),
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
