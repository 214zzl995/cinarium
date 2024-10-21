import 'package:bridge/call_rust/task/crawler.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../components/scroll_animator.dart';
import '../../../util/search_url_util.dart';
import '../controllers/settings_controller.dart';

class SettingsCrawlerTemplatePage extends StatelessWidget {
  const SettingsCrawlerTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Lottie.asset(
                      'assets/lottie/monitor_folder.json',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(child: _buildDocument(context)),
                ],
              )),
              Container(
                margin: const EdgeInsets.only(right: 20, left: 20),
                padding: const EdgeInsets.only(bottom: 100),
                height: double.infinity,
                child: SizedBox(
                  height: 50,
                  width: 150,
                  child: TextButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.download,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            weight: 400,
                          ),
                          const SizedBox(width: 10),
                          const Text('Import'),
                        ],
                      )),
                ),
              )
            ],
          ),
        ),
        Expanded(child: _buildITemplatesList(context))
      ],
    );
  }

  Widget _buildITemplatesList(BuildContext context) {
    return ScrollAnimator(
        scrollSpeed: 0.5,
        builder: (context, controller, physics) =>
            Selector<SettingsController, List<CrawlerTemplate>>(
              selector: (_, settings) => settings.crawlerTemplates,
              builder: (BuildContext context,
                  List<CrawlerTemplate> crawlerTemplates, Widget? child) {
                return ListView.builder(
                  physics: physics,
                  controller: controller,
                  itemBuilder: (BuildContext context, int index) {
                    final template = crawlerTemplates[index];

                    return Container(
                      key: ValueKey(template),
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withOpacity(0.5),
                          width: 1,
                        ),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLowest,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Row(
                            children: [
                              const Icon(
                                Symbols.travel_explore,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("Base url: ${template.baseUrl}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  _buildSearchUrl(template.searchUrl, context),
                                ],
                              )
                            ],
                          )),
                          Selector<SettingsController, bool>(
                              builder: (_, enabled, __) {
                                return Checkbox(
                                    value: enabled,
                                    onChanged: (value) {
                                      context
                                          .read<SettingsController>()
                                          .modelDisableChange(value, index);
                                    });
                              },
                              selector: (_, settings) =>
                                  settings.crawlerTemplates[index].enabled),
                        ],
                      ),
                    );
                  },
                  itemCount: crawlerTemplates.length,
                );
              },
            ));
  }

  Widget _buildDocument(BuildContext context) {
    return ScrollAnimator(
        scrollSpeed: 0.5,
        builder: (context, controller, physics) => ListView(
              physics: physics,
              controller: controller,
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  '1. Base Url:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  'A string replacement node used in templates, also serves as a display label.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16.0),
                Text(
                  '2. Search Url:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  'Fetch URL for the root page.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16.0),
                Text(
                  '3. Variable Explanation:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  '\${crawl_name}: The name used in the query.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '\${###}: A child node can use content already fetched in the parent node; this string is used to get the ending part.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16.0),
                Text(
                  '4. Available Methods:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  'Includes: selector, parent, prev, next, replace, uppercase, lowercase, '
                  'insert, prepend, append, delete, regex, equals, html, attr, val.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16.0),
                Text(
                  '5. Usable mark:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  'Includes: request = true (Request the string obtained in this segment)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ));
  }
}

Widget _buildSearchUrl(String searchUrl, BuildContext context) {
  List<UrlSpan> urlSpans = SearchUrlUtil.parseSearchUrl(searchUrl);
  return Text.rich(
    TextSpan(
        children: urlSpans.map((urlSpan) {
      return TextSpan(
        text: urlSpan.text,
        style: TextStyle(
          color: urlSpan.isHyperlink
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: urlSpan.isHyperlink ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }).toList()),
    style: Theme.of(context).textTheme.labelSmall,
  );
}
