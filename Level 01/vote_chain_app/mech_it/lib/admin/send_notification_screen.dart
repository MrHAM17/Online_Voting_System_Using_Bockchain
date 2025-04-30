// import 'package:flutter/material.dart';
// import 'notification_service.dart';
//
// class SendNotificationScreen extends StatelessWidget {
//   final NotificationService _notificationService = NotificationService();
//
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _bodyController = TextEditingController();
//
//   void _sendNotification(BuildContext context) {
//     if (_titleController.text.isNotEmpty && _bodyController.text.isNotEmpty) {
//       _notificationService.sendNotification(
//         _titleController.text,
//         _bodyController.text,
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notification sent successfully!")));
//       _titleController.clear();
//       _bodyController.clear();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Send Notification"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(labelText: "Notification Title"),
//             ),
//             TextField(
//               controller: _bodyController,
//               decoration: InputDecoration(labelText: "Notification Body"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _sendNotification(context),
//               child: Text("Send Notification"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
