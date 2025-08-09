import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/models/category_model.dart';

class EventModel {
  String id;
  String userId;
  String title;
  String description;
  CategoryModel categoryModel;
  DateTime dateTime;
  EventModel({
    this.id = '',
    required this.userId,
    required this.title,
    required this.description,
    required this.categoryModel,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'categoryid': categoryModel.id,
    'timestamp': Timestamp.fromDate(dateTime),
  };

  EventModel.fromJson(Map<String, dynamic> json)
    : this(
        id: json['id'],
        userId: json['userId'],
        title: json['title'],
        description: json['description'],
        categoryModel: CategoryModel.categoryList.firstWhere(
          (category) => category.id == json['categoryid'],
        ),
        dateTime: (json['timestamp'] as Timestamp).toDate(),
      );
}
