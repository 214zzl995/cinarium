import 'dart:io';
import 'dart:ui';

import 'package:bridge/call_rust/model/video.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class MovCard extends StatelessWidget {
  const MovCard(this.video, this.thumbnailRatio, {super.key});

  final HomeVideo video;
  final double thumbnailRatio;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> hover = ValueNotifier<bool>(false);
    return Column(
      children: [
        MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event) {
              hover.value = true;
            },
            onExit: (event) {
              hover.value = false;
            },
            child: GestureDetector(
                onTap: () {
                  //systemApi.openInDefaultSoftware(path:"${smov.path}\\${smov.filename}.${smov.extension}" );
                },
                child: ValueListenableBuilder<bool>(
                  valueListenable: hover,
                  builder: (context, value, child) {
                    return Stack(
                      children: [
                        child!,
                        if (value) _buildMask(context),
                      ],
                    );
                  },
                  child: Positioned(
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          child: AspectRatio(
                            aspectRatio: thumbnailRatio,
                            child: ValueListenableBuilder<bool>(
                              valueListenable: hover,
                              builder: (context, value, child) {
                                return AnimatedScale(
                                    scale: value ? 1 : 1,
                                    curve: const Cubic(1, .21, .2, .9),
                                    duration: const Duration(milliseconds: 400),
                                    child: ExtendedImage(
                                      image: ExtendedResizeImage(
                                        ExtendedFileImageProvider(
                                          File("${video.matedata.path}/img/thumbnail.webp"),
                                          imageCacheName: video.name,
                                        ),
                                        compressionRatio: null,
                                        // maxBytes: 125 << 10,
                                        width: null,
                                        height: null,
                                        imageCacheName: video.name,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(11.0)),
                                      fit: BoxFit.contain,
                                      clearMemoryCacheWhenDispose: true,
                                      shape: BoxShape.rectangle,
                                    ));
                              },
                            ),
                          ))),
                ))),
        Row(
          children: [
            Container(
                alignment: Alignment.topLeft,
                height: CardParam.nameHeight,
                padding: const EdgeInsets.only(left: 10),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Text(video.name,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant))),
            Expanded(
              child: Container(),
            ),
            Container(
                alignment: Alignment.topRight,
                height: CardParam.nameHeight,
                padding: const EdgeInsets.only(right: 10),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Text(video.releaseTime.toString(),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant))),
          ],
        ),
      ],
    );
  }

  //现在还没有很好的方案 怎么完美的把详情显示出来
  Widget _buildMask(BuildContext context) {
    return Positioned.fill(
        top: 10,
        bottom: 10,
        left: 10,
        right: 10,
        child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0),
                // 此处添加其他子组件
              ),
            )));
  }
}

class CardParam {
  static const double nameHeight = 25;
  static const double cardWidth = 300;
}
