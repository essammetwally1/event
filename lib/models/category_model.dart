import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String label;
  final IconData icon;
  final String imageName;

  CategoryModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.imageName,
  });
  static List<CategoryModel> categoryList = [
    CategoryModel(
      id: '1',
      label: 'Sport',
      icon: Icons.sports,
      imageName: 'sports',
    ),
    CategoryModel(
      id: '2',
      label: 'Birthday',
      icon: Icons.cake_outlined,
      imageName: 'birthday',
    ),
    CategoryModel(
      id: '3',
      label: 'Book Club',
      icon: Icons.book_online,
      imageName: 'bookclub',
    ),
    CategoryModel(
      id: '4',
      label: 'Eating',
      icon: Icons.food_bank_outlined,
      imageName: 'eating',
    ),
    CategoryModel(
      id: '5',
      label: 'Exhibition',
      icon: Icons.museum_outlined,
      imageName: 'exhibition',
    ),
    CategoryModel(
      id: '6',
      label: 'Gaming',
      icon: Icons.games_outlined,
      imageName: 'gaming',
    ),
    CategoryModel(
      id: '7',
      label: 'Holiday',
      icon: Icons.holiday_village_outlined,
      imageName: 'holiday',
    ),
    CategoryModel(
      id: '8',
      label: 'Meeting',
      icon: Icons.meeting_room_outlined,
      imageName: 'meeting',
    ),
    CategoryModel(
      id: '9',
      label: 'Work Shop',
      icon: Icons.workspace_premium_outlined,
      imageName: 'workshop',
    ),
  ];
}
