import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/root/page/root_page.dart';
import '../models/theme.dart';
import '../screens/debug/page/debug_page.dart';
import '../screens/home/page/home_page.dart';
import '../screens/http/page/http_page.dart';
import '../screens/pool/page/pool_page.dart';
import '../screens/retrieve/page/retrieve_page.dart';
import '../screens/settings/page/settings_page.dart';
import 'package:go_router/go_router.dart';

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
                pageBuilder: (context, state) => SlideUpFadeTransitionPage(
                    key: state.pageKey, child: const HomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.settings.router,
                name: Routes.settings.name,
                pageBuilder: (context, state) => SlideUpFadeTransitionPage(
                    key: state.pageKey, child: const SettingsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.retrieve.router,
                name: Routes.retrieve.name,
                pageBuilder: (context, state) => SlideUpFadeTransitionPage(
                    key: state.pageKey, child: const RetrievePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.debug.router,
                name: Routes.debug.name,
                pageBuilder: (context, state) => SlideUpFadeTransitionPage(
                    key: state.pageKey, child: const DebugPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.http.router,
                name: Routes.http.name,
                pageBuilder: (context, state) => SlideUpFadeTransitionPage(
                    key: state.pageKey, child: const HttpPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.pool.router,
                name: Routes.pool.name,
                pageBuilder: (context, state) => SlideUpFadeTransitionPage(
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
            pageBuilder: (context, state) => FadeTransitionPage(
                key: state.pageKey, child: const DebugPage()),
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
          GoRoute(
              path: Routes.settings.router,
              name: Routes.settings.name,
              pageBuilder: (context, state) => FadeTransitionPage(
                  key: state.pageKey, child: const SettingsPage())
          ),
        ]),
  ]);
}

/// A page that fades in an out.
class SlideUpFadeTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [SlideUpFadeTransitionPage].
  SlideUpFadeTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
            transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) =>
                SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.02),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: Tween<double>(
                        begin: 1,
                        end: 0,
                      ).animate(secondaryAnimation),
                      child: child,
                    )));

  static final CurveTween _curveTween = CurveTween(curve: Curves.easeIn);
}

class SlideHorizontalTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [SlideUpFadeTransitionPage].
  SlideHorizontalTransitionPage({
    required LocalKey super.key,
    required super.child,
    required this.xBegin,
  }) : super(
            transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) =>
                SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(xBegin, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: _curve,
                    )),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset.zero,
                        end: Offset(xBegin, 0),
                      ).animate(CurvedAnimation(
                        parent: secondaryAnimation,
                        curve: _curve,
                      )),
                      child: child,
                    )));

  final double xBegin;

  static const Curve _curve = Cubic(1, .19, 0, .81);
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
