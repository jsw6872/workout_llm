import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'gym_record.dart';
import 'loading.dart';
import 'pages/month_view_page.dart';
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
    final ByteData data = await rootBundle.load('assets/mp4/workout_content_test.mp3');

    final directory = await getTemporaryDirectory();
    String filePath = '${directory.path}/output.mp3';
    final File file = File(filePath);
    await file.writeAsBytes(data.buffer.asUint8List());

    String url = 'http://10.0.2.2:8080/whisper/audio-to-workout-content';

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadingPage(index: 1)),
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
          MaterialPageRoute(builder: (context) => GymRecordPage()),
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
                style: GoogleFonts.notoSansGothic(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // 기록 버튼을 활성화 상태로 설정
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
          setState(() {
            if (index == 0) {
              // 홈 버튼이 눌렸을 때 MonthViewPageDemo로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MonthViewPageDemo()),
              );
            } else if (index == 1) {
              // 기록 버튼이 눌렸을 때는 기록 버튼을 활성화된 상태로 유지
              _stopRecording();
              _sendAudioToServer(context);
            } else if (index == 2) {
              // 추천 버튼이 눌렸을 때 동작 추가
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoadingPage(index: setRecords.length),
                ),
              );
            }
          });
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'gym_record.dart';
// import 'loading.dart';
// import 'package:path_provider/path_provider.dart';
//
// class RecordingPage extends StatefulWidget {
//   @override
//   _RecordingPageState createState() => _RecordingPageState();
// }
//
// class _RecordingPageState extends State<RecordingPage> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   bool isRecording = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 1),
//     );
//
//     _animation = Tween<double>(begin: 0.0, end: 100.0).animate(_controller)
//       ..addListener(() {
//         setState(() {});
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _startRecording() {
//     setState(() {
//       isRecording = true;
//     });
//     _controller.repeat(reverse: true);
//   }
//
//   void _stopRecording() {
//     setState(() {
//       isRecording = false;
//     });
//     _controller.reset();
//   }
//
//   Future<void> _sendAudioToServer(BuildContext context) async {
//     final ByteData data = await rootBundle.load('assets/mp4/workout_content_test.mp3');
//
//     final directory = await getTemporaryDirectory();
//     String filePath = '${directory.path}/output.mp3';
//     final File file = File(filePath);
//     await file.writeAsBytes(data.buffer.asUint8List());
//
//     String url = 'http://10.0.2.2:8080/whisper/audio-to-workout-content';
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => LoadingPage(index: 1)),
//     );
//
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(url));
//       request.files.add(await http.MultipartFile.fromPath('file', file.path));
//
//       var response = await request.send();
//
//       if (response.statusCode == 200) {
//         var responseBody = await response.stream.bytesToString();
//         var jsonResponse = json.decode(responseBody);
//
//         Navigator.popUntil(context, (route) => route.isFirst);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => GymRecordPage()),
//         );
//       } else {
//         print('Failed to upload audio file. Status code: ${response.statusCode}');
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       print('Error occurred while sending audio: $e');
//       Navigator.pop(context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     List<SetRecord> setRecords = [SetRecord(setNumber: 1)];
//
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               '운동 내용을 말해주세요.',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 20),
//             GestureDetector(
//               onTap: () {
//                 if (isRecording) {
//                   _stopRecording();
//                 } else {
//                   _startRecording();
//                 }
//               },
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Container(
//                     width: screenWidth * 0.8,
//                     height: screenWidth * 0.8,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.blue.withOpacity(0.3),
//                     ),
//                   ),
//                   Container(
//                     width: screenWidth * 0.8 - _animation.value,
//                     height: screenWidth * 0.8 - _animation.value,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.blue,
//                     ),
//                     child: Icon(
//                       Icons.mic,
//                       size: screenWidth * 0.4,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _stopRecording();
//                 _sendAudioToServer(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 textStyle: TextStyle(fontSize: 20),
//               ),
//               child: Text(
//                 '완료',
//                 style: GoogleFonts.notoSansGothic(),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 1, // 기록 버튼을 활성화 상태로 설정
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: '홈',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.mic),
//             label: '기록',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.star),
//             label: '추천',
//           ),
//         ],
//         onTap: (index) {
//           setState(() {
//             if (index == 1) {
//               // 기록 버튼이 눌렸을 때는 기록 버튼을 활성화된 상태로 유지
//               _stopRecording();
//               _sendAudioToServer(context);
//             } else if (index == 0) {
//               // 홈 버튼이 눌렸을 때 동작 추가 (예: 홈 화면으로 이동)
//               Navigator.popUntil(context, (route) => route.isFirst);
//             } else if (index == 2) {
//               // 추천 버튼이 눌렸을 때 동작 추가
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => LoadingPage(index: setRecords.length),
//                 ),
//               );
//             }
//           });
//         },
//       ),
//     );
//   }
// }
