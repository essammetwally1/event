import 'package:event/components/custom_textfield.dart';
import 'package:event/components/event_item.dart';
import 'package:flutter/material.dart';

class LoveTab extends StatelessWidget {
  static const String routeName = '/love';
  const LoveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CustomTextFormField(
                hintText: 'Search For Event',
                iconPathName: 'search',
                onChange: (query) {},
              ),
            ),
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
      ),
    );
  }
}
