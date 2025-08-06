import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/models/event_model.dart';

class FirebaseService {
  static CollectionReference<EventModel> getEventsCollection() =>
      FirebaseFirestore.instance
          .collection('event')
          .withConverter<EventModel>(
            fromFirestore: (docSnapshot, _) =>
                EventModel.fromJson(docSnapshot.data()!),
            toFirestore: (event, _) => event.toJson(),
          );

  static Future<void> createEvent(EventModel event) {
    CollectionReference<EventModel> eventsCollection = getEventsCollection();
    DocumentReference<EventModel> docs = eventsCollection.doc();
    event.id = docs.id;
    return docs.set(event);
  }

  static Future<List<EventModel>> getEvents() async {
    CollectionReference<EventModel> eventsCollection = getEventsCollection();
    QuerySnapshot<EventModel> querySnapshot = await eventsCollection
        .orderBy('timestamp')
        .get();
    List<QueryDocumentSnapshot<EventModel>> docs = querySnapshot.docs;
    List<EventModel> events = docs.map((event) => event.data()).toList();
    return events;
  }

  static Future<bool> deleteEvent(String eventId) async {
    CollectionReference<EventModel> eventsCollection = getEventsCollection();
    try {
      eventsCollection.doc(eventId).delete().then((_) => true);
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  static Future<void> updateEvent(EventModel event) async {
    CollectionReference<EventModel> eventsCollection = getEventsCollection();
    eventsCollection.doc(event.id).update(event.toJson());
  }
}
