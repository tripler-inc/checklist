import 'package:checklist/repositories/theme_repository.dart';
import 'package:checklist/screens/checklist_screen.dart';
import 'package:flutter/material.dart';

class ChecklistApp extends StatefulWidget {
  const ChecklistApp({
    super.key,
    ThemeRepository? themeRepository,
  }) : _themeRepository = themeRepository ?? const ThemeRepository();

  final ThemeRepository _themeRepository;

  @override
  State<ChecklistApp> createState() => _ChecklistAppState();
}

class _ChecklistAppState extends State<ChecklistApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await widget._themeRepository.loadThemeMode();
    setState(() {
      _themeMode = mode;
    });
  }

  Future<void> _saveThemeMode(ThemeMode mode) {
    return widget._themeRepository.saveThemeMode(mode);
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    _saveThemeMode(_themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: ChecklistScreen(onToggleTheme: _toggleTheme),
    );
  }
}
