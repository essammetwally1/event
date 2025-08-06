import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/models/event_model.dart';
import 'package:event/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static CollectionReference<EventModel> getEventsCollection() =>
      FirebaseFirestore.instance
          .collection('event')
          .withConverter<EventModel>(
            fromFirestore: (docSnapshot, _) =>
                EventModel.fromJson(docSnapshot.data()!),
            toFirestore: (event, _) => event.toJson(),
          );
  static CollectionReference<UserModel> getUsersCollection() =>
      FirebaseFirestore.instance
          .collection('users')
          .withConverter(
            fromFirestore: (docSnapshot, _) =>
                UserModel.fromJson(docSnapshot.data()!),
            toFirestore: (user, _) => user.toJson(),
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

  static Future<UserModel> register({
    required String name,
    required String password,
    required String email,
  }) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    UserModel userModel = UserModel(
      id: userCredential.user!.uid,
      name: name,
      email: email,
    );

    CollectionReference<UserModel> usersCollection = getUsersCollection();
    await usersCollection.doc(userModel.id).set(userModel);

    return userModel;
  }

  static Future<UserModel> logIn({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    CollectionReference<UserModel> usersColletion = getUsersCollection();
    DocumentSnapshot<UserModel> docSnapshot = await usersColletion
        .doc(userCredential.user!.uid)
        .get();

    return docSnapshot.data()!;
  }

  static Future<void> signOut() => FirebaseAuth.instance.signOut();
}
