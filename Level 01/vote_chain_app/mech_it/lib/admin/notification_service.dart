//
// class NotificationService {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//
//   Future<void> sendNotification(String title, String body) async {
//     // In real scenarios, you'd use a server to send notifications via FCM.
//     // This is just a placeholder for testing FCM functionality.
//
//     // Request notification permissions.
//     NotificationSettings settings = await _messaging.requestPermission();
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print("Notifications authorized");
//       // FCM functionality for sending notifications goes here.
//     } else {
//       print("Notifications not authorized");
//     }
//   }
// }
