import 'package:flutter/material.dart';

class ReloadLoadingPage extends StatefulWidget {
  @override
  _ReloadLoadingPageState createState() => _ReloadLoadingPageState();
}

class _ReloadLoadingPageState extends State<ReloadLoadingPage> with SingleTickerProviderStateMixin {
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
            // 모래시계 아이콘 표시 (크기를 키움)
            RotationTransition(
              turns: _controller,
              child: Icon(
                Icons.hourglass_empty,
                size: 100,  // 마이크 아이콘 크기와 유사하게 크기 조정
                color: Colors.blueAccent
              ),
            ),
            SizedBox(height: 20),  // 모래시계와 텍스트 사이의 간격 조정
            // 응답을 기다리는 중 ... 텍스트 추가
            Text(
              '응답을 기다리는 중...',
              style: TextStyle(fontSize: 18, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
