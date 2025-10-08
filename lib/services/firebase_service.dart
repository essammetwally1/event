import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/models/event_model.dart';
import 'package:event/models/user_model.dart';
import 'package:event/services/subabase_service.dart';
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
    final eventsCollection = getEventsCollection();
    final docs = eventsCollection.doc();
    event.id = docs.id;
    return docs.set(event);
  }

  static Future<List<EventModel>> getEvents() async {
    final eventsCollection = getEventsCollection();
    final querySnapshot = await eventsCollection.orderBy('timestamp').get();
    return querySnapshot.docs.map((event) => event.data()).toList();
  }

  static Future<bool> deleteEvent(String eventId) async {
    try {
      await getEventsCollection().doc(eventId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> updateEvent(EventModel event) async {
    await getEventsCollection().doc(event.id).update(event.toJson());
  }

  static Future<UserModel> register({
    required String name,
    required String password,
    required String email,
  }) async {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    final userModel = UserModel(
      id: userCredential.user!.uid,
      name: name,
      email: email,
      imageUrl: null,
      favouriteEventsIds: [],
    );

    await getUsersCollection().doc(userModel.id).set(userModel);
    return userModel;
  }

  static Future<UserModel> logIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    final userId = userCredential.user!.uid;
    final usersCollection = getUsersCollection();
    final docSnapshot = await usersCollection.doc(userId).get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      return docSnapshot.data()!;
    } else {
      final newUser = UserModel(
        id: userId,
        name: userCredential.user!.displayName ?? 'User',
        email: email,
        imageUrl: null,
        favouriteEventsIds: [],
      );

      await usersCollection.doc(userId).set(newUser);
      return newUser;
    }
  }

  static Future<void> signOut() => FirebaseAuth.instance.signOut();

  static Future<void> addEventToFavourite(String eventId) async {
    final userDoc = getUsersCollection().doc(
      FirebaseAuth.instance.currentUser!.uid,
    );
    await userDoc.update({
      'favouriteEventsIds': FieldValue.arrayUnion([eventId]),
    });
  }

  static Future<void> removeEventFromFavourite(String eventId) async {
    final userDoc = getUsersCollection().doc(
      FirebaseAuth.instance.currentUser!.uid,
    );
    await userDoc.update({
      'favouriteEventsIds': FieldValue.arrayRemove([eventId]),
    });
  }

  static Future<UserModel?> getUserById(String userId) async {
    try {
      final docSnapshot = await getUsersCollection().doc(userId).get();
      return docSnapshot.data();
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateUserProfileImage({
    required String userId,
    String? imageUrl,
    String? name,
  }) async {
    final updateData = <String, dynamic>{};
    if (imageUrl != null) updateData['imageUrl'] = imageUrl;
    if (name != null) updateData['name'] = name;

    await getUsersCollection().doc(userId).update(updateData);
  }

  static Future<String?> uploadUserImage({
    required String userId,
    required String imagePath,
  }) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) return null;

      final imageUrl = await SupabaseService.upload(
        uid: userId,
        file: imageFile,
      );

      if (imageUrl != null) {
        await updateUserProfileImage(userId: userId, imageUrl: imageUrl);
      }

      return imageUrl;
    } catch (e) {
      return null;
    }
  }
}
