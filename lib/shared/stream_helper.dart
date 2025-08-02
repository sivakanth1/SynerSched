import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;

class StreamConnectionHelper {
  static Future<void> ensureConnected(stream.StreamChatClient client) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Already connected?
    if (client.state.currentUser?.id == currentUser.uid) {
      final name = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile')
          .doc('info')
          .get()
          .then((doc) => doc.data()?['name'] ?? currentUser.uid);
      client.updateUser(stream.User(id: currentUser.uid, name: name));
      return;
    }

    // Fetch token from backend
    final uri = Uri.parse("https://stream-token-server-pi1u.onrender.com/get-stream-token");
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer synerSchedSecret', // secure in prod
      },
      body: jsonEncode({'uid': currentUser.uid}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch token: ${response.body}");
    }

    final token = jsonDecode(response.body)['token'];

    await client.connectUser(
      stream.User(id: currentUser.uid, name: currentUser.displayName ?? "User"),
      token,
    );
  }

  static void logout(stream.StreamChatClient client) async {
    await FirebaseAuth.instance.signOut();
    await client.disconnectUser();
  }
}