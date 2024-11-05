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
        Container(
          height: 150,
          margin: const EdgeInsets.only(bottom: 20),
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
                    width: 20,
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
                      onPressed: () {
                        _openImportDialog(context);
                      },
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
                          Row(
                            children: [
                              TextButton(
                                  onPressed: () {
                                    context
                                        .read<SettingsController>()
                                        .deleteTemplate(template.id)
                                        .then((val) {
                                      if (val != null) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Symbols.error,
                                                      size: 30,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    const Text('Error')
                                                  ],
                                                ),
                                                content: Text(val),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('OK'),
                                                  )
                                                ],
                                              );
                                            });
                                      }
                                    });
                                  },
                                  child: const Icon(Symbols.delete, size: 20)),
                              const SizedBox(
                                width: 20,
                              ),
                              Transform.scale(
                                scale: 0.9,
                                child: Selector<SettingsController, bool>(
                                    builder: (_, enabled, __) {
                                      return Checkbox(
                                          value: enabled,
                                          onChanged: (value) {
                                            context
                                                .read<SettingsController>()
                                                .modelDisableChange(
                                                    value, index);
                                          });
                                    },
                                    selector: (_, settings) => settings
                                        .crawlerTemplates[index].enabled),
                              )
                            ],
                          ),
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

  void _openImportDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        ValueNotifier<PickerTemplateFile?> selectTemplatePath =
            ValueNotifier(null);
        TextEditingController baseUrlController = TextEditingController();
        TextEditingController searchUrlController = TextEditingController();

        return AlertDialog(
          title: _buildDialogTitle(dialogContext),
          content: SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                _buildFilePathSection(selectTemplatePath, context),
                const SizedBox(height: 20),
                _buildUrlInputSection('Base Url', baseUrlController, context),
                const SizedBox(height: 20),
                _buildUrlInputSection(
                    'Search Url', searchUrlController, context),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: _buildDialogActions(dialogContext, selectTemplatePath,
              baseUrlController, searchUrlController, context),
        );
      },
    );
  }

  Widget _buildDialogTitle(BuildContext context) {
    return Row(
      children: [
        Icon(
          Symbols.download,
          color: Theme.of(context).colorScheme.primary,
          weight: 400,
        ),
        const SizedBox(width: 10),
        Text(
          'Import Crawler Template',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }

  Widget _buildFilePathSection(
      ValueNotifier<PickerTemplateFile?> selectTemplatePath,
      BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Icon(Symbols.file_open),
          SizedBox(width: 10),
          Text('File Path'),
        ]),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          constraints: const BoxConstraints(minHeight: 48),
          width: double.infinity,
          child: ValueListenableBuilder(
            valueListenable: selectTemplatePath,
            builder: (valueListenableContext, value, child) {
              return TextButton(
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  backgroundColor: value != null && value.error
                      ? Theme.of(context).colorScheme.errorContainer
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  context
                      .read<SettingsController>()
                      .pickerTemplateFile()
                      .then((value) {
                    selectTemplatePath.value = value;
                  });
                },
                child: value == null
                    ? const Icon(Symbols.mouse, size: 20, weight: 500)
                    : _buildSelectedFileRow(value, context),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFileRow(PickerTemplateFile value, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 8,
          child: Text(value.path, textAlign: TextAlign.left),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: value.error
              ? Tooltip(
                  message: value.errorText,
                  child: Icon(
                    Symbols.error,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                    weight: 500,
                  ),
                )
              : const Icon(Symbols.check_circle, size: 20, weight: 500),
        ),
      ],
    );
  }

  Widget _buildUrlInputSection(
      String label, TextEditingController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Symbols.link),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDialogActions(
      BuildContext dialogContext,
      ValueNotifier<PickerTemplateFile?> selectTemplatePath,
      TextEditingController baseUrlController,
      TextEditingController searchUrlController,
      BuildContext context) {
    return [
      TextButton(
        onPressed: () {
          Navigator.of(dialogContext).pop();
        },
        child: const Text('Cancel'),
      ),
      ValueListenableBuilder(
        valueListenable: baseUrlController,
        builder: (_, baseUrl, child) {
          return ValueListenableBuilder(
            valueListenable: searchUrlController,
            builder: (_, searchUrl, child) {
              return ValueListenableBuilder(
                valueListenable: selectTemplatePath,
                builder: (_, selectTemplate, child) {
                  bool canImport = baseUrl.text.isNotEmpty &&
                      searchUrl.text.isNotEmpty &&
                      selectTemplate != null &&
                      !selectTemplate.error;
                  return TextButton(
                    onPressed: canImport
                        ? () {
                            context
                                .read<SettingsController>()
                                .importTemplateFile(selectTemplate.raw!,
                                    baseUrl.text, searchUrl.text)
                                .then((_) {
                              Navigator.of(dialogContext).pop();
                            });
                          }
                        : null,
                    child: const Text('Import'),
                  );
                },
              );
            },
          );
        },
      ),
    ];
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
