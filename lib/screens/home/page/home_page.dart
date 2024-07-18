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

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 0, bottom: 50, left: 0, right: 0, child: _buildBody()),
          _buildFilterBar(context),
        ],
      ),
      floatingActionButton: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /*FloatingActionButton(
            onPressed: context.read<HomeController>().getNativeList,
            tooltip: 'Refresh',
            child: const Icon(Icons.refresh),
          ),*/
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
                itemCount: movList.length + 1,
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
                    final video = context.read<HomeController>().videoList[index];
                    return SlideFadeTransition(
                        offset: 0.3, child: MovCard(video, video.thumbnailRatio));
                  }
                },
              ));
        });
  }

  Widget _buildBody() {
    return Selector<HomeController, (bool, bool)>(
        selector: (_, homeController) =>
            (homeController.loading, homeController.videoList.isEmpty),
        builder: (selectorContext, data, __) {
          final loading = data.$1;
          final empty = data.$2;
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
                : empty
                    ? Lottie.asset(
                        'assets/lottie/animation_empty_whale.json',
                        repeat: true,
                        animate: true,
                        reverse: false,
                        frameRate: FrameRate.max,
                        width: 500,
                        height: 500,
                      )
                    : _buildScrollingView(selectorContext),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
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
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, -1),
              ),
            ],
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
