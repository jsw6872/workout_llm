import 'package:flutter/material.dart';
import 'recording.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Multi-Page App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecordingPage(), // 여기서 GymPage를 실행합니다.
    );
  }
}