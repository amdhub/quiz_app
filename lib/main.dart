import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/home_page.dart';
import 'package:quiz_app/quiz_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => QuizProvider(), // Context not needed here
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Cannot be const because ThemeData with primarySwatch is not const
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const HomePage(), // Assuming HomePage will have a const constructor
    );
  }
}


