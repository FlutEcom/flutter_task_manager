import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zadanie/bloc/tasks_bloc.dart';
import 'package:zadanie/data/task_model.dart';
import 'package:zadanie/presentation/screens/add_edit_task_screen.dart';
import 'package:zadanie/presentation/screens/stats_screen.dart';
import 'package:zadanie/presentation/widgets/task_list_item.dart';
import 'package:zadanie/presentation/widgets/weather_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    TasksListPage(),
    StatsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Moje Zadania' : 'Statystyki',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddEditTaskScreen()),
                );
              },
              tooltip: 'Dodaj zadanie',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Zadania',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Statystyki',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}

class TasksListPage extends StatelessWidget {
  const TasksListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const WeatherWidget(),
        Expanded(
          child: BlocBuilder<TasksBloc, TasksState>(
            builder: (context, state) {
              if (state is TasksLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TasksLoadSuccess) {
                if (state.activeTasks.isEmpty && state.completedTasks.isEmpty) {
                  return const Center(
                    child: Text('Brak zadań. Dodaj nowe!',
                        style: TextStyle(fontSize: 18)),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    if (state.activeTasks.isNotEmpty)
                      _buildTaskList(context, 'Do zrobienia', state.activeTasks),
                    if (state.completedTasks.isNotEmpty)
                      _buildTaskList(
                          context, 'Ukończone', state.completedTasks),
                  ],
                );
              }
              if (state is TasksLoadFailure) {
                return const Center(
                    child: Text('Nie udało się załadować zadań.'));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context, String title, List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
        ...tasks.map((task) => TaskListItem(task: task)).toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}
