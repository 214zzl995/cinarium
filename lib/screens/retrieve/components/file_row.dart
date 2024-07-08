import 'package:bridge/call_rust/model/video.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/retrieve/components/crawl_name_field.dart';

import '../controllers/retrieve_controller.dart';
import 'file_col.dart';

class FileRow extends StatelessWidget {
  const FileRow(
      {Key? key,
      required this.untreatedVideo,
      required this.index,
      this.doubleTap})
      : super(key: key);

  final UntreatedVideo untreatedVideo;
  final int index;

  final bool? doubleTap;

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
        child: ValueListenableBuilder(
            valueListenable: isHovering,
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
                  value: untreatedVideo.matedata.filename,
                ),
                CrawlNameField(index),
                FileCol(
                  width: 100,
                  value: untreatedVideo.matedata.size,
                ),
                _buildAction(context),
              ],
            ),
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
            }),
      ),
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
                              value: untreatedVideo.matedata.filename,
                            ),
                          ],
                        ))),
                CrawlNameField(index),
                FileCol(
                  width: 100,
                  value: untreatedVideo.matedata.size,
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
                    icon: Icon(value
                        ? Icons.delete_outlined
                        : Icons.add_circle_outline),
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
              icon: const Icon(Icons.search_outlined),
            )
          ],
        ));
  }
}
