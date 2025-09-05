import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/models/event_model.dart';
import 'package:event/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static CollectionReference<EventModel> getEventsCollection() =>
      FirebaseFirestore.instance
          .collection('events')
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
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel userModel = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        favouriteEventsIds: [],
      );

      CollectionReference<UserModel> usersCollection = getUsersCollection();
      await usersCollection.doc(userModel.id).set(userModel);

      return userModel;
    } catch (e) {
      log('Firebase registration error: $e');
      rethrow; // Re-throw the error to handle it in the UI
    }
  }

  static Future<UserModel> logIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final String userId = userCredential.user!.uid;

      CollectionReference<UserModel> usersCollection = getUsersCollection();
      DocumentSnapshot<UserModel> docSnapshot = await usersCollection
          .doc(userId)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.data()!;
      } else {
        final UserModel newUser = UserModel(
          id: userId,
          name: userCredential.user!.displayName ?? 'User',
          email: email,
          favouriteEventsIds: [],
        );

        await usersCollection.doc(userId).set(newUser);
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } on FirebaseException catch (e) {
      log('Firestore Error: ${e.code} - ${e.message}');
      throw Exception('Failed to access user data. Please try again.');
    } catch (e) {
      log('Unexpected error during login: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  static Future<void> signOut() => FirebaseAuth.instance.signOut();

  static Future<void> addEventToFavourite(String eventId) async {
    CollectionReference<UserModel> usersCollection = getUsersCollection();
    DocumentReference<UserModel> userDoc = usersCollection.doc(
      FirebaseAuth.instance.currentUser!.uid,
    );
    userDoc.update({
      'favouriteEventsIds': FieldValue.arrayUnion([eventId]),
    });
  }

  static Future<void> removeEventFromFavourite(String eventId) async {
    CollectionReference<UserModel> usersCollection = getUsersCollection();
    DocumentReference<UserModel> userDoc = usersCollection.doc(
      FirebaseAuth.instance.currentUser!.uid,
    );
    userDoc.update({
      'favouriteEventsIds': FieldValue.arrayRemove([eventId]),
    });
  }
}
