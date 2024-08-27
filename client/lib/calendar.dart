import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'recording.dart';
import 'loading.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {}; // 날짜별 이벤트를 저장하는 맵

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('캘린더'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3, // 최대 3개의 마커를 표시
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.map((event) {
                      return Container(
                        width: 7.0,
                        height: 7.0,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getCategoryColor((event as Event).category),
                        ),
                      );
                    }).toList(),
                  );
                }
                return null;
              },
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay ?? _focusedDay)
                  .map((event) => ListTile(
                        title: Text(event.title),
                        leading: CircleAvatar(
                          backgroundColor: _getCategoryColor(event.category),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            setState(() {
                              _events[_selectedDay]?.remove(event);
                              if (_events[_selectedDay]?.isEmpty ?? false) {
                                _events.remove(_selectedDay);
                              }
                            });
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDay != null) {
            _showAddEventDialog(context);
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
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

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController _eventController = TextEditingController();
    String _selectedCategory = '빨간색'; // 기본 카테고리 설정

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('할 일 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _eventController,
                    decoration: InputDecoration(labelText: '할 일 입력'),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    items: <String>['빨간색', '파란색', '노란색']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_eventController.text.isNotEmpty) {
                      setState(() {
                        if (_events[_selectedDay] != null) {
                          _events[_selectedDay]!.add(Event(
                            title: _eventController.text,
                            category: _selectedCategory,
                          ));
                        } else {
                          _events[_selectedDay!] = [
                            Event(
                              title: _eventController.text,
                              category: _selectedCategory,
                            )
                          ];
                        }
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '빨간색':
        return Colors.red;
      case '파란색':
        return Colors.blue;
      case '노란색':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}

class Event {
  final String title;
  final String category;

  Event({required this.title, required this.category});
}
