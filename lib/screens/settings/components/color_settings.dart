import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/theme.dart';
import 'color_piece.dart';

const accColors = [
  Color(0xFFBBC3FF),
  Color(0xFFA03F28),
  Color(0xFF496727),
  Color(0xff255fa4),
  Color(0xFF616036),
  Color(0xff45617c),
  Color(0xFF6750A4),
  Color(0xFF984061),
  Color(0xff006a67),
  Color(0xff8e437f),
  Color(0xff694fa3),
  Color(0xff2e6b27),
  Color(0xFF984813),
  Color(0xff3a5ba9),
  Color(0xFF646100),
];

class ColorSettings extends StatelessWidget {
  const ColorSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          width: 1,
        ),
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
                    '主题色',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            )),
            Row(
              children: [
                Text('自动跟随系统',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(
                  width: 10,
                ),
                Selector<SmovbookTheme, bool>(
                    selector: (_, theme) => theme.autoColor,
                    builder: (_, data, __) {
                      return Switch(
                        value: data,
                        onChanged: (val) {
                          final theme = context.read<SmovbookTheme>();
                          theme.autoColor = val;
                        },
                      );
                    })
              ],
            ),
          ]),
          Selector<SmovbookTheme, bool>(
            selector: (_, theme) => theme.autoColor,
            builder: (_, data, __) {
              return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
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
