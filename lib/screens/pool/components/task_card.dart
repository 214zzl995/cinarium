import 'package:bridge/call_rust/native/task_api.dart';
import 'package:bridge/call_rust/task.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/pool/controllers/pool_controller.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({Key? key, required this.id, required this.task})
      : super(key: key);
  final String id;
  final TaskOperationalData task;

  @override
  Widget build(BuildContext context) {
    final progress = task.status == TaskStatus.success ? 100 : task.schedule;

    (IconData, Color) status;
    if (task.status == TaskStatus.running) {
      status = (Icons.language_outlined, Theme.of(context).colorScheme.primary);
    } else if (task.status == TaskStatus.pause) {
      status = (
        Icons.motion_photos_paused_outlined,
        Theme.of(context).colorScheme.secondary
      );
    } else if (task.status == TaskStatus.wait) {
      status = (
        Icons.access_time_outlined,
        Theme.of(context).colorScheme.onSurfaceVariant
      );
    } else if (task.status == TaskStatus.success) {
      status = (Icons.check_circle_outline, Colors.green);
    } else {
      status = (Icons.error_outline, Theme.of(context).colorScheme.error);
    }

    (IconData, TaskStatus)? changeTaskStatus;

    if (task.status == TaskStatus.pause) {
      changeTaskStatus = (Icons.play_circle_outline_outlined, TaskStatus.wait);
    } else if (task.status == TaskStatus.fail) {
      changeTaskStatus = (Icons.refresh_outlined, TaskStatus.wait);
    } else if (task.status == TaskStatus.wait) {
      changeTaskStatus =
          (Icons.pause_circle_outline_outlined, TaskStatus.pause);
    }

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Flex(
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: 5,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                      )),
                );
              },
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    id,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    task.metadata.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Selector<PoolController, String>(
                      builder: (context, msg, child) {
                        return Text(msg,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ));
                      },
                      selector: (_, controller) =>
                          controller.taskMsg[id] ?? ''),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (changeTaskStatus != null)
                            IconButton(
                                onPressed: () {
                                  context
                                      .read<PoolController>()
                                      .changeTaskStatus(
                                          id, changeTaskStatus!.$2);
                                },
                                icon: Icon(changeTaskStatus.$1)),
                          IconButton(
                              onPressed: () {
                                context.read<PoolController>().removeTask(id);
                              },
                              icon: const Icon(Icons.delete_outlined))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AnimatedRotation(
                              turns: task.status == TaskStatus.running ? 1 : 0,
                              duration: const Duration(milliseconds: 1000),
                              child: Icon(
                                status.$1,
                                color: status.$2,
                                size: 22,
                              )),
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                size: 15,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '$progress%',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  )),
                ],
              ),
            )),
          ],
        ));
  }
}
