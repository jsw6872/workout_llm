import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'record_loading.dart';
import 'recommend.dart';
import 'recording.dart';

class CalendarPage extends StatefulWidget {
  final List<Event>? newEvents;

  CalendarPage({this.newEvents});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents(); // 앱 시작 시 이벤트 데이터를 로드

    if (widget.newEvents != null && widget.newEvents!.isNotEmpty) {
      _addEvents(widget.newEvents!);
    }
  }

  void _addEvents(List<Event> events) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (var event in events) {
      final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
      final normalizedDate = DateTime(eventDate.year, eventDate.month, eventDate.day);

      if (_events[normalizedDate] != null) {
        _events[normalizedDate]!.add(event);
      } else {
        _events[normalizedDate] = [event];
      }
    }

    // 이벤트 데이터를 SharedPreferences에 저장
    _saveEvents();
  }

  Future<void> _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString('events');

    if (encodedData != null) {
      Map<String, dynamic> decodedData = json.decode(encodedData);
      _events = decodedData.map((key, value) => MapEntry(
          DateTime.parse(key),
          (value as List).map((e) => Event.fromMap(e)).toList()));
      setState(() {});
    }
  }

  Future<void> _saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedData = json.encode(_events.map((key, value) => MapEntry(
        key.toString(), value.map((e) => e.toMap()).toList())));
    await prefs.setString('events', encodedData);
  }

  void _deleteEvent(Event event) {
    setState(() {
      final normalizedDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      _events[normalizedDay]?.remove(event);
      if (_events[normalizedDay]?.isEmpty ?? false) {
        _events.remove(normalizedDay);
      }
    });
    // 삭제 후 업데이트된 데이터 저장
    _saveEvents();
  }

  Future<void> _getRecommendedWorkouts(BuildContext context) async {
    String url = 'http://10.0.2.2:8080/llm/fake-recommended-workouts';

    // 로딩 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReloadLoadingPage()),
    );

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩
        // 로딩 페이지를 닫고 추천 페이지로 이동
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendPage(
              data: jsonResponse,
            ),
          ),
        );
      } else {
        print('Failed to get recommendations. Status code: ${response.statusCode}');
        Navigator.pop(context);  // 에러 시에도 로딩 페이지를 닫음
      }
    } catch (e) {
      print('Error occurred while getting recommendations: $e');
      Navigator.pop(context);  // 에러 시에도 로딩 페이지를 닫음
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '캘린더',
          style: TextStyle(fontWeight: FontWeight.bold), // '캘린더' 텍스트를 bold로 설정
        ),
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
              markersMaxCount: 3,
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
            child: _selectedDay != null && _getEventsForDay(_selectedDay!).isNotEmpty
                ? ListView.builder(
              itemCount: _getEventsForDay(_selectedDay!).length,
              itemBuilder: (context, index) {
                final event = _getEventsForDay(_selectedDay!)[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(event.title),
                      subtitle: Text(event.details.replaceAll(', ', '\n')), // 줄바꿈 처리
                      leading: Icon(Icons.star, color: _getCategoryColor(event.category)), // 별 모양 아이콘으로 변경
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          _deleteEvent(event);
                        },
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Text(
                '선택한 날짜에 운동 기록이 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
                  builder: (context) => RecordingPage(),
                ),
              );
              break;
            case 2:
              _getRecommendedWorkouts(context);  // 추천 요청
              break;
          }
        },
      ),
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '빨간색':
        return Colors.red;
      case '파란색':
        return Colors.blue;
      case '노란색':
        return Colors.yellow;
      case '초록색':
        return Colors.green;
      case '검정색':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}

class Event {
  final String title;
  final String category;
  final DateTime date;
  final String details;

  Event({
    required this.title,
    required this.category,
    required this.date,
    required this.details,
  });

  // JSON으로 변환하기 위한 메서드
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'date': date.toIso8601String(),
      'details': details,
    };
  }

  // JSON에서 객체를 생성하기 위한 메서드
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      title: map['title'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      details: map['details'],
    );
  }
}
