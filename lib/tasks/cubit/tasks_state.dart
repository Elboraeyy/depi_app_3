import '../../models/task_model.dart';

enum TasksStatus { initial, loading, success, failure }

class TasksState {
  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.message,
  });

  final TasksStatus status;
  final List<TaskModel> tasks;
  final String? message;

  TasksState copyWith({
    TasksStatus? status,
    List<TaskModel>? tasks,
    String? message,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      message: message,
    );
  }
}
