import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class NotificationManagementScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Notifications')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firebaseService.streamNotifications('StateName'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications available.'));
          }
          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification['title']),
                subtitle: Text(notification['message']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddNotificationDialog(context);
        },
      ),
    );
  }

  void _showAddNotificationDialog(BuildContext context) {
    final _titleController = TextEditingController();
    final _messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
              TextField(controller: _messageController, decoration: InputDecoration(labelText: 'Message')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final notificationData = {
                  'title': _titleController.text,
                  'message': _messageController.text,
                  'timestamp': DateTime.now().toIso8601String(),
                };
                await _firebaseService.saveNotification('StateName', notificationData);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
