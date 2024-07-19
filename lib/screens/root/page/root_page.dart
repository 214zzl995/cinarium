import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/models/theme.dart';
import 'package:cinarium/screens/settings/controllers/settings_controller.dart';
import '../../../util/theme_extension_util.dart';
import '../../hfs/controllers/http_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../pool/controllers/pool_controller.dart';
import '../../retrieve/controllers/retrieve_controller.dart';
import '../components/menu.dart';
import '../components/s_app_bar.dart';
import '../controllers/root_controller.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RootController()),
        ChangeNotifierProvider(create: (_) => RetrieveController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => HttpController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => PoolController())
      ],
      builder: (context, _) {
        //初始化 SettingsController
        context.read<SettingsController>();
        context.read<PoolController>();
        return Scaffold(
          backgroundColor: Theme.of(context).extension<CustomColors>()!.danger,
          appBar: SAppBar(
            toolbarHeight: 45,
            windowButtonHeight: 30,
            title: Row(
              children: [
                const ImageIcon(
                  AssetImage('assets/app_icon.ico'),
                  size: 20,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  context.select<RootController, String>(
                      (RootController p) => p.title),
                  style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SystemFont'),
                )
              ],
            ),
            //windowButtonHeight: 33,
            backgroundColor:
                Theme.of(context).extension<CustomColors>()!.danger,
            surfaceTintColor:
                Theme.of(context).extension<CustomColors>()!.danger,
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Menu(),
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(8)),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDarkSwitch(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20.0),
      alignment: Alignment.center,
      child: Row(
        children: [
          Transform.scale(
              scale: 0.9,
              child: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (val) {
                  final theme = context.read<SmovbookTheme>();
                  if (val) {
                    theme.mode = ThemeMode.dark;
                    theme.setEffect(theme.windowEffect, context,
                        brightness: Brightness.dark);
                  } else {
                    theme.mode = ThemeMode.light;
                    theme.setEffect(theme.windowEffect, context,
                        brightness: Brightness.light);
                  }
                },
              )),
          const Text('Dark'),
        ],
      ),
    );
  }
}
