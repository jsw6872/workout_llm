import 'package:example/recording.dart';
import 'package:flutter/material.dart';

import '../enumerations.dart';
import '../extension.dart';
import '../widgets/month_view_widget.dart';
import '../widgets/responsive_widget.dart';
import 'create_event_page.dart';
import 'web/web_home_page.dart';

class MonthViewPageDemo extends StatefulWidget {
  const MonthViewPageDemo({
    super.key,
  });

  @override
  _MonthViewPageDemoState createState() => _MonthViewPageDemoState();
}

class _MonthViewPageDemoState extends State<MonthViewPageDemo> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) { // 기록 버튼의 인덱스가 1이라고 가정
      context.pushRoute(RecordingPage());
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      webWidget: WebHomePage(
        selectedView: CalendarView.month,
      ),
      mobileWidget: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          elevation: 8,
          onPressed: () => context.pushRoute(CreateEventPage()),
        ),
        body: MonthViewWidget(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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
        ),
      ),
    );
  }
}
