import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/home/controllers/home_controller.dart';

class AttrFilterPanelMenu extends StatelessWidget {
  const AttrFilterPanelMenu(this.filterType, this.icon, {super.key});
  final FilterType filterType;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final searchValue = ValueNotifier("");
    final searchController = TextEditingController();

    return Selector<HomeController, (Map<int, FilterValue>, int)>(
      builder: (context, value, child) {
        final checkSize = value.$2;
        final filterList = value.$1;

        return MenuAnchor(
          alignmentOffset: const Offset(0, 15),
          clipBehavior: Clip.none,
          onClose: () {
            searchValue.value = "";
          },
          style: MenuTheme.of(context).style?.copyWith(),
          builder:
              (BuildContext context, MenuController controller, Widget? child) {
            return Stack(clipBehavior: Clip.none, children: [
              if (checkSize > 0)
                Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      height: 16,
                      width: 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: Theme.of(context).colorScheme.primary),
                      child: Text(
                        checkSize.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              TextButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                    return;
                  }
                  controller.open();
                },
                child: Row(
                  children: [
                    Icon(icon),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(filterType.name.capitalizeFirstLetter())
                  ],
                ),
              )
            ]);
          },
          menuChildren: [
            Column(
              children: [
                Container(
                  constraints: const BoxConstraints(
                      maxHeight: 500, maxWidth: 500, minWidth: 300),
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical, // 设置垂直滚动
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // 设置水平滚动
                      child: ValueListenableBuilder<String>(
                          valueListenable: searchValue,
                          builder: (BuildContext context, String value,
                              Widget? child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...List.of(filterList.entries)
                                    .where((element) => element.value.value
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                    .map((attr) => Row(children: [
                                          Checkbox(
                                              value:
                                                  filterList[attr.key]!.checked,
                                              onChanged: (value) {
                                                context
                                                    .read<HomeController>()
                                                    .addFilter(
                                                        filterType,
                                                        attr.key,
                                                        value ?? false);
                                              }),
                                          MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                  onTap: () {
                                                    context
                                                        .read<HomeController>()
                                                        .addFilter(
                                                            filterType,
                                                            attr.key,
                                                            !filterList[
                                                                    attr.key]!
                                                                .checked);
                                                  },
                                                  child: Text(
                                                      attr.value.value
                                                          .replaceAll('\n', ''),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onSurfaceVariant))))
                                        ]))
                              ],
                            );
                          }),
                    ),
                  ),
                ),
                child!
              ],
            ),
          ],
        );
      },
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SizedBox(
                    height: 40,
                    child: TextField(
                      cursorHeight: 22,
                      cursorWidth: 3,
                      controller: searchController,
                      cursorOpacityAnimates: true,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      onChanged: (value) {
                        searchValue.value = value;
                      },
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                            left: 10,
                          ),
                          border: const OutlineInputBorder(),
                          label: Text(
                            '',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.primary,
                          )),
                    )),
              ),
              const SizedBox(
                width: 30,
              ),
              SizedBox(
                width: 90,
                child: ElevatedButton(
                    onPressed: () {
                      context.read<HomeController>().clearFilter(filterType);
                      searchValue.value = "";
                      searchController.text = "";
                    },
                    child: const Text('Clear')),
              )
            ],
          )),
      selector: (context, homeController) {
        Map<int, FilterValue> filterList;

        switch (filterType) {
          case FilterType.actor:
            filterList = context.watch<HomeController>().actorFilter;
            break;
          case FilterType.director:
            filterList = context.watch<HomeController>().directorFilter;
            break;
          case FilterType.tag:
            filterList = context.watch<HomeController>().tagFilter;
            break;
          case FilterType.series:
            filterList = context.watch<HomeController>().seriesFilter;
            break;
          default:
            filterList = {};
        }

        final checkSize =
            filterList.values.where((element) => element.checked).length;

        return (filterList, checkSize);
      },
    );
  }
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}
