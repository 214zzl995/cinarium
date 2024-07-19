import 'package:bridge/call_rust/frb_generated.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import './models/theme.dart';
import './routes/app_pages.dart';
import './util/theme_extension_util.dart';
import './util/desktop_util.dart';
import './util/hive_util.dart';
import './util/path_util.dart';
import './util/tray_util.dart';
import 'package:window_manager/window_manager.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await PathUtil.init();
  await HiveUtil.install();
  await TrayUtil.initSystemTray();
  await RustLib.init();

  if (DesktopUtil().isDesktop) {
    await flutter_acrylic.Window.initialize();
    await WindowManager.instance.ensureInitialized();
    await windowManager.center();

    if (defaultTargetPlatform == TargetPlatform.windows) {
      await flutter_acrylic.Window.hideWindowControls();
    }

    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setMinimumSize(const Size(800, 500));
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
      //await WindowManager.instance.setAsFrameless();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = Theme.of(context).brightness;
    return FutureBuilder<SmovbookTheme>(
      future: getTheme(mode),
      builder: (futureContext, snapshot) {
        if (snapshot.hasData) {
          final theme = snapshot.data!;

          return ChangeNotifierProvider(
              create: (_) => theme,
              builder: (notifierContext, _) {
                final readTheme = notifierContext.watch<SmovbookTheme>();
                final effectBackgroundColor =
                    CustomColors(danger: readTheme.effectBackgroundColor);
                return MaterialApp.router(
                  theme: ThemeData(
                    colorScheme: readTheme.lightColorScheme,
                    extensions: [effectBackgroundColor],
                    useMaterial3: true,
                  ),
                  darkTheme: ThemeData(
                    colorScheme: readTheme.darkColorScheme,
                    extensions: [effectBackgroundColor],
                    useMaterial3: true,
                  ),
                  supportedLocales: const [
                    Locale("zh", "CN"),
                    Locale("en", "US")
                  ],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routerConfig: AppPages.routers,
                  themeMode: readTheme.mode,
                  debugShowCheckedModeBanner: false,
                );
              });
        } else {
          //此时背景颜色未初始化
          return Column(
            children: [
              const Center(
                child: CircularProgressIndicator(),
              ),
              Container()
            ],
          );
        }
      },
    );
  }

  /// 持久化获取theme方法
  Future<SmovbookTheme> getTheme(Brightness mode) async {
    final hiveUtil = await HiveUtil.getInstance();
    var appTheme = hiveUtil.themeBox.get('theme') as SmovbookTheme?;
    if (appTheme == null) {
      appTheme = SmovbookTheme();
      hiveUtil.themeBox.put('theme', appTheme);
    }

    windowManager.waitUntilReadyToShow().then((_) async {
      ThemeMode themeMode;
      if (appTheme?.mode != ThemeMode.system) {
        themeMode = appTheme!.mode;
      } else {
        themeMode = mode == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      }

      Window.setEffect(
        effect: appTheme!.windowEffect,
        color: appTheme.effectBackgroundColor,
        dark: themeMode == ThemeMode.dark,
      );
    });

    //初始化 ColorScheme
    if (appTheme.autoColor || appTheme.color == null) {
      await appTheme.initPlatformState();
      if (appTheme.color == null) {
        appTheme.color = appTheme.lightColorScheme!.primary;
        hiveUtil.themeBox.put('theme', appTheme);
      }
    } else {
      await appTheme.initPlatformState(color: appTheme.color);
    }

    return appTheme;
  }
}





