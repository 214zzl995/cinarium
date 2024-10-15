import 'package:bridge/call_rust/native/task_api.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/pool/components/task_card.dart';
import 'package:cinarium/screens/pool/controllers/pool_controller.dart';

class PoolPage extends StatelessWidget {
  const PoolPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Expanded(
            child: _buildTasksView(context),
          )
        ],
      ),
      floatingActionButton: _buildPoolButton(context),
    );
  }

  Widget _buildTasksView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
              child: CustomScrollView(slivers: [
            Selector<PoolController, int>(
              builder: (context, len, child) {
                if (len == 0) {
                  return SliverToBoxAdapter(
                      child: Lottie.asset(
                    'assets/lottie/pool_empty.json',
                    repeat: true,
                    animate: true,
                    reverse: false,
                    frameRate: FrameRate.max,
                    width: 300,
                    height: 300,
                  ));
                }

                return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 450.0,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 12.0,
                        childAspectRatio: 1.5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final (id, task) = context
                              .read<PoolController>()
                              .poolData
                              .tasks[index];

                          return TaskCard(id: id, task: task);
                        },
                        childCount: len,
                      ),
                    ));
              },
              selector: (context, controller) =>
                  controller.poolData.tasks.length,
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ]))
        ],
      ),
    );
  }

  Widget _buildPoolButton(BuildContext context) {
    return Selector<PoolController, PoolStatus>(
      selector: (context, controller) => controller.poolStatus,
      builder: (context, value, child) {
        return FloatingActionButton(
          onPressed: () {
            // context.read<PoolController>().changeTaskPoolStatus();
          },
          child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: Container(
                key: ValueKey(value),
                child: _buildIcon(value),
              ),
              transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  )),
        );
      },
    );
  }

  Widget _buildIcon(PoolStatus value) {
    switch (value) {
      case PoolStatus.running:
        return const Icon(Icons.pause);
      case PoolStatus.pause:
        return const Icon(Icons.play_arrow);
      case PoolStatus.pauseLoading:
        return const CircularProgressIndicator();
      default:
        return const Icon(Icons.play_arrow);
    }
  }
}
