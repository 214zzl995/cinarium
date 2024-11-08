import 'package:bridge/call_rust/model/video.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/retrieve/components/crawl_name_field.dart';
import 'package:super_context_menu/super_context_menu.dart';

import '../../../components/color_scheme_desktop_menu_widget_builder.dart';
import '../controllers/retrieve_controller.dart';
import 'file_col.dart';

class FileRow extends StatelessWidget {
  const FileRow(
      {super.key,
      required this.untreatedVideo,
      required this.index,
      required this.scrollController,
      this.doubleTap});

  final UntreatedVideo untreatedVideo;
  final int index;

  final bool? doubleTap;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final doubleTap = this.doubleTap ?? false;
    if (doubleTap) {
      return _buildDoubleTapRow(context);
    } else {
      return _buildOneTapRow(context);
    }
  }

  Widget _buildOneTapRow(BuildContext context) {
    final ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
    final ValueNotifier<bool> isMenuShow = ValueNotifier<bool>(false);
    scrollController.addListener(() {
      isHovering.value = false;
      isMenuShow.value = false;
    });
    final colorSchemeDesktopMenuWidgetBuilder =
        ColorSchemeDesktopMenuWidgetBuilder();
    return GestureDetector(
      onTap: () {
        context.read<RetrieveController>().checkFile(untreatedVideo.id);
      },
      child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (event) {
            isHovering.value = true;
          },
          onExit: (event) {
            isHovering.value = false;
          },
          child: ContextMenuWidget(
            iconTheme: const IconThemeData(fill: 1, opticalSize: 20),
            desktopMenuWidgetBuilder: colorSchemeDesktopMenuWidgetBuilder,
            menuProvider: (menuRequest) {
              scrollControllerListener() async {
                colorSchemeDesktopMenuWidgetBuilder.hideMenu();
              }

              menuRequest.onShowMenu.addListener(() {
                isMenuShow.value = true;
                debugPrint('show menu');
                scrollController.addListener(scrollControllerListener);
              });
              menuRequest.onHideMenu.addListener(() {
                isMenuShow.value = false;
                debugPrint('hide menu');
                scrollController.removeListener(scrollControllerListener);
              });

              final showAction = MenuAction(
                  title: 'Show',
                  image: MenuImage.icon(
                    Symbols.visibility,
                  ),
                  callback: () {});
              final hideAction = MenuAction(
                  title: 'Hide',
                  image: MenuImage.icon(
                    Symbols.visibility_off,
                  ),
                  callback: () {});

              return Menu(children: [
                untreatedVideo.isHidden ? showAction : hideAction,
                MenuAction(
                    title: 'Add to task',
                    image: MenuImage.icon(
                      Symbols.travel_explore,
                    ),
                    callback: () {}),
              ]);
            },
            child: ValueListenableBuilder(
              valueListenable: isHovering,
              builder: (BuildContext context, bool hovering, Widget? child) {
                return ValueListenableBuilder(
                  valueListenable: isMenuShow,
                  builder:
                      (BuildContext context, bool menuShow, Widget? child) {
                    return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: hovering || menuShow
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: child);
                  },
                  child: Row(
                    children: [
                      FileCol(
                          width: 50,
                          value: Selector<RetrieveController, bool>(
                            selector: (context, controller) =>
                                controller.checkMap[untreatedVideo.id] ?? false,
                            builder: (context, value, child) {
                              return Checkbox(
                                value: value,
                                onChanged: (value) {
                                  context
                                      .read<RetrieveController>()
                                      .checkFile(untreatedVideo.id, value!);
                                },
                              );
                            },
                          )),
                      FileCol(
                        width: 50,
                        value: untreatedVideo.id,
                      ),
                      FileCol(
                        flex: 1,
                        value: untreatedVideo.metadata.filename,
                      ),
                      CrawlNameField(index),
                      FileCol(
                        width: 100,
                        value: untreatedVideo.metadata.size,
                      ),
                      _buildAction(context),
                    ],
                  ),
                );
              },
            ),
          )),
    );
  }

  Widget _buildDoubleTapRow(BuildContext context) {
    final ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);

    return ValueListenableBuilder(
        valueListenable: isHovering,
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event) {
              isHovering.value = true;
            },
            onExit: (event) {
              isHovering.value = false;
            },
            child: Row(
              children: [
                FileCol(
                    width: 50,
                    value: Selector<RetrieveController, bool>(
                      selector: (context, controller) =>
                          controller.checkMap[untreatedVideo.id] ?? false,
                      builder: (context, value, child) {
                        return Checkbox(
                          value: value,
                          onChanged: (value) {
                            context
                                .read<RetrieveController>()
                                .checkFile(untreatedVideo.id, value!);
                          },
                        );
                      },
                    )),
                Expanded(
                    child: GestureDetector(
                        onDoubleTap: () {
                          context
                              .read<RetrieveController>()
                              .checkFile(untreatedVideo.id);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            FileCol(
                              width: 50,
                              value: untreatedVideo.id,
                            ),
                            FileCol(
                              flex: 1,
                              value: untreatedVideo.metadata.filename,
                            ),
                          ],
                        ))),
                CrawlNameField(index),
                FileCol(
                  width: 100,
                  value: untreatedVideo.metadata.size,
                ),
                _buildAction(context)
              ],
            )),
        builder: (BuildContext context, bool value, Widget? child) {
          return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: value
                    ? Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.6)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(5),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: child);
        });
  }

  Widget _buildAction(BuildContext context) {
    return FileCol(
        width: 120,
        value: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Selector<RetrieveController, bool>(
                selector: (context, controller) =>
                    controller.showFiles[index].isHidden,
                builder: (context, value, child) {
                  return IconButton(
                    style: TextButton.styleFrom(
                        iconColor: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      context
                          .read<RetrieveController>()
                          .switchVideosHidden([untreatedVideo.id]);
                    },
                    icon: Icon(
                        value ? Symbols.visibility : Symbols.visibility_off,
                        size: 20,
                        weight: 600),
                  );
                }),
            IconButton(
              style: TextButton.styleFrom(
                  iconColor: Theme.of(context).colorScheme.primary),
              onPressed: () {
                context
                    .read<RetrieveController>()
                    .insertionOfTasks([untreatedVideo.id]);
              },
              icon: const Icon(
                Symbols.travel_explore,
                size: 20,
                weight: 600,
              ),
            )
          ],
        ));
  }
}
