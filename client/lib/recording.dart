import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'gym_record.dart';
import 'record_loading.dart';
import 'calendar.dart';
import 'package:path_provider/path_provider.dart';

class RecordingPage extends StatefulWidget {
  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0.0, end: 100.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      isRecording = true;
    });
    _controller.repeat(reverse: true);
  }

  void _stopRecording() {
    setState(() {
      isRecording = false;
    });
    _controller.reset();
  }

  Future<void> _sendAudioToServer(BuildContext context) async {
    final ByteData data = await rootBundle.load('assets/mp4/workout_content_0827.mp3');

    final directory = await getTemporaryDirectory();
    String filePath = '${directory.path}/output.mp3';
    final File file = File(filePath);
    await file.writeAsBytes(data.buffer.asUint8List());

    String url = 'http://10.0.2.2:8080/whisper/audio-to-workout-content';

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReloadLoadingPage()),
    );

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);

        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GymRecordPage(
              selectedDate: DateTime.now(), // 여기에 올바른 날짜를 넘겨야 합니다.
              onSave: (newEvent) {
                // 여기에 이벤트 저장 로직 추가
              },
              data: jsonResponse, // 이 부분을 추가하여 데이터를 전달
            ),
          ),
        );
      } else {
        print('Failed to upload audio file. Status code: ${response.statusCode}');
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error occurred while sending audio: $e');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                '운동 내용을 말해주세요.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (isRecording) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(0, 38, 78, 0.5)
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.8 - _animation.value,
                    height: screenWidth * 0.8 - _animation.value,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(0, 38, 78, 1)
                    ),
                    child: Icon(
                      Icons.mic,
                      size: screenWidth * 0.4,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _stopRecording();
                _sendAudioToServer(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text(
                '완료',
                style: TextStyle(color: Colors.black), // 텍스트 색상을 파란색으로 설정
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
        currentIndex: 0, // 기본 선택 아이템 설정 (첫 번째 아이템 선택)
        selectedItemColor: Colors.blue, // 선택된 아이템의 색상을 파란색으로 설정
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템의 색상 설정
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarPage(newEvents: []),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecordingPage(), // 기록 페이지로 이동
                ),
              );
              break;
            case 2:
              break;
          }
        },
      ),
    );
  }
}
