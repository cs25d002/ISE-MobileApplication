import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';
import '../screens/home/home_page.dart';
import 'database.dart';

class AuthMethods {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'], // No profile or openid!
);


  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      log('Error getting current user: $e');
      return null;
    }
  }

  // Sign in with Google (without People API)
  static Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      await _googleSignIn.signOut(); // Ensure fresh login session

      // Trigger Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        log('Google Sign-In: User canceled the sign-in flow');
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Store user info in Firestore (without requiring People API)
        final Map<String, dynamic> userInfoMap = {
          "email": user.email,
          "id": user.uid,
          "lastLogin": DateTime.now().toIso8601String(),
          "signUpDate": user.metadata.creationTime?.toIso8601String(),
        };

        await DatabaseMethods().addUser(user.uid, userInfoMap);

        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GreetingPage(email: user.email ?? '')),
        );

        return user;
      }
      return null;
    } catch (e) {
      log('Error during Google Sign-In: $e');

      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  // Sign out
  static Future<void> signOut(BuildContext context) async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      // Navigate back to login page
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      log('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Reset password
  static Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Please check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log('Error sending password reset email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send password reset email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Get user token
  static Future<String?> getUserToken() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      log('Error getting user token: $e');
      return null;
    }
  }
}
