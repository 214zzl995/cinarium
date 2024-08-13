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

        return SizedBox(
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                                                  .addFilter(filterType,
                                                      attr.key, value ?? false);
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
                                                          !filterList[attr.key]!
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
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant))))
                                      ])),
                            ],
                          );
                        }),
                  ),
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
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}
