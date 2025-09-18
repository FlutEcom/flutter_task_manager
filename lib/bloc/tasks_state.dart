import 'package:equatable/equatable.dart';
import 'package:zadanie/data/task_model.dart';

abstract class TasksState extends Equatable {
  const TasksState();
  @override
  List<Object> get props => [];
}

class TasksLoadInProgress extends TasksState {}

class TasksLoadSuccess extends TasksState {
  final List<Task> activeTasks;
  final List<Task> completedTasks;

  const TasksLoadSuccess(
      {this.activeTasks = const [], this.completedTasks = const []});

  @override
  List<Object> get props => [activeTasks, completedTasks];
}

class TasksLoadFailure extends TasksState {}
