import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart'; // AssetBundle 사용을 위해 추가
import 'gym_record.dart';
import 'loading.dart';
import 'package:path_provider/path_provider.dart'; // path_provider 사용

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
    // 1. assets 폴더에서 파일을 로드합니다.
    final ByteData data = await rootBundle.load('assets/mp4/workout_content_test.mp3');

    // 2. 임시 디렉토리에 파일을 저장합니다.
    final directory = await getTemporaryDirectory();
    String filePath = '${directory.path}/output.mp3';
    final File file = File(filePath);
    await file.writeAsBytes(data.buffer.asUint8List());

    String url = 'http://10.0.2.2:8080/whisper/audio-to-workout-content';

    // 3. 서버 요청 후 로딩 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadingPage(index: 1)),
    );

    try {
      // 4. Multipart request를 생성하여 MP3 파일을 전송합니다.
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // 5. 서버에 요청을 보내고 응답을 기다립니다.
      var response = await request.send();

      if (response.statusCode == 200) {
        // 응답이 성공적이면 GymRecordPage로 이동
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);

        // GymRecordPage로 jsonResponse 데이터를 함께 넘겨줍니다.
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GymRecordPage(data: jsonResponse), // GymRecordPage로 jsonResponse 전달
          ),
        );
      } else {
        print('Failed to upload audio file. Status code: ${response.statusCode}');
        Navigator.pop(context); // 로딩 페이지 닫기
      }
    } catch (e) {
      print('Error occurred while sending audio: $e');
      Navigator.pop(context); // 로딩 페이지 닫기
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<SetRecord> setRecords = [SetRecord(setNumber: 1)];

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '운동 내용을 말해주세요.',
              style: TextStyle(fontSize: 24),
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
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.8 - _animation.value,
                    height: screenWidth * 0.8 - _animation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
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
                style: GoogleFonts.notoSansGothic(), // 한글 폰트 적용
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
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoadingPage(index: setRecords.length),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}

