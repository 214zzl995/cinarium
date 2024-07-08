import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/theme.dart';

class BrightnessSetting extends StatelessWidget {
  const BrightnessSetting({super.key});

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
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                '主题',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        ...ThemeMode.values.map((e) => Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                    child: Row(
                  children: [
                    Radio(
                      value: e,
                      groupValue: context.watch<SmovbookTheme>().mode,
                      onChanged: (val) {
                        final theme = context.read<SmovbookTheme>();
                        theme.mode = val!;
                        //设置效果
                        Brightness brightness;
                        if (e == ThemeMode.system) {
                          //应获取系统主题 不然会因为 还没有触发重组 Theme获取的主题还是原来的主题
                          brightness = WidgetsBinding
                              .instance.platformDispatcher.platformBrightness;
                        } else {
                          brightness = e == ThemeMode.light
                              ? Brightness.light
                              : Brightness.dark;
                        }
                        theme.setEffect(theme.windowEffect, context,
                            brightness: brightness);
                      },
                    ),
                    Text(
                      e.name,
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                )),
                /* 未来可能需要增加的参数 模糊强度
                if (e == WindowEffect.acrylic)
                  Row(
                    children: [
                      Text('模糊强度',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                      const SizedBox(
                        width: 10,
                      ),
                      Selector<SmovbookTheme, double>(
                          selector: (_, theme) => theme.acrylicIntensity,
                          builder: (_, data, __) {
                            return Slider(
                              value: data,
                              onChanged: (val) {
                                final theme = context.read<SmovbookTheme>();
                                theme.acrylicIntensity = val;
                              },
                            );
                          })
                    ],
                  )*/
              ],
            )))
      ]),
    );
  }
}
