import 'package:ai_teacher_chatbot/ui/views/chat_screen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Helper',
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

