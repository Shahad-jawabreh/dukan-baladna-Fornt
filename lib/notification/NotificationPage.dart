import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../globle.dart' ;

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final notificationApiUrl = "https://dukan-baladna.onrender.com/notification";
    
    try {
      final response = await http.get(
        Uri.parse(notificationApiUrl),
        headers: {
          'Authorization': 'brear_$token',  // Replace with actual token or method to retrieve it
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['notifications'] != null) {
          setState(() {
            notifications = data['notifications'];
          });
        }
      } else {
        throw Exception('Failed to fetch notifications.');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF347928),
      ),
      body: notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                 child: ListTile(
  contentPadding: const EdgeInsets.all(10),
  leading: CircleAvatar(
    backgroundImage: notification['senderImage'] != null
        ? NetworkImage(notification['senderImage'])
        : AssetImage('assets/defualtuser.jpg') as ImageProvider, // Use default image if no image URL is provided
    radius: 25, // Adjust the size of the avatar
  ),
  title: Row(
    children: [
      Text(notification['sender'] ?? 'Unknown Sender', // Show sender's name
          style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(width: 8),
      Text(notification['title'] ?? 'No Title'),
    ],
  ),
  subtitle: Text(notification['body'] ?? 'No Message'),
  trailing: Text(notification['status'] ?? 'Status: unseen'),
  onTap: () {
    // Optionally, mark the notification as read when tapped
    _markAsRead(notification['_id']);
  },
)

                );
              },
            ),
    );
  }

  Future<void> _markAsRead(int notificationId) async {
    final markReadApiUrl = "https://dukan-baladna.onrender.com/notifications/markRead/$notificationId";
    
    try {
      final response = await http.put(
        Uri.parse(markReadApiUrl),
        headers: {
          'Authorization': 'brear_$token',  // Replace with actual token
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          // Mark the notification as read locally
          notifications = notifications.map((notification) {
            if (notification['_id'] == notificationId) {
              notification['status'] = 'read';
            }
            return notification;
          }).toList();
        });
      } else {
        throw Exception('Failed to mark notification as read.');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}
