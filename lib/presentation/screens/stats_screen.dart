import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zadanie/bloc/tasks_bloc.dart';
import 'package:zadanie/data/task_model.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        if (state is TasksLoadSuccess) {
          final completedCount = state.completedTasks.length;
          final mostProductiveDay =
              _calculateMostProductiveDay(state.completedTasks);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatCard(
                  context,
                  title: 'Ukończone zadania',
                  value: completedCount.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  title: 'Najbardziej produktywny dzień',
                  value: mostProductiveDay,
                  icon: Icons.star_border_rounded,
                  color: Colors.amber,
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[400])),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateMostProductiveDay(List<Task> completedTasks) {
    if (completedTasks.isEmpty) {
      return 'Brak danych';
    }

    final dayCounts = <int, int>{};
    for (final task in completedTasks) {
      final weekday = task.deadline.weekday;
      dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
    }

    final mostProductiveDayIndex =
        dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final days = [
      'Poniedziałek',
      'Wtorek',
      'Środa',
      'Czwartek',
      'Piątek',
      'Sobota',
      'Niedziela'
    ];
    return days[mostProductiveDayIndex - 1];
  }
}
