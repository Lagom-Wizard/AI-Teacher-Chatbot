import 'dart:io';
import 'package:ai_teacher_chatbot/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

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

