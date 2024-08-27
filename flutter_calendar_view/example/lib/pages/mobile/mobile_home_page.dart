import 'package:flutter/material.dart';

import '../../extension.dart';
import '../day_view_page.dart';
import '../month_view_page.dart';
import '../week_view_page.dart';

class MobileHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("운동 일기"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.pushRoute(MonthViewPageDemo()),
              child: Text("시작하기"),
            ),
            // SizedBox(
            //   height: 20,
            // ),
            // ElevatedButton(
            //   onPressed: () => context.pushRoute(DayViewPageDemo()),
            //   child: Text("Day View"),
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            // ElevatedButton(
            //   onPressed: () => context.pushRoute(WeekViewDemo()),
            //   child: Text("Week View"),
            // ),
          ],
        ),
      ),
    );
  }
}
