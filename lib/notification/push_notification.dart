import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dukan_baladna/notification/tokenDevice.dart'; // تأكد من أنك قد أضفت الكود المسؤول عن جلب التوكن من هنا
import 'package:dukan_baladna/globle.dart';
Future<void> sendNotification(String title, String body, String notificationType, String sender, String receiver) async {
 String? token = await getToken();
    String? accessToken = await getAccessToken();

    if (token == null || accessToken == null) {
      throw Exception('Failed to retrieve token or access token.');
    }


  var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  var request = http.Request(
      'POST', Uri.parse('https://fcm.googleapis.com/v1/projects/dukan-baladna-99045/messages:send'));

  request.body = json.encode({
    "message": {
      "token": "$token", // Replace with target device token
      "notification": {
        "title": title,
        "body": body,
      },
      "android": {
        "notification": {
          "notification_priority": "PRIORITY_MAX",
          "sound": "default",
        },
      },
      "apns": {
        "payload": {
          "aps": {
            "content_available": true,
          },
        },
      },
      "data": {
        "type": notificationType,
        "sender": sender,
        "receiver" : receiver
      },
    }
  });

  request.headers.addAll(headers);

  try {
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
       await saveNotificationDetails(sender, receiver, notificationType, title, body);
      print(await response.stream.bytesToString());
    } else {
      print("Failed to send notification: ${response.reasonPhrase}");
    }
  } catch (e) {
    print("Error occurred while sending notification: $e");
  }
}



Future<void> saveNotificationDetails(
    String sender, String receiver, String type, String title, String body) async {
  var url = Uri.parse('$domain/notification/'); // Replace with your API endpoint
  var headers = {
    'Content-Type': 'application/json',
  };
  var bodyData = json.encode({
    "sender": sender,
    "receiver": receiver,
    "type": type,
    "title": title,
    "body": body,
  });
   
   print(bodyData);
  try {
    var response = await http.post(url, headers: headers, body: bodyData);
    print(response.body);
    if (response.statusCode == 200) {
      print("Notification saved successfully: ${response.body}");
    } else {
      print("Failed to save notification: ${response.reasonPhrase}");
    }
  } catch (e) {
    print("Error occurred while saving notification: $e");
  }
}