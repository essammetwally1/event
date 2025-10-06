import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/models/category_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventModel {
  String id;
  String userId;
  String title;
  String description;
  CategoryModel categoryModel;
  DateTime dateTime;
  LatLng? location;
  String? address;

  EventModel({
    this.id = '',
    required this.userId,
    required this.title,
    required this.description,
    required this.categoryModel,
    required this.dateTime,
    this.location,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'categoryid': categoryModel.id,
    'timestamp': Timestamp.fromDate(dateTime),
    'location': location != null
        ? {'latitude': location!.latitude, 'longitude': location!.longitude}
        : null,
    'address': address,
  };

  EventModel.fromJson(Map<String, dynamic> json)
    : this(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        categoryModel: CategoryModel.categoryList.firstWhere(
          (category) => category.id == json['categoryid'],
          orElse: () => CategoryModel.categoryList.first,
        ),
        dateTime: (json['timestamp'] as Timestamp).toDate(),
        location: json['location'] != null
            ? LatLng(
                json['location']['latitude'],
                json['location']['longitude'],
              )
            : null,
        address: json['address'],
      );
}
