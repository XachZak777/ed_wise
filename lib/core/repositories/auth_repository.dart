import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../services/env_service.dart';

abstract class AuthRepository {
  static AuthRepository get instance {
    // Always use Firebase Auth (no mock auth)
    return FirebaseAuthRepository();
  }

  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<UserCredential?> signInWithEmail(String email, String password);
  Future<UserCredential?> signUpWithEmail(String email, String password, String name);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserCredential?> signInWithGoogle();
  Future<Map<String, dynamic>?> getUserProfile(String uid);
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: EnvService.googleSignInWebClientId,
  );

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Ensure user profile exists in Firestore (create if missing)
      if (credential.user != null) {
        await _ensureUserProfileExists(credential.user!);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _createUserProfile(credential.user!, name, email);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      // In newer versions of google_sign_in, accessToken is no longer exposed.
      // For Firebase Auth sign-in we only need the ID token.
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _createOrUpdateUserProfile(
          userCredential.user!,
          googleUser.displayName ?? '',
          googleUser.email,
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> _createUserProfile(User user, String name, String email) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'studyStats': {
          'totalStudyTime': 0,
          'completedTasks': 0,
          'activePlans': 0,
        },
        'preferences': {
          'notifications': true,
          'darkMode': false,
          'language': 'en',
        },
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<void> _createOrUpdateUserProfile(User user, String name, String email) async {
    try {
      final docRef = _firestore.collection(AppConstants.usersCollection).doc(user.uid);
      final doc = await docRef.get();
      
      if (doc.exists) {
        await docRef.update({
          'name': name,
          'email': email,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _createUserProfile(user, name, email);
      }
    } catch (e) {
      throw Exception('Failed to create or update user profile: $e');
    }
  }

  /// Ensures user profile exists in Firestore. Creates it if missing.
  /// This ensures that user data persists across sessions.
  Future<void> _ensureUserProfileExists(User user) async {
    try {
      final docRef = _firestore.collection(AppConstants.usersCollection).doc(user.uid);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        // Profile doesn't exist, create it with available information
        final name = user.displayName ?? user.email?.split('@').first ?? 'User';
        final email = user.email ?? '';
        await _createUserProfile(user, name, email);
      } else {
        // Profile exists, update last accessed time
        await docRef.update({
          'lastAccessedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Don't throw - profile check shouldn't break sign-in
      debugPrint('Warning: Failed to ensure user profile exists: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

