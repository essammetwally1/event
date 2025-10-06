// lib/models/event_model.dart  (or inside your existing model)
import 'package:cloud_firestore/cloud_firestore.dart';

class EventLocationModel {
  final GeoPoint geopoint; // lat/lng saved as GeoPoint
  final String address; // optional manual text

  const EventLocationModel({required this.geopoint, required this.address});

  Map<String, dynamic> toMap() => {'geopoint': geopoint, 'address': address};

  factory EventLocationModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return EventLocationModel(geopoint: const GeoPoint(0, 0), address: '');
    }
    return EventLocationModel(
      geopoint: map['geopoint'] as GeoPoint,
      address: (map['address'] ?? '') as String,
    );
  }
}
