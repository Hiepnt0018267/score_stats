// File: lib/main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_screen.dart'; // Trỏ tới file chứa giao diện chính

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Đánh thức Firebase
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livescore Ngoại Hạng Anh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3C1C5A),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF3C1C5A),
          secondary: const Color(0xFFE90052),
        ),
      ),
      home: const MainScreen(), // Gọi màn hình chính
    );
  }
}