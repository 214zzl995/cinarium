import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/models/theme.dart';
import 'package:cinarium/screens/settings/controllers/settings_controller.dart';
import '../../../util/theme_extension_util.dart';
import '../../http/controllers/http_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../pool/controllers/pool_controller.dart';
import '../../retrieve/controllers/retrieve_controller.dart';
import '../components/menu.dart';
import '../components/cinarium_app_bar.dart';
import '../controllers/root_controller.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RootController()),
        ChangeNotifierProvider(
          create: (_) => RetrieveController(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => HttpController()),
        ChangeNotifierProvider(
          create: (_) => SettingsController(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => PoolController(),
          lazy: false,
        )
      ],
      builder: (context, _) {
        return Scaffold(
          backgroundColor:
              Theme.of(context).extension<EffectMenuColors>()!.danger,
          appBar: CinariumAppBar(
            toolbarHeight: 40,
            windowButtonHeight: 30,
            title: Row(
              children: [
                SvgPicture.asset('assets/logo.svg',
                    width: 17, height: 20, semanticsLabel: 'Logo'),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  context.select<RootController, String>(
                      (RootController p) => p.title),
                  style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SystemFont'),
                )
              ],
            ),
            //windowButtonHeight: 33,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Menu(),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          width: 0.3),
                      left: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          width: 0.3),
                    ),
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
