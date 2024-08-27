import 'package:flutter/material.dart';
import 'recording.dart';
import 'loading.dart';

class GymRecordPage extends StatefulWidget {
  @override
  _GymRecordPageState createState() => _GymRecordPageState();
}

class _GymRecordPageState extends State<GymRecordPage> {
  List<SetRecord> setRecords = [SetRecord(setNumber: 1)];

  void _addSet() {
    if (setRecords.length < 10) { // 최대 10개의 세트만 추가 가능
      setState(() {
        setRecords.add(SetRecord(setNumber: setRecords.length + 1));
      });
    }
  }

  void _removeSet(int index) {
    if (setRecords.length > 1) {
      setState(() {
        setRecords.removeAt(index);
        // Set number 재설정
        for (int i = 0; i < setRecords.length; i++) {
          setRecords[i].setNumber = i + 1;
        }
      });
    }
  }

  Widget _buildAddRemoveButton(int index) {
    bool isFirst = index == 0;
    return OutlinedButton(
      onPressed: isFirst ? _addSet : () => _removeSet(index),
      style: OutlinedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(10),
        side: BorderSide(color: Colors.black),
      ),
      child: Icon(isFirst ? Icons.add : Icons.remove, color: Colors.black),
    );
  }

  Widget _buildSetRow(SetRecord setRecord, int index) {
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
          _buildAddRemoveButton(index),
        ],
      ),
    );
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
                      child: SizedBox(
                        height: 40, // 두 번째 SizedBox의 높이
                        child: Center(
                          child: Text(
                            '운동 내용',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey), // 테두리 추가
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
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
                                    items: ['근력', '유산소']
                                        .map((String category) {
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
                                    items: ['가슴', '등', '어깨', '팔', '복근', '하체']
                                        .map((String bodyPart) {
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
                                '(${setRecords.length} / 10)',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 10), // 세트 설정과 세트 리스트 사이의 여백
                          // 세트 설정
                          Column(
                            children: setRecords.asMap().entries.map((entry) {
                              int index = entry.key;
                              SetRecord setRecord = entry.value;
                              return _buildSetRow(setRecord, index);
                            }).toList(),
                          ),
                        ],
                      ),
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

class SetRecord {
  int setNumber;

  SetRecord({required this.setNumber});
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