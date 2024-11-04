import 'package:bridge/call_rust/frb_generated.dart';
import 'package:bridge/call_rust/native/db_api.dart';
import 'package:bridge/call_rust/native/system_api.dart';
import 'package:bridge/call_rust/native/task_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import './models/theme.dart';
import './routes/app_pages.dart';
import './util/theme_extension_util.dart';
import './util/desktop_util.dart';
import './util/hive_util.dart';
import 'package:window_manager/window_manager.dart';

void main(List<String> args) async {
  await RustLib.init();
  WidgetsFlutterBinding.ensureInitialized();
  await HiveUtil.install();
  await initAppLog();
  await initDb();
  await initCinariumConfig();
  await initPool();
  await initSourceNotify();

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
      await windowManager.setMinimumSize(const Size(700, 500));
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
      //await WindowManager.instance.setAsFrameless();
    });
  }
  CinariumTheme theme = await buildTheme();
  theme.refreshWindowEffect();

  runApp(MyApp(
    theme: theme,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.theme});

  final CinariumTheme theme;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => theme,
        builder: (notifierContext, _) {
          final readTheme = notifierContext.watch<CinariumTheme>();
          final effectBackgroundColor =
              EffectMenuColors(danger: readTheme.effectBackgroundColor);
          return MaterialApp.router(
            theme: ThemeData(
                colorScheme: readTheme.lightColorScheme,
                extensions: [effectBackgroundColor],
                scaffoldBackgroundColor: readTheme.lightColorScheme?.surface),
            darkTheme: ThemeData(
                colorScheme: readTheme.darkColorScheme,
                extensions: [effectBackgroundColor],
                scaffoldBackgroundColor: readTheme.lightColorScheme?.surface),
            supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: AppPages.routers,
            themeMode: readTheme.themeMode,
            debugShowCheckedModeBanner: false,
          );
        });
  }
}

Future<CinariumTheme> buildTheme() async {
  final hiveUtil = await HiveUtil.getInstance();
  var cinariumTheme = hiveUtil.themeBox.get('theme') as CinariumTheme?;
  if (cinariumTheme == null) {
    cinariumTheme = CinariumTheme();
    hiveUtil.themeBox.put('theme', cinariumTheme);
  }

  if (cinariumTheme.autoColor || cinariumTheme.color == null) {
    await cinariumTheme.initPlatformState();
    if (cinariumTheme.color == null) {
      cinariumTheme.color = cinariumTheme.lightColorScheme!.primary;
      hiveUtil.themeBox.put('theme', cinariumTheme);
    }
  } else {
    await cinariumTheme.initPlatformState(color: cinariumTheme.color);
  }

  return cinariumTheme;
}
