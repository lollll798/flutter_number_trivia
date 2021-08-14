import 'package:clean_arch_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter/material.dart';

import 'features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'injection_container.dart' as container;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await container.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[800],
        ),
        accentColor: Colors.green[600],
      ),
      home: NumberTriviaPage(),
    );
  }
}
