import 'package:flutter/material.dart';
import 'calendar.dart';
import 'recording.dart';
import 'package:intl/intl.dart';

// ExerciseSection 클래스 정의
class ExerciseSection {
  final int index;
  String category;
  String bodyPart;
  String exerciseName;
  List<SetRecord> setRecords;

  ExerciseSection(
      this.index, {
        required this.category,
        required this.bodyPart,
        required this.exerciseName,
        required List<dynamic> sets,
      }) : setRecords = sets
      .asMap()
      .entries
      .map((entry) => SetRecord(
    setNumber: entry.key + 1,
    weight: entry.value[0].toString(),
    unit: entry.value[1].toString(),
    reps: entry.value[2],
  ))
      .toList();
}

// SetRecord 클래스 정의
class SetRecord {
  int setNumber;
  String weight;
  String unit;
  int reps;

  SetRecord({
    required this.setNumber,
    required this.weight,
    required this.unit,
    required this.reps,
  });
}

class RecommendPage extends StatefulWidget {
  final Map<String, dynamic> data;

  RecommendPage({required this.data});

  @override
  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  List<ExerciseSection> exerciseSections = [];
  String formattedDate = '';
  List<String> comments = [];

  @override
  void initState() {
    super.initState();

    DateTime? actualDate;

    if (widget.data.containsKey('date') && widget.data.containsKey('day')) {
      String dateStr = widget.data['date'];
      String dayStr = widget.data['day'];

      actualDate = DateTime.parse(dateStr);
      formattedDate = DateFormat('yyyy년 MM월 dd일').format(actualDate) + ' ' + dayStr;
    }

    if (widget.data.containsKey('exercises')) {
      Map<String, dynamic> exercises = widget.data['exercises'];

      exercises.forEach((category, bodyParts) {
        bodyParts.forEach((bodyPart, exerciseList) {
          if (exerciseList is Map<String, dynamic>) {
            exerciseList.forEach((exerciseName, sets) {
              exerciseSections.add(ExerciseSection(
                exerciseSections.length,
                category: category,
                bodyPart: bodyPart,
                exerciseName: exerciseName,
                sets: sets,
              ));
            });
          }
        });
      });
    }

    if (widget.data.containsKey('comments')) {
      comments = List<String>.from(widget.data['comments']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formattedDate,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '추천 운동',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🤖 참고하세요! 참고 하세요.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...comments.map((comment) => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('✅ ' + comment, style: TextStyle(fontSize: 15)),
                    )),
                    SizedBox(height: 25),
                    ...exerciseSections.map((section) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // 박스의 배경색을 연한 회색으로 설정
                            border: Border.all(color: Colors.lightGreen, width: 2), // 박스의 테두리 색을 설정
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(1, 1), // 그림자를 오른쪽 아래로 추가
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: _buildExerciseSection(section),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarPage(newEvents: []),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RecordingPage(),
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

  Widget _buildExerciseSection(ExerciseSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text('💪🏼 운동 종류: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Bold 처리
              SizedBox(width: 10),
              Expanded(child: Text(section.category)),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text('🔥 운동 부위: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Bold 처리
              SizedBox(width: 10),
              Expanded(child: Text(section.bodyPart)),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text('🏼‍♂️ 운동 종목: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Bold 처리
              SizedBox(width: 10),
              Expanded(child: Text(section.exerciseName)),
            ],
          ),
        ),
        Divider(color: Colors.grey, thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('세트 설정', style: TextStyle(fontSize: 12)),
            Text('(${section.setRecords.length} / 10)', style: TextStyle(fontSize: 12)),
          ],
        ),
        SizedBox(height: 10),
        Column(
          children: section.setRecords.asMap().entries.map((entry) {
            int index = entry.key;
            SetRecord setRecord = entry.value;
            return _buildSetRow(setRecord, index, section);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSetRow(SetRecord setRecord, int index, ExerciseSection section) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('Set ${setRecord.setNumber}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Bold 처리
          SizedBox(width: 20),
          Expanded(child: Text('${setRecord.weight} ${setRecord.unit}')),
          SizedBox(width: 20),
          Expanded(child: Text('${setRecord.reps} 회')),
        ],
      ),
    );
  }
}
