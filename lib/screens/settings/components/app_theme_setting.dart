import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../models/theme.dart';
import 'color_piece.dart';

const accColors = [
  Color(0xFF7B8CD3),
  Color(0xFFAC72E6),
  Color(0xFFF38181),
  Color(0xFFADF8AD),
  Color(0xFF65D5D5),
  Color(0xFFD5BB63),
  Color(0xFFEDAE5D),
  Color(0xFFac608e),
  Color(0xFFB0C4DE),
  Color(0xFF6500FF),
];

class AppThemeSetting extends StatelessWidget {
  const AppThemeSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(6),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      child: ClipRect(
        child: Selector<CinariumTheme, bool>(
            selector: (_, theme) => theme.autoColor,
            builder: (_, data, child) {
              return LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth - 30;
                // 59.25 is the width of the color piece,Although I don't know why it is 59.25,
                final rowSize = (width / 53.6).floor();
                final columnSize = (accColors.length / rowSize).ceil();

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: data ? 40 : columnSize * (59.25) + 45,
                  child: child,
                );
              });
            },
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView(
                key: key,
                clipBehavior: Clip.none,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Row(mainAxisSize: MainAxisSize.max, children: [
                    Expanded(
                        child: Row(
                      children: [
                        Icon(
                          Symbols.colors,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          weight: 300,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            'Theme Colors',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    )),
                    Row(
                      children: [
                        Text('Follow system',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.8))),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          height: 40,
                          child: Selector<CinariumTheme, bool>(
                              selector: (_, theme) => theme.autoColor,
                              builder: (_, data, __) {
                                return Transform.scale(
                                  scale: 0.80,
                                  child: Switch(
                                    value: data,
                                    onChanged: (val) {
                                      final theme =
                                          context.read<CinariumTheme>();
                                      theme.autoColor = val;
                                    },
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(
                    height: 10,
                  ),
                  Selector<CinariumTheme, bool>(
                    selector: (_, theme) => theme.autoColor,
                    builder: (_, data, child) {
                      return AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          opacity: data ? 0 : 1.0,
                          child: child);
                    },
                    child: Row(
                      children: [
                        Expanded(
                            child: Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            ...accColors
                                .map((e) => ColorPiece(color: e))
                                .toList(),
                          ],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
