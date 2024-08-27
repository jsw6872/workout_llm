import 'package:flutter/material.dart';
import 'recording.dart';
import 'loading.dart';

class GymRecordPage extends StatefulWidget {
  final Map<String, dynamic> data; // jsonResponse 데이터를 받을 변수 추가

  GymRecordPage({this.data = const {}}); // 생성자에 data를 추가

  @override
  _GymRecordPageState createState() => _GymRecordPageState();
}

class _GymRecordPageState extends State<GymRecordPage> {
  List<ExerciseSection> exerciseSections = [ExerciseSection(0)]; // 운동 섹션 리스트
  int currentIndex = 0; // 현재 보고 있는 운동 섹션의 인덱스

  @override
  void initState() {
    super.initState();

    // 운동 종목의 총 개수를 계산
    int totalExercises = 0;

    if (widget.data.containsKey('exercises')) {
      Map<String, dynamic> exercises = widget.data['exercises'];

      // 각 카테고리와 부위에 대해 반복하여 운동 종목 개수를 계산
      exercises.forEach((category, bodyParts) {
        bodyParts.forEach((bodyPart, exerciseList) {
          if (exerciseList is Map<String, dynamic>) {  // 이 부분에서 명확하게 타입을 지정
            totalExercises += exerciseList.keys.length;
          }
        });
      });
    }

    // 총 운동 종목 개수 출력
    print("Total number of exercises: $totalExercises");
    print("Received JSON Response: ${widget.data["exercises"]}");
  }

  void _addExerciseSection() {
    setState(() {
      exerciseSections.add(ExerciseSection(exerciseSections.length));
      currentIndex = exerciseSections.length - 1;
    });
  }

  void _nextSection() {
    if (currentIndex < exerciseSections.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      _addExerciseSection();
    }
  }

  void _previousSection() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기록 생성하기'),
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
                    SizedBox(
                      height: 100, // 첫 번째 SizedBox의 높이
                      child: DatePickerField(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0), // 상하로 5의 마진 추가
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${exerciseSections[currentIndex].index+1}번째 운동내용',
                            style: TextStyle(fontSize: 20),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_left),
                                onPressed: _previousSection,
                                color: currentIndex > 0 ? Colors.black : Colors.grey,
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_right),
                                onPressed: _nextSection,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey), // 테두리 추가
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: _buildExerciseSection(exerciseSections[currentIndex]),
                    ),
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
            // 추천 탭 클릭 시 동작 - LoadingPage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoadingPage(index: exerciseSections.length),
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
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ['근력', '유산소'].map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (newValue) {},
                ),
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
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ['가슴', '등', '어깨', '팔', '복근', '하체'].map((String bodyPart) {
                    return DropdownMenuItem(
                      value: bodyPart,
                      child: Text(bodyPart),
                    );
                  }).toList(),
                  onChanged: (newValue) {},
                ),
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
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '운동 종목 입력',
                  ),
                ),
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
        child: TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                'kg',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            suffixIconConstraints: BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 16),
        ),
      ),
      SizedBox(width: 20),
      Expanded(
        child: TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                '회',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            suffixIconConstraints: BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 16),
        ),
      ),
      SizedBox(width: 20),
      _buildAddRemoveButton(index, section),
    ],
    ),
    );
  }

  Widget _buildAddRemoveButton(int index, ExerciseSection section) {
    bool isFirst = index == 0;
    return OutlinedButton(
      onPressed: isFirst ? () => _addSet(section) : () => _removeSet(index, section),
      style: OutlinedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(10),
        side: BorderSide(color: Colors.black),
      ),
      child: Icon(isFirst ? Icons.add : Icons.remove, color: Colors.black),
    );
  }

  void _addSet(ExerciseSection section) {
    setState(() {
      if (section.setRecords.length < 10) {
        section.setRecords.add(SetRecord(setNumber: section.setRecords.length + 1));
      }
    });
  }

  void _removeSet(int index, ExerciseSection section) {
    setState(() {
      if (section.setRecords.length > 1) {
        section.setRecords.removeAt(index);
        for (int i = 0; i < section.setRecords.length; i++) {
          section.setRecords[i].setNumber = i + 1;
        }
      }
    });
  }
}

class SetRecord {
  int setNumber;

  SetRecord({required this.setNumber});
}

class ExerciseSection {
  final int index;
  List<SetRecord> setRecords;

  ExerciseSection(this.index) : setRecords = [SetRecord(setNumber: 1)];
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

