import 'package:flutter/material.dart';
// import 'package:souvenir/screens/journal_entry_screen.dart';
import 'package:souvenir/screens/journal_writing_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: JournalWritingScreen(title: ""),
    );
  }
}
