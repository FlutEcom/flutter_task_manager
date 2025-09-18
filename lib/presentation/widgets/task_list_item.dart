import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:zadanie/bloc/tasks_bloc.dart';
import 'package:zadanie/data/task_model.dart';
import 'package:zadanie/presentation/screens/add_edit_task_screen.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isOverdue = !task.isDone && task.deadline.isBefore(DateTime.now());

    return Dismissible(
      key: Key(task.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<TasksBloc>().add(DeleteTask(task.id!));
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Zadanie usunięto')));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditTaskScreen(task: task),
              ),
            );
          },
          leading: Checkbox(
            value: task.isDone,
            onChanged: (bool? value) {
              context.read<TasksBloc>().add(ToggleTaskCompletion(task));
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration:
                  task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
          subtitle: Text(
            'Termin: ${DateFormat('dd.MM.yyyy HH:mm').format(task.deadline)}',
            style: TextStyle(
              color: isOverdue ? Colors.redAccent : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
