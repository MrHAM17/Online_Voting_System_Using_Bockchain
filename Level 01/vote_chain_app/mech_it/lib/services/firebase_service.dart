import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save election data
  Future<void> saveElectionToFirebase(String state, Map<String, dynamic> electionData) async {
    final docRef = _db
        .collection('Vote Chain')
        .doc(state)
        .collection('Election')
        .doc(electionData['id']);

    await docRef.set(electionData);
  }

  // Fetch real-time election updates
  Stream<List<Map<String, dynamic>>> streamElections(String state) {
    return _db
        .collection('Vote Chain')
        .doc(state)
        .collection('Election')
        .snapshots()
        .map((query) => query.docs.map((doc) => doc.data()).toList());
  }

  // Save notifications
  Future<void> saveNotification(String state, Map<String, dynamic> notificationData) async {
    await _db
        .collection('Vote Chain')
        .doc(state)
        .collection('Notifications')
        .add(notificationData);
  }

  // Fetch notifications
  Stream<List<Map<String, dynamic>>> streamNotifications(String state) {
    return _db
        .collection('Vote Chain')
        .doc(state)
        .collection('Notifications')
        .snapshots()
        .map((query) => query.docs.map((doc) => doc.data()).toList());
  }

  // Notification functionality using Firebase Messaging
  Future<void> sendNotification(String title, String body) async {
    FirebaseMessaging _messaging = FirebaseMessaging.instance;

    // Request notification permissions
    NotificationSettings settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Notifications authorized");

      // Placeholder for sending FCM notifications (you'd use a server to do this in production)
      // This part can be expanded to integrate with your server to send actual FCM notifications
    } else {
      print("Notifications not authorized");
    }
  }

}
