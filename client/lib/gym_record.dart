import 'package:flutter/material.dart';
import 'calendar.dart';
import 'package:intl/intl.dart';
import 'recording.dart';

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

class GymRecordPage extends StatefulWidget {
  final DateTime selectedDate;
  final Function(List<Event>) onSave;
  final Map<String, dynamic> data;

  GymRecordPage({
    required this.selectedDate,
    required this.onSave,
    this.data = const {},
  });

  @override
  _GymRecordPageState createState() => _GymRecordPageState();
}

class _GymRecordPageState extends State<GymRecordPage> {
  List<ExerciseSection> exerciseSections = [];
  String formattedDate = '';

  @override
  void initState() {
    super.initState();

    DateTime? actualDate; // JSON에서 받은 실제 날짜

    if (widget.data.containsKey('date') && widget.data.containsKey('day')) {
      String dateStr = widget.data['date'];
      String dayStr = widget.data['day'];

      actualDate = DateTime.parse(dateStr); // 실제 날짜
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

    print("Total number of exercises: ${exerciseSections.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          formattedDate,
          style: TextStyle(fontWeight: FontWeight.bold), // 날짜 부분 Bold 처리
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // 여기서 실제 날짜를 사용하여 이벤트를 생성합니다.
              List<Event> newEvents = exerciseSections.map((section) {
                return Event(
                  title: '${section.bodyPart} - ${section.exerciseName}',
                  category: _getCategoryForBodyPart(section.bodyPart),
                  date: DateTime.parse(widget.data['date']), // 실제 날짜 사용
                  details: section.setRecords
                      .map((set) => 'Set ${set.setNumber}: ${set.weight} ${set.unit} x ${set.reps}회')
                      .join(', '),
                );
              }).toList();

              widget.onSave(newEvents);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarPage(newEvents: newEvents),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exerciseSections.map((section) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // 박스 안의 배경색을 연한 회색으로
                          border: Border.all(color: Colors.grey, width: 2.0), // 박스의 테두리를 굵게
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(2, 2), // 그림자를 오른쪽 아래로 추가
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: _buildExerciseSection(section),
                      ),
                    );
                  }).toList(),
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

  String _getCategoryForBodyPart(String bodyPart) {
    switch (bodyPart) {
      case '등':
        return '빨간색';
      case '팔':
        return '파란색';
      case '가슴':
        return '초록색';
      case '하체':
        return '노란색';
      case '코어':
        return '검정색';
      default:
        return '회색';
    }
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
              Text('🏋🏼‍♂️ 운동 종목: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Bold 처리
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
