import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;

class StreamConnectionHelper {
  /// Ensures that the Stream Chat client is connected with the current Firebase user.
  /// If the user is already connected, it updates the user information.
  /// Otherwise, it fetches a new token from the backend and connects the user.
  static Future<void> ensureConnected(stream.StreamChatClient client) async {
    // Get the currently authenticated Firebase user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return; // No user is signed in, so no connection needed

    // Check if the Stream client is already connected with this user
    if (client.state.currentUser?.id == currentUser.uid) {
      // Fetch the user's name from Firestore profile data
      final name = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('profile')
          .doc('info')
          .get()
          .then((doc) => doc.data()?['name'] ?? currentUser.uid);
      // Update the Stream user with the latest name information
      client.updateUser(stream.User(id: currentUser.uid, name: name));
      return; // Already connected and updated, no further action needed
    }

    // If not connected, request a Stream token from the backend server
    final uri = Uri.parse("https://stream-token-server-pi1u.onrender.com/get-stream-token");
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer synerSchedSecret', // Authorization header for secure token retrieval
      },
      body: jsonEncode({'uid': currentUser.uid}), // Send the Firebase user ID to get a corresponding Stream token
    );

    // Throw an error if the token request failed
    if (response.statusCode != 200) {
      throw Exception("Failed to fetch token: ${response.body}");
    }

    // Parse the token from the backend response
    final token = jsonDecode(response.body)['token'];

    // Connect the Stream client user with the retrieved token and user information
    await client.connectUser(
      stream.User(id: currentUser.uid, name: currentUser.displayName ?? "User"),
      token,
    );
  }

  /// Logs out the current Firebase user and disconnects the Stream Chat client.
  static void logout(stream.StreamChatClient client) async {
    // Sign out from Firebase authentication
    await FirebaseAuth.instance.signOut();
    // Disconnect the Stream Chat client user session
    await client.disconnectUser();
  }
}