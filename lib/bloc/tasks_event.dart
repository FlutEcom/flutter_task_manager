import 'package:equatable/equatable.dart';
import 'package:zadanie/data/task_model.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();
  @override
  List<Object> get props => [];
}

class LoadTasks extends TasksEvent {}

class AddTask extends TasksEvent {
  final Task task;
  const AddTask(this.task);
  @override
  List<Object> get props => [task];
}

class UpdateTask extends TasksEvent {
  final Task task;
  const UpdateTask(this.task);
  @override
  List<Object> get props => [task];
}

class DeleteTask extends TasksEvent {
  final int id;
  const DeleteTask(this.id);
  @override
  List<Object> get props => [id];
}

class ToggleTaskCompletion extends TasksEvent {
  final Task task;
  const ToggleTaskCompletion(this.task);
  @override
  List<Object> get props => [task];
}
