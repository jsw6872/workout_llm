import 'package:flutter/material.dart';
import 'recording.dart';

class LoadingPage extends StatefulWidget {
  final int index;

  LoadingPage({required this.index});

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
            // 첫 번째 컨테이너: 날짜 표시
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
            // 두 번째 컨테이너: 추천 메시지 표시
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '이전의 ${widget.index}일간의 운동 내용을 바탕으로 운동 내용을 추천하는 중입니다 ....',
                style: TextStyle(fontSize: 18, color: Colors.orange),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40), // 텍스트와 모래시계 사이의 간격을 조정합니다
            // 세 번째 컨테이너: 모래시계 아이콘 표시 (애니메이션 적용)
            RotationTransition(
              turns: _controller,
              child: Icon(
                Icons.hourglass_empty,
                size: 60,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: '기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: '추천',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
            // 홈 탭 클릭 시 동작
              break;
            case 1:
            // 기록 탭 클릭 시 동작 - RecordingPage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecordingPage()),
              );
              break;
            case 2:
            // 추천 탭 클릭 시 동작
              break;
          }
        },
      ),
    );
  }
}