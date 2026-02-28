import 'package:flutter/material.dart';
import 'screens/compare_screen.dart';

void main() {
  runApp(const MarketAnalyzerApp());
}

class MarketAnalyzerApp extends StatefulWidget {
  const MarketAnalyzerApp({super.key});

  @override
  State<MarketAnalyzerApp> createState() => _MarketAnalyzerAppState();
}

class _MarketAnalyzerAppState extends State<MarketAnalyzerApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Market Analyzer Pro', // Numele oficial al ferestrei
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F1218),
        cardTheme: const CardThemeData(
          color: Color(0xFF1C222D),
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      home: CompareScreen(onThemeToggle: _toggleTheme),
    );
  }
}