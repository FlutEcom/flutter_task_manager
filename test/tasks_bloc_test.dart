import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zadanie/bloc/tasks_bloc.dart';
import 'package:zadanie/data/database_helper.dart';
import 'package:zadanie/data/task_model.dart';
import 'package:zadanie/services/notification_service.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockDatabaseHelper mockDatabaseHelper;
  late MockNotificationService mockNotificationService;
  late Task testTask;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockNotificationService = MockNotificationService();
    
    registerFallbackValue(Task(
      title: 'Fallback Task',
      deadline: DateTime.now(),
    ));

    testTask = Task(
      id: 1,
      title: 'Nowe zadanie testowe',
      deadline: DateTime.now().add(const Duration(days: 1)),
    );
  });

  group('TasksBloc', () {
    test('stan początkowy to TasksLoadInProgress', () {
      expect(
        TasksBloc(
          databaseHelper: mockDatabaseHelper,
          notificationService: mockNotificationService,
        ).state,
        TasksLoadInProgress(),
      );
    });

    blocTest<TasksBloc, TasksState>(
      'emituje stan z nowym zadaniem po dodaniu zdarzenia AddTask',
      setUp: () {
        when(() => mockDatabaseHelper.createTask(any())).thenAnswer(
          (_) async => testTask,
        );
        when(() => mockNotificationService.scheduleNotification(any()))
            .thenAnswer((_) async {});
      },
      seed: () => const TasksLoadSuccess(activeTasks: [], completedTasks: []),
      build: () => TasksBloc(
        databaseHelper: mockDatabaseHelper,
        notificationService: mockNotificationService,
      ),
      act: (bloc) => bloc.add(AddTask(testTask)),
      expect: () => [
        isA<TasksLoadSuccess>()
            .having((state) => state.activeTasks.length, 'długość listy zadań aktywnych', 1)
            .having((state) => state.activeTasks.first.title, 'tytuł zadania', 'Nowe zadanie testowe'),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'poprawnie sortuje zadania po terminie po dodaniu nowego zadania z wcześniejszym terminem',
      setUp: () {
        when(() => mockDatabaseHelper.createTask(any())).thenAnswer(
          (_) async =>
              testTask.copyWith(id: 2, title: 'Zadanie na dzisiaj'),
        );
        when(() => mockNotificationService.scheduleNotification(any()))
            .thenAnswer((_) async {});
      },
      seed: () => TasksLoadSuccess(
        activeTasks: [
          Task(
              id: 1,
              title: 'Zadanie na jutro',
              deadline: DateTime.now().add(const Duration(days: 1))),
        ],
      ),
      build: () => TasksBloc(
        databaseHelper: mockDatabaseHelper,
        notificationService: mockNotificationService,
      ),
      act: (bloc) {
        final task = Task(
            title: 'Zadanie na dzisiaj',
            deadline: DateTime.now().add(const Duration(hours: 1)));
        bloc.add(AddTask(task));
      },
      expect: () => [
        isA<TasksLoadSuccess>()
            .having(
                (state) => state.activeTasks.length, 'długość listy', 2)
            .having((state) => state.activeTasks.first.title,
                'tytuł pierwszego zadania', 'Zadanie na dzisiaj'),
      ],
    );
  });
}

