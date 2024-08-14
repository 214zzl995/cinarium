import 'package:cinarium/components/scroll_animator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/home/controllers/home_controller.dart';

/// 搜索框默认不显示 在 头部边上添加搜索按钮 点击后出现小搜索框 失去焦点后隐藏 但会在这个icon按钮 边上显示搜索字符串

class AttrFilterPanel extends StatelessWidget {
  const AttrFilterPanel(this.filterType, this.icon, {Key? key})
      : super(key: key);
  final FilterType filterType;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final searchValue = ValueNotifier("");
    final searchController = TextEditingController();

    ValueNotifier<bool> panelSearchShow = ValueNotifier(false);

    FocusNode focusNode = FocusNode();

    focusNode.addListener(() {
      if (!focusNode.hasFocus && searchController.value.text.isEmpty) {
        panelSearchShow.value = false;
      }
    });

    return Selector<HomeController, bool>(
        builder: (context, loading, child) {
          return Selector<HomeController, Map<int, FilterValue>>(
            builder: (context, filterMap, child) {
              return Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                ),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) => Container(
                        padding:
                            const EdgeInsets.only(left: 14, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  icon,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(filterType.name.capitalizeFirstLetter(),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant))
                              ],
                            ),
                            Row(
                              children: [
                                ValueListenableBuilder<bool>(
                                    valueListenable: panelSearchShow,
                                    builder: (context, value, child) {
                                      return AnimatedContainer(
                                          curve: Curves.easeOutQuart,
                                          height: 30,
                                          width: value
                                              ? constraints.maxWidth - 120
                                              : 20,
                                          duration:
                                              const Duration(milliseconds: 100),
                                          child: TextField(
                                            cursorHeight: 22,
                                            cursorWidth: 3,
                                            autofocus: true,
                                            controller: searchController,
                                            cursorOpacityAnimates: true,
                                            focusNode: focusNode,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            onChanged: (value) {
                                              searchValue.value = value;
                                            },
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                left: 10,
                                              ),
                                              border: value
                                                  ? const OutlineInputBorder()
                                                  : const OutlineInputBorder()
                                                      .copyWith(
                                                      borderSide:
                                                          BorderSide.none,
                                                    ), // 移除默认边框

                                              label: Text(
                                                '',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              prefixIcon: InkWell(
                                                onTap: () {
                                                  panelSearchShow.value =
                                                      !panelSearchShow.value;
                                                  focusNode.requestFocus();
                                                },
                                                child: const Icon(
                                                  Icons.search,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ));
                                    }),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        child: ValueListenableBuilder<String>(
                            valueListenable: searchValue,
                            builder: (BuildContext context, String value,
                                Widget? child) {
                              return ScrollAnimator(
                                  scrollSpeed: 1,
                                  builder: (context, controller, physics) =>
                                      ListView(
                                        controller: controller,
                                        shrinkWrap: true,
                                        physics: physics,
                                        children: [
                                          ...List.of(filterMap.entries)
                                              .where((element) => element
                                                  .value.value
                                                  .toLowerCase()
                                                  .contains(
                                                      value.toLowerCase()))
                                              .map((attr) =>
                                                  _buildItem(context, attr)),
                                        ],
                                      ));
                            }),
                      ),
                    ),
                  ],
                ),
              );
            },
            selector: (context, homeController) {
              switch (filterType) {
                case FilterType.actor:
                  return homeController.actorFilter;
                case FilterType.director:
                  return homeController.directorFilter;
                case FilterType.tag:
                  return homeController.tagFilter;
                case FilterType.series:
                  return homeController.seriesFilter;
                default:
                  return {};
              }
            },
          );
        },
        selector: (context, homeController) => homeController.loading);
  }

  Widget _buildItem(BuildContext context, MapEntry<int, FilterValue> attr) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Selector<HomeController, bool>(
          builder: (context, checked, child) => Checkbox(
                value: checked,
                onChanged: (value) {
                  context
                      .read<HomeController>()
                      .addFilter(filterType, attr.key, value ?? false);
                },
              ),
          selector: (context, homeController) {
            switch (filterType) {
              case FilterType.actor:
                return homeController.actorFilter[attr.key]!.checked;
              case FilterType.director:
                return homeController.directorFilter[attr.key]!.checked;
              case FilterType.tag:
                return homeController.tagFilter[attr.key]!.checked;
              case FilterType.series:
                return homeController.seriesFilter[attr.key]!.checked;
              default:
                return false;
            }
          }),
      Expanded(
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () {
                    context
                        .read<HomeController>()
                        .addFilter(filterType, attr.key, !attr.value.checked);
                  },
                  child: Text(attr.value.value.replaceAll('\n', ''),
                      softWrap: true,
                      maxLines: 1, // 需要换行显示直接改这个
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant)))))
    ]);
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
