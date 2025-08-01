import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  // Sign up with email and password
  static Future<User?> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }

  // Login with email and password
  static Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Current user
  static User? get currentUser => _auth.currentUser;

  // Is user logged in
  static bool get isLoggedIn => _auth.currentUser != null;
}