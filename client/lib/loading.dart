import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();  // 애니메이션을 반복하도록 설정
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 120, // 필요에 따라 높이를 조정하세요
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '2024년 8월 27일',
                    style: TextStyle(fontSize: 24, color: Colors.orange),
                  ),
                  Text(
                    '2024년 8월 28일',
                    style: TextStyle(fontSize: 24, color: Colors.orange),
                  ),
                  Text(
                    '2024년 8월 29일',
                    style: TextStyle(fontSize: 24, color: Colors.orange),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40), // 날짜와 텍스트 사이의 간격을 조정합니다
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '응답을 기다리는 중입니다 ...',
                style: TextStyle(fontSize: 18, color: Colors.orange),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40), // 텍스트와 모래시계 사이의 간격을 조정합니다
            RotationTransition(
              turns: _controller,
              child: Icon(
                Icons.hourglass_empty,
                size: 60, // 모래시계 아이콘 크기
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
