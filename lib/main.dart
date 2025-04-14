import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'block/toodo_block.dart';
import 'screens/todo_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  final SharedPreferences prefs = await SharedPreferences.getInstance(); // Initialize SharedPreferences

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>(create: (_) => prefs), // Provide SharedPreferences
        Provider<TodoBloc>(create: (context) => TodoBloc(context.read<SharedPreferences>())), // Pass SharedPreferences to TodoBloc
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(), // Fetch SharedPreferences
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for SharedPreferences to load, show a loading indicator
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          // Handle error case
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error loading preferences')),
            ),
          );
        } else {
          // Once SharedPreferences is loaded, build the app
          final SharedPreferences prefs = snapshot.data!;
          return MaterialApp(
            title: 'ToDo App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: BlocProvider(
              create: (context) => TodoBloc(prefs), // Pass the SharedPreferences instance
              child: TodoScreen(),
            ),
          );
        }
      },
    );
  }
}