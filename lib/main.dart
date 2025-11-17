import 'package:flutter/material.dart';
import 'services/note_service.dart';
import 'screens/home_screen.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notesService = NotesService();
  await notesService.initialize();
  runApp(MyApp(notesService: notesService));
}

class MyApp extends StatefulWidget {
  final NotesService notesService;

  const MyApp({super.key, required this.notesService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notes',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(notesService: widget.notesService),
    );
  }
}