import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/retrieve/components/file_col.dart';
import '../components/file_row.dart';
import '../components/search_field.dart';
import '../controllers/retrieve_controller.dart';

// 如果list 需要有动画可能需要 SliverFadeTransition
class RetrievePage extends StatelessWidget {
  const RetrievePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 10),
        child: Column(
          children: [
            _buildToolBar(context),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _buildTableHeader(context),
                  SliverFixedExtentList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final file =
                            context.read<RetrieveController>().showFiles[index];
                        return FileRow(
                          index: index,
                          untreatedVideo: file,
                          doubleTap: false,
                        );
                      },
                      childCount: context.select<RetrieveController, int>(
                          (value) => value.fileCount),
                    ),
                    itemExtent: 55.0,
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyHeaderDelegate(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FileCol(
                width: 50,
                value: Selector<RetrieveController, bool?>(
                  selector: (context, controller) => controller.checkAll,
                  builder: (context, checkAll, child) {
                    return Checkbox(
                      value: checkAll,
                      tristate: true,
                      onChanged: (value) {
                        context
                            .read<RetrieveController>()
                            .checkAllFiles(value ?? false);
                      },
                    );
                  },
                ),
              ),
              const FileCol(
                width: 50,
                value: Text("FileId",
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              const FileCol(
                flex: 1,
                value: Text("FileName",
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              FileCol(
                  flex: 1,
                  value: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      const Text("SeekName",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.edit_note_outlined,
                        size: 20,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ],
                  )),
              const FileCol(
                  width: 100,
                  value: Text("FileSize",
                      style: TextStyle(fontWeight: FontWeight.w500))),
              const FileCol(
                  width: 120,
                  value: Text("Actions",
                      style: TextStyle(fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolBar(BuildContext context) {
    return Container(
      height: 50,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Selector<RetrieveController, int>(
                    selector: (_, controller) => controller.fileCount,
                    builder: (context, fileCount, child) {
                      return Text(
                        "Total: $fileCount Files",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SearchField(),
            const SizedBox(
              width: 20,
            ),
            Selector<RetrieveController, List<bool>>(
              selector: (_, controller) => List.of(FileFilter.values)
                  .map((e) => e == controller.filterFlag)
                  .toList(),
              builder: (context, isSelected, child) {
                return ToggleButtons(
                  direction: Axis.horizontal,
                  onPressed: (int index) {
                    context
                        .read<RetrieveController>()
                        .changeFilterFiles(FileFilter.values[index], true);
                  },
                  fillColor: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  selectedColor: Theme.of(context).colorScheme.onPrimary,
                  constraints:
                      const BoxConstraints(minWidth: 50, minHeight: 35),
                  isSelected: [...isSelected],
                  children: [
                    ...List.of(FileFilter.values)
                        .map((e) => Text(e.name))
                        .toList()
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Selector<RetrieveController, bool>(selector: (_, controller) {
      return controller.checkAll ?? true;
    }, builder: (selectorContext, data, __) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.fastLinearToSlowEaseIn,
        switchOutCurve: Curves.easeOut,
        child: data
            ? Container(
                key: const ValueKey(1),
                margin: const EdgeInsets.only(bottom: 15),
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        context
                            .read<RetrieveController>()
                            .switchVideoHiddenWithCheck(true);
                      },
                      child: const Icon(Icons.delete_outlined),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<RetrieveController>()
                            .switchVideoHiddenWithCheck(false);
                      },
                      child: const Icon(Icons.add_circle_outline),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<RetrieveController>()
                            .insertionOfTasksCheck();
                      },
                      child: const Icon(Icons.search_outlined),
                    ),
                  ],
                ),
              )
            : Container(
                key: const ValueKey(2),
                margin: const EdgeInsets.only(bottom: 15),
                width: 200,
                height: 50,
              ),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(animation),
            child: child,
          );
        },
      );
    });
  }
}

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 68.0;

  @override
  double get minExtent => 68.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}