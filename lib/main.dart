import 'package:flutter/material.dart';
import 'main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'D-ID Agent',
    theme: ThemeData(colorSchemeSeed: Colors.blue),
    debugShowCheckedModeBanner: false,
    home: const MainPage(),
  );
}
