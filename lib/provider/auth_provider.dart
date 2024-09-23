import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  bool get isAuth => _user != null;

  Stream<User?> get userStream => _auth.authStateChanges();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: [
        'https://www.googleapis.com/auth/userinfo.profile',
        'https://www.googleapis.com/auth/userinfo.email'
      ]).signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user != null) {
          _user = user;
          notifyListeners();
        }
      }
    } catch (e) {}
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> logout() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      return;
    }

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      return;
    }

    try {
      await _auth.signOut();
    } catch (e) {
      return;
    }

    _user = null;

    notifyListeners();
  }

  Future<void> reloadUser() async {
    await _user!.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }
}
