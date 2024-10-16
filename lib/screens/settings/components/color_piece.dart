import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../models/theme.dart';

class ColorPiece extends StatelessWidget {
  const ColorPiece({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Selector<CinariumTheme, bool>(
        selector: (_, theme) => theme.color?.value == color.value,
        builder: (_, data, __) {
          return ValueListenableBuilder(
            valueListenable: ValueNotifier(false),
            builder: (BuildContext context, bool value, Widget? child) {
              return MouseRegion(
                onEnter: (_) => value = true,
                onExit: (_) => value = false,
                cursor:
                    value ? SystemMouseCursors.click : SystemMouseCursors.basic,
                child: child!,
              );
            },
            child: GestureDetector(
                onTap: () {
                  context.read<CinariumTheme>().color = color;
                },
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.topRight,
                  decoration: data
                      ? BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 2,
                          ),
                        )
                      : BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                  child: data
                      ? Container(
                          alignment: Alignment.center,
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outline,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(5),
                                bottomLeft: Radius.circular(5)),
                          ),
                          child: Icon(
                            Symbols.check,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 15,
                            weight: 1000,
                          ),
                        )
                      : Container(),
                )),
          );
        });
  }
}
