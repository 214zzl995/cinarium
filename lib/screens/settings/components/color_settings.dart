import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/theme.dart';
import 'color_piece.dart';

const accColors = [
  Color(0xFFBBC3FF),
  Color(0xFFF2F0FF), // 薰衣草色
  Color(0xFFFFFAFA), // 雪白色
  Color(0xFFF0FFF0), // 蜜瓜色
  Color(0xFFE0FFFF), // 淡青色
  Color(0xFFDCDCDC), // Gainsboro
  Color(0xFFF8F8FF), // Ghost White
  Color(0xFFF0FFFF), // Azure
  Color(0xFF87CEFA), // Light Sky Blue
  Color(0xFFB0C4DE), // Light Steel Blue


];

class ColorSettings extends StatelessWidget {
  const ColorSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Expanded(
                child: Row(
              children: [
                Icon(
                  Icons.color_lens_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Theme Colours',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            )),
            Row(
              children: [
                Text('follow-up system',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8))),
                const SizedBox(
                  width: 10,
                ),
                Selector<CinariumTheme, bool>(
                    selector: (_, theme) => theme.autoColor,
                    builder: (_, data, __) {
                      return Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: data,
                          onChanged: (val) {
                            final theme = context.read<CinariumTheme>();
                            theme.autoColor = val;
                          },
                        ),
                      );
                    }),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
          ]),
          Selector<CinariumTheme, bool>(
            selector: (_, theme) => theme.autoColor,
            builder: (_, data, __) {
              return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutQuart,
                  opacity: data ? 0.0 : 1.0,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: data
                        ? Container()
                        : Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    ...accColors
                                        .map((e) => ColorPiece(color: e))
                                        .toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ));
            },
            shouldRebuild: (prev, next) => prev != next,
          )
        ],
      ),
    );
  }
}
