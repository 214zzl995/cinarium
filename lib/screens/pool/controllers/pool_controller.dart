import 'package:bridge/call_rust/native/task_api.dart' as task_api;
import 'package:bridge/call_rust/native/task_api.dart';
import 'package:bridge/call_rust/task.dart';
import 'package:flutter/cupertino.dart';

class PoolController with ChangeNotifier {
  PoolController() {
    task_api.listenerTaskStatusChange(dartCallback: onTaskStatusChange);
    task_api.listenerPoolStatusChange(dartCallback: onPoolStatusChange);

    _poolData = task_api.getPoolData();
    _poolStatus = _poolData.status;
  }

  late PoolStatus _poolStatus;

  late PoolData _poolData;

  final Map<String, String> _taskMsg = {};

  void onTaskStatusChange(String id, TaskStatus status) async {
    for (var (taskId, task) in _poolData.tasks) {
      if (taskId == id) {
        task = task.copyWith(status: status);
      }
    }
    notifyListeners();
  }

  void onPoolStatusChange(PoolStatus poolStatus) async {
    _poolStatus = poolStatus;
    notifyListeners();
  }

  void pausePool() {
    task_api.pausePool();
  }

  void resumePool() {
    task_api.resumePool();
  }

  void forcePausePool() {
    task_api.forcePausePool();
  }

  void changeTaskStatus(String id, TaskStatus status) {
    task_api.changeTaskStatus(id: id, status: status);
  }

  (int, TaskStatus) removeTask(String uuid) {
    task_api.deleteTask(id: uuid);
    int id = 0;
    TaskStatus status = TaskStatus.values[0];

    _poolData.tasks.removeWhere((task) {
      if (task.$1 == uuid) {
        return true;
      }
      return false;
    });

    notifyListeners();
    return (id, status);
  }

  get poolStatus => _poolStatus;

  PoolData get poolData => _poolData;

  Map<String, String> get taskMsg => _taskMsg;
}

extension TaskOperationalDataExt on TaskOperationalData {
  TaskOperationalData copyWith({
    TaskStatus? status,
    int? schedule,
    String? lastLog,
    DateTime? createAt,
    TaskMetadata? metadata,
  }) {
    return TaskOperationalData(
      status: status ?? this.status,
      schedule: schedule ?? this.schedule,
      lastLog: lastLog ?? this.lastLog,
      createAt: createAt ?? this.createAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
