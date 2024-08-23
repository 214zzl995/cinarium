import '../util/path_util.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/color.g.dart';
import '../models/text_direction.g.dart';
import '../models/theme.dart';
import '../models/theme_mode.g.dart';
import '../models/window_effect.g.dart';

/// Hive 数据操作
class HiveUtil {
  /// 实例
  static HiveUtil? instance;

  late Box _themeBox;

  Box get themeBox => _themeBox;

  /// <https://docs.hivedb.dev/>
  static Future<void> install() async {
    /// 初始化Hive地址
    final roaming = PathUtil.roaming;
    Hive.init(roaming);

    /// 注册自定义对象（实体）
    /// <https://docs.hivedb.dev/#/custom-objects/type_adapters>
    Hive.registerAdapter(CinariumThemeAdapter());
    Hive.registerAdapter(ColorAdapter());
    Hive.registerAdapter(TextDirectionAdapter());
    Hive.registerAdapter(ThemeModeAdapter());
    Hive.registerAdapter(WindowEffectAdapter());

    ///初始化 instance
    await getInstance();
  }

  /// 初始化 Box
  static Future<HiveUtil> getInstance() async {
    if (instance == null) {
      instance = HiveUtil();
      await Hive.initFlutter();
      instance?._themeBox = await Hive.openBox<CinariumTheme>('theme');
    }
    return instance!;
  }
}
