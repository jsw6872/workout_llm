import 'package:flutter/material.dart';
import 'recording.dart';
import 'calendar.dart';

class GymRecordPage extends StatefulWidget {
  final DateTime selectedDate;
  final Function(Event) onSave;
  final Map<String, dynamic> data; // jsonResponse 데이터를 받을 변수 추가

  GymRecordPage({
    required this.selectedDate,
    required this.onSave,
    this.data = const {},
  });

  @override
  _GymRecordPageState createState() => _GymRecordPageState();
}

class _GymRecordPageState extends State<GymRecordPage> {
  List<ExerciseSection> exerciseSections = []; // 운동 섹션 리스트

  @override
  void initState() {
    super.initState();

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

    // 총 운동 종목 개수 출력
    print("Total number of exercises: ${exerciseSections.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기록 생성하기'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // 저장 버튼 클릭 시 이벤트를 캘린더로 전달
              widget.onSave(Event(
                title: '운동 기록',
                category: '빨간색', // 예시로 설정된 카테고리
              ));
              Navigator.pop(context); // 저장 후 이전 화면으로 돌아가기
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
                          border: Border.all(color: Colors.grey), // 테두리 추가
                          borderRadius: BorderRadius.circular(5.0),
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
              // "추천" 탭 클릭 시 CalendarPage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarPage(), // CalendarPage로 이동
                ),
              );
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
        // 운동 종류 선택
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text('운동 종류: ', style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Expanded(
                child: Text(section.category),
              ),
            ],
          ),
        ),
        // 운동 부위 선택
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text('운동 부위: ', style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Expanded(
                child: Text(section.bodyPart),
              ),
            ],
          ),
        ),
        // 운동 종목 입력
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text('운동 종목: ', style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Expanded(
                child: Text(section.exerciseName),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.grey, // 회색 선
          thickness: 1, // 선 두께
        ),
        // 세트 설정 및 숫자 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('세트 설정', style: TextStyle(fontSize: 12)),
            Text(
              '(${section.setRecords.length} / 10)',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 10), // 세트 설정과 세트 리스트 사이의 여백
        // 세트 설정
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
          Text('Set ${setRecord.setNumber}', style: TextStyle(fontSize: 16)),
          SizedBox(width: 20),
          Expanded(
            child: Text('${setRecord.weight} ${setRecord.unit}'),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text('${setRecord.reps} 회'),
          ),
        ],
      ),
    );
  }
}

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
                  weight: entry.value[0].toString(), // weight 매개변수 추가
                  unit: entry.value[1].toString(), // unit 매개변수 추가
                  reps: entry.value[2], // reps 매개변수 추가
                ))
            .toList();
}

class DatePickerField extends StatefulWidget {
  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _controller.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: '날짜 선택',
        hintText: '날짜를 선택하세요',
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
    );
  }
}
