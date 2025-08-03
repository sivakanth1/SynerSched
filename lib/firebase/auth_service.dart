import 'package:firebase_auth/firebase_auth.dart';

/// A service class that provides authentication-related operations
/// using Firebase Authentication.
class AuthService {
  /// Firebase authentication instance to interact with Firebase Auth APIs.
  static final _auth = FirebaseAuth.instance;

  /// Creates a new user with the given email and password.
  ///
  /// Returns the created [User] object on success, or null on failure.
  static Future<User?> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Handle signup failure by returning null
      return null;
    }
  }

  /// Signs in an existing user using the provided email and password.
  ///
  /// Returns the signed-in [User] object on success, or null on failure.
  static Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Handle login failure by returning null
      return null;
    }
  }

  /// Signs out the currently logged-in user.
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// Gets the currently authenticated [User] object, if any.
  static User? get currentUser => _auth.currentUser;

  /// Checks whether a user is currently signed in.
  static bool get isLoggedIn => _auth.currentUser != null;
}