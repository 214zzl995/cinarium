import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:provider/provider.dart';
import 'package:system_info2/system_info2.dart';

import '../../../models/theme.dart';

const win11Mode = [
  WindowEffect.disabled,
  //支持大于 1803
  WindowEffect.acrylic,
  WindowEffect.mica,
  //此效果 只支持 22523以上
  WindowEffect.tabbed,
];

const win10Mode = [
  WindowEffect.disabled,
  WindowEffect.aero,
  WindowEffect.transparent,
];

const win7Mode = [
  WindowEffect.aero,
  WindowEffect.disabled,
  WindowEffect.transparent,
];

const linuxMode = [
  WindowEffect.disabled,
  WindowEffect.transparent,
];

const macOSMode = [
  WindowEffect.disabled,
  WindowEffect.titlebar,
  WindowEffect.selection,
  WindowEffect.menu,
  WindowEffect.popover,
  WindowEffect.sidebar,
  WindowEffect.headerView,
  WindowEffect.sheet,
  WindowEffect.windowBackground,
  WindowEffect.hudWindow,
  WindowEffect.fullScreenUI,
  WindowEffect.toolTip,
  WindowEffect.contentBackground,
  WindowEffect.underWindowBackground,
  WindowEffect.underPageBackground,
];

List<WindowEffect> get currentWindowEffects {
  if (defaultTargetPlatform == TargetPlatform.windows) {
    //win11 最开始 的版本号为 22000 ，win10 的版本号为 10240 ，win7 的版本号为 7601
    //获取内部版本号 例如 10.0.22621
    final version = SysInfo.operatingSystemVersion;
    //截取最后一段版本号 例如 22621
    final versionNumber = int.parse(version.split('.').last);
    //判断版本号是否大于 22000
    if (versionNumber >= 22000) {
      return win11Mode;
    } else if (versionNumber >= 10240) {
      return win10Mode;
    } else {
      return win7Mode;
    }
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    return linuxMode;
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    return macOSMode;
  }
  return [];
}

class ModeSetting extends StatelessWidget {
  const ModeSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
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
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          children: [
            Icon(
              Icons.window_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Window Effect',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        ...currentWindowEffects.map((e) => Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                    child: Row(
                  children: [
                    Radio(
                      value: e,
                      groupValue: context.watch<CinariumTheme>().windowEffect,
                      onChanged: (val) {
                        final theme = context.read<CinariumTheme>();
                        theme.windowEffect = val!;
                        //设置效果
                        theme.setEffect(val, context);
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
