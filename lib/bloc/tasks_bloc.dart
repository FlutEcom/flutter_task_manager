import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zadanie/data/database_helper.dart';
import 'package:zadanie/data/task_model.dart';
import 'package:zadanie/services/notification_service.dart';
import 'package:zadanie/bloc/tasks_event.dart';
import 'package:zadanie/bloc/tasks_state.dart';

export 'package:zadanie/bloc/tasks_event.dart';
export 'package:zadanie/bloc/tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final DatabaseHelper databaseHelper;
  final NotificationService notificationService;

  TasksBloc({required this.databaseHelper, required this.notificationService})
      : super(TasksLoadInProgress()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    try {
      final tasks = await databaseHelper.readAllTasks();
      final active = tasks.where((task) => !task.isDone).toList();
      final completed = tasks.where((task) => task.isDone).toList();
      emit(TasksLoadSuccess(activeTasks: active, completedTasks: completed));
    } catch (_) {
      emit(TasksLoadFailure());
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    if (state is TasksLoadSuccess) {
      final currentState = state as TasksLoadSuccess;

      final createdTask = await databaseHelper.createTask(event.task);

      try {
        await notificationService.scheduleNotification(createdTask);
      } catch (e) {
        debugPrint("Failed to schedule notification: $e");
      }

      final newActiveTasks = List<Task>.from(currentState.activeTasks)
        ..add(createdTask);
      newActiveTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

      emit(TasksLoadSuccess(
          activeTasks: newActiveTasks,
          completedTasks: currentState.completedTasks));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    await databaseHelper.updateTask(event.task);
    try {
      await notificationService.scheduleNotification(event.task);
    } catch (e) {
      debugPrint("Failed to schedule notification: $e");
    }
    add(LoadTasks());
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    if (state is TasksLoadSuccess) {
      final currentState = state as TasksLoadSuccess;
      await databaseHelper.deleteTask(event.id);
      await notificationService.cancelNotification(event.id);

      final newActiveTasks =
          currentState.activeTasks.where((task) => task.id != event.id).toList();
      final newCompletedTasks = currentState.completedTasks
          .where((task) => task.id != event.id)
          .toList();

      emit(TasksLoadSuccess(
          activeTasks: newActiveTasks, completedTasks: newCompletedTasks));
    }
  }

  Future<void> _onToggleTaskCompletion(
      ToggleTaskCompletion event, Emitter<TasksState> emit) async {
    final updatedTask = event.task.copyWith(isDone: !event.task.isDone);
    await databaseHelper.updateTask(updatedTask);
    if (updatedTask.isDone) {
      if (updatedTask.id != null) {
        await notificationService.cancelNotification(updatedTask.id!);
      }
    } else {
      try {
        await notificationService.scheduleNotification(updatedTask);
      } catch (e) {
        debugPrint("Failed to schedule notification: $e");
      }
    }
    add(LoadTasks());
  }
}

