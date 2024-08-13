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

    return Selector<HomeController, (Map<int, FilterValue>, int)>(
      builder: (context, value, child) {
        final filterList = value.$1;

        return Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.3),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(5)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 14, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                ),
                child: Row(
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant))
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: ValueListenableBuilder<String>(
                      valueListenable: searchValue,
                      builder:
                          (BuildContext context, String value, Widget? child) {
                        return ScrollAnimator(
                            scrollSpeed: 1,
                            builder: (context, controller, physics) => ListView(
                                  controller: controller,
                                  shrinkWrap: true,
                                  physics: physics,
                                  children: [
                                    ...List.of(filterList.entries)
                                        .where((element) => element.value.value
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
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

  Widget _buildItem(BuildContext context, MapEntry<int, FilterValue> attr) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Checkbox(
        value: attr.value.checked,
        onChanged: (value) {
          context
              .read<HomeController>()
              .addFilter(filterType, attr.key, value ?? false);
        },
      ),
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
