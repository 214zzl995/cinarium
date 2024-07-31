import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../models/theme.dart';

class ColorPiece extends StatelessWidget {
  const ColorPiece({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 1),
        child: Selector<SmovbookTheme, bool>(
            selector: (_, theme) => theme.color?.value == color.value,
            builder: (_, data, __) {
              return ValueListenableBuilder(
                valueListenable: ValueNotifier(false),
                builder: (BuildContext context, bool value, Widget? child) {
                  return MouseRegion(
                    onEnter: (_) => value = true,
                    onExit: (_) => value = false,
                    cursor: value
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    child: child!,
                  );
                },
                child: GestureDetector(
                    onTap: () {
                      context.read<SmovbookTheme>().color = color;
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
                                color: const Color(0xFF494949),
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
                              decoration: const BoxDecoration(
                                color: Color(0xFF494949),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomLeft: Radius.circular(5)),
                              ),
                              child: const Icon(
                                CupertinoIcons.checkmark_alt,
                                color: CupertinoColors.white,
                                size: 15,
                              ),
                            )
                          : Container(),
                    )),
              );
            }));
  }
}