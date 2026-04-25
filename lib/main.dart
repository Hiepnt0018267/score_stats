
import 'package:flutter/material.dart';
import 'package:score_stats/screens/main_screen.dart';
import 'screens/fixtures_tab.dart';

void main() {
  runApp(const ScoreStatsApp());
}

class ScoreStatsApp extends StatelessWidget {
  const ScoreStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Score Stats',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3C1C5A)),
        useMaterial3: true,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}