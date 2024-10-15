import 'package:cinarium/screens/settings/page/settings_main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/root/page/root_page.dart';
import '../models/theme.dart';
import '../screens/debug/page/debug_page.dart';
import '../screens/home/page/home_page.dart';
import '../screens/http/page/http_page.dart';
import '../screens/pool/page/pool_page.dart';
import '../screens/retrieve/page/retrieve_page.dart';
import '../screens/settings/page/settings_crawler_template_page.dart';
import 'package:go_router/go_router.dart';

import '../screens/settings/page/settings_monitor_folder_page.dart';
import '../screens/settings/page/settings_root.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = '/home';

  /// 保持页面状态版本 但是我需要动画 而且我觉得没有什么必要 先放着
  static final routersKeepAlive = GoRouter(initialLocation: initial, routes: [
    StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          final theme = context.read<CinariumTheme>();
          if (theme.themeMode == ThemeMode.system) {
            //获取系统主题
            final Brightness platformBrightness =
                MediaQuery.platformBrightnessOf(context);

            theme.brightness = platformBrightness;
          }
          return RootPage(child: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.home.router,
                name: Routes.home.name,
                pageBuilder: (context, state) => FadeTransitionPage(
                    key: state.pageKey, child: const HomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.retrieve.router,
                name: Routes.retrieve.name,
                pageBuilder: (context, state) => FadeTransitionPage(
                    key: state.pageKey, child: const RetrievePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.debug.router,
                name: Routes.debug.name,
                pageBuilder: (context, state) => FadeTransitionPage(
                    key: state.pageKey, child: const DebugPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.http.router,
                name: Routes.http.name,
                pageBuilder: (context, state) => FadeTransitionPage(
                    key: state.pageKey, child: const HttpPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.pool.router,
                name: Routes.pool.name,
                pageBuilder: (context, state) => FadeTransitionPage(
                    key: state.pageKey, child: const PoolPage()),
              ),
            ],
          ),
        ]),
  ]);

  static final routers = GoRouter(initialLocation: initial, routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        final theme = context.read<CinariumTheme>();
        if (theme.themeMode == ThemeMode.system) {
          //获取系统主题
          final Brightness platformBrightness =
              MediaQuery.platformBrightnessOf(context);

          theme.brightness = platformBrightness;
        }
        return RootPage(child: child);
      },
      routes: [
        GoRoute(
          path: Routes.home.router,
          name: Routes.home.name,
          pageBuilder: (context, state) =>
              FadeTransitionPage(key: state.pageKey, child: const HomePage()),
        ),
        GoRoute(
          path: Routes.retrieve.router,
          name: Routes.retrieve.name,
          pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey, child: const RetrievePage()),
        ),
        GoRoute(
          path: Routes.debug.router,
          name: Routes.debug.name,
          pageBuilder: (context, state) =>
              FadeTransitionPage(key: state.pageKey, child: const DebugPage()),
        ),
        GoRoute(
          path: Routes.http.router,
          name: Routes.http.name,
          pageBuilder: (context, state) =>
              FadeTransitionPage(key: state.pageKey, child: const HttpPage()),
        ),
        GoRoute(
          path: Routes.pool.router,
          name: Routes.pool.name,
          pageBuilder: (context, state) =>
              FadeTransitionPage(key: state.pageKey, child: const PoolPage()),
        ),
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return SettingsRoot(child: child);
          },
          pageBuilder: (context, state, Widget child) => FadeTransitionPage(
              key: state.pageKey,
              child: SettingsRoot(
                child: child,
              )),
          routes: [
            GoRoute(
              path: Routes.settings.router,
              name: Routes.settings.name,
              pageBuilder: (context, state) => SlideTransitionPage(
                key: state.pageKey,
                child: const SettingsMainPage(),
              ),
              routes: [
                GoRoute(
                  path: SettingsRoutes.monitorFolder.router,
                  name: SettingsRoutes.monitorFolder.name,
                  pageBuilder: (context, state) => SlideTransitionPage(
                    key: state.pageKey,
                    child: const SettingsMonitorFolderPage(),
                  ),
                ),
                GoRoute(
                  path: SettingsRoutes.crawlerTemplate.router,
                  name: SettingsRoutes.crawlerTemplate.name,
                  pageBuilder: (context, state) => SlideTransitionPage(
                    key: state.pageKey,
                    child: const SettingsCrawlerTemplatePage(),
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    ),
  ]);
}

class SlideTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [SlideTransitionPage] with the old page sliding to the left.
  SlideTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(transitionsBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          // 新页面从右向左进入
          const beginOffset = Offset(1.0, 0.0); // 新页面从右边进入
          const endOffset = Offset.zero; // 停留在中间

          // 旧页面向左滑出
          const oldPageBeginOffset = Offset.zero; // 旧页面从中间开始
          const oldPageEndOffset = Offset(-1.0, 0.0); // 旧页面向左滑出

          // 新页面的滑动动画：从右边进入
          final slideInAnimation =
              Tween<Offset>(begin: beginOffset, end: endOffset)
                  .animate(CurvedAnimation(
            parent: animation,
            curve: _curve,
          ));

          // 旧页面的滑动动画：向左滑出
          final slideOutAnimation =
              Tween<Offset>(begin: oldPageBeginOffset, end: oldPageEndOffset)
                  .animate(CurvedAnimation(
            parent: secondaryAnimation,
            curve: _curve,
          ));

          // 使用 Stack 叠加新旧页面的滑动效果
          return SlideTransition(
            position: slideOutAnimation, // 旧页面向左滑出
            child: SlideTransition(
              position: slideInAnimation, // 新页面从右滑入
              child: child,
            ),
          );
        });

  static const Curve _curve = Curves.easeInOut; // 平滑的过渡曲线
}

class FadeTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [SlideUpFadeTransitionPage].
  FadeTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
            transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) =>
                // FadeTransition(opacity: animation, child: child));
                FadeTransition(
                    opacity:
                        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
                      parent: animation,
                      curve: _curve,
                    )),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 1, end: 0)
                          .animate(CurvedAnimation(
                        parent: secondaryAnimation,
                        curve: _curve,
                      )),
                      child: child,
                    )));

  static const Curve _curve = Cubic(1, .19, 0, .81);
}
