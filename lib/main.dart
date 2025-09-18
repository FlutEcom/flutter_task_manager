import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zadanie/bloc/tasks_bloc.dart';
import 'package:zadanie/data/database_helper.dart';
import 'package:zadanie/presentation/screens/home_screen.dart';
import 'package:zadanie/services/notification_service.dart';

Future<void> main() async {
  // Upewniamy się, że wszystkie wtyczki są zainicjowane przed startem aplikacji.
  WidgetsFlutterBinding.ensureInitialized();

  // Prosimy o uprawnienia do powiadomień przy starcie.
  await NotificationService().requestPermissions();
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dostarczamy BLoC do całego drzewa widżetów za pomocą BlocProvider.
    return BlocProvider(
      create: (context) => TasksBloc(
        databaseHelper: DatabaseHelper.instance,
        notificationService: NotificationService(),
      )..add(LoadTasks()), // Wysyłamy początkowe zdarzenie, aby załadować zadania.
      child: MaterialApp(
        title: 'Menadżer Zadań',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
            surface: const Color(0xFF121212),
          ),
          textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              )),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

