  import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

    Future<String?> getAccessToken() async {
    final serviceAccountJson = {
  "type": "service_account",
  "project_id": "dukan-baladna-99045",
  "private_key_id": "05dfc2878d7396da4f63a9481e245ad15f2901c4",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC2FOoyPw+dx4HP\nbw14HgzsNzGU6qsk2Aru5fFOVHsU0COSswVxp+vrvMGtMy6cPQ7CFbU/hl4bgxSv\nXXpPaArFwKNywntkOkNTsjk3zcF9OlgQT07B7xvYfYQzImdpdSgp33WhV7Ov6/Oi\nhOZ4+5XuHqyJgx7N0gM+nIK9mq4dV6azNYFb5ALkFk48rp9LBwpXj0vMyc9y05JS\nSx8Ip0WVyiCF70KfvqI7qT80BwObpWNOGTTz0koYlurs+4tNPTiJXZsXu7+G0iw4\nBQrPV7Q3ndeNS2bvMKEDmVM+tyDWi0JIMEYnsTllPFmbJPdbWGcp1Xlptm2NQhiq\nEGK6vc4RAgMBAAECggEAFSk0GJfUmEkl8HYfEh0n8lHtzLlDH5qOFrqZgzl1PnN8\nFuIAWXejBvgeaCMhIR5Fd0/viwzyJe9jeYf7HXxheB8Nv9oTXhAZYAI//RjICmY7\n8tVMuWQxD8VylkDC1PI9MzSZpqEbLHBXFcWtRVUz1QMymR6od1IXd3DYDvIJlzY0\nPLx5CDpnCfS32nkIyX6EyARyOaAcE2ecc1dBV3ZlADaP7XT3F7dece3AyaLD7mWB\ng5SVrICVdfWJhcVw6Q7JNR3RoCnAYCRKGWodkwYKHdWcikMLkY/lCjZUINzvkX4k\nMRTUNxqptibKhwFF83RzlaRUziAUGptVM3SkZ/cmmwKBgQD96XJml573TiqVsQD2\n+Hr95M2ScQ+aRvzNTHwmaOAKr9lPDX8jvWwmcbeUXiCiSEGPNPpMcJuSxJue/YTL\nFbcVI0eqiWyLPJ7i4MLG/hNPP0SvwTASM7u0Dez+qBFVtxHXLmcgiS0LDb9K5p5B\nt4tIZLzuJeHg6OR6wST+ZSQg8wKBgQC3lD74QguPodPLzGaLUKNDxWp6WgTNE6Y9\nZygRhdKKntWBH0VdkBxDYRH+exjt4eunj3IfAqASYSP3gqpfIYCEKzb4rHIs6m+2\nHeTgX7l9wzwem98sLTtlhQNBI076WWEgx17KgFq2AMEucOg3m1nu4zbhQsI07WNj\nO1Kd34n16wKBgCFoiOvkwT7K4yGFA5p7QTuM0luVUrc65eJhUOiA3hGp547WOMdM\nEiHQzpXP+L1BgpbEIrbSDjY2dj9qHgHWnptCZBiVMlnzpPg3GIm0Pngr2+7AHYIX\nmnfraSZsmLNNfiRw75LBWdLdgTDqvSHqc4IX9x/ijiDYo89fAG4UgrdvAoGBAK3W\nMKbPi7kQScnjnXrw+hlT2NdRZNh5ceMVSukE6vEfJRgnb30A2PKo+ewbzuh8FbXO\n7QcWalPdLrzTO9fnlpYRgfWK/ncv7Gbs+e3KV5ESjlyBx5xCnMsuYH2PHNuORZ5P\njKB/WOad4lDC0/LMJiZDfJVkrRiHbqTp6PrcUfzPAoGBANnJZ6oAvvuNYBZ32rbd\navPfEdW4BsHauEcNpEg10qn3rqBMGe4yHOvoxD68fuqxn5+BZYBLWxSVoZO948FT\nWUc+GJYGF2zUuuF1DqWJ6f35P78V55ikhnpG+35GM313zDpvHjj+0trpb5gCXaLc\nRAy0W+eSqd3Y+l409ea2/ro1\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-lexak@dukan-baladna-99045.iam.gserviceaccount.com",
  "client_id": "103835211998621346311",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-lexak%40dukan-baladna-99045.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
};


    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    try {
      http.Client client = await auth.clientViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
              auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
              scopes,
              client);

      client.close();
      print(credentials.accessToken.data);
      return credentials.accessToken.data;
    } catch (e) {
      print("Error getting access token: $e");
      return null;
    }
  }

 Future<String?> getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print(token);
      return token ;
      // Add token to Firebase or use it as needed
    } catch (e) {
      print("Error fetching Firebase token: $e");
    }
  }


