import 'package:event/components/event_item.dart';
import 'package:event/home_tab/home_header.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HomeHeader(),
          SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (_, index) => EventItem(),
              separatorBuilder: (_, _) => SizedBox(height: 8),
              itemCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}
