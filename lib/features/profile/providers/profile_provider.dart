import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

class ProfileProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

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

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        ...data,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await updateUserProfile(user.uid, {'name': displayName});
      }
    } catch (e) {
      throw Exception('Failed to update display name: $e');
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        await updateUserProfile(user.uid, {'email': newEmail});
      }
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _deleteUserData(user.uid);
        
        // Delete the user account
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<void> _deleteUserData(String uid) async {
    try {
      // Delete user profile
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .delete();

      // Delete user's study plans
      final studyPlansSnapshot = await _firestore
          .collection(AppConstants.studyPlansCollection)
          .where('userId', isEqualTo: uid)
          .get();

      for (final doc in studyPlansSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user's AI videos
      final aiVideosSnapshot = await _firestore
          .collection(AppConstants.aiVideosCollection)
          .where('userId', isEqualTo: uid)
          .get();

      for (final doc in aiVideosSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user's forum posts
      final forumPostsSnapshot = await _firestore
          .collection(AppConstants.forumPostsCollection)
          .where('userId', isEqualTo: uid)
          .get();

      for (final doc in forumPostsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user's forum comments
      final forumCommentsSnapshot = await _firestore
          .collection(AppConstants.forumCommentsCollection)
          .where('userId', isEqualTo: uid)
          .get();

      for (final doc in forumCommentsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> updateStudyStats(String uid, Map<String, dynamic> stats) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'studyStats': stats,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update study stats: $e');
    }
  }

  Future<void> incrementStudyTime(String uid, int minutes) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'studyStats.totalStudyTime': FieldValue.increment(minutes),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to increment study time: $e');
    }
  }

  Future<void> incrementCompletedTasks(String uid) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'studyStats.completedTasks': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to increment completed tasks: $e');
    }
  }

  Future<void> updateActivePlans(String uid, int count) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'studyStats.activePlans': count,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update active plans: $e');
    }
  }
}
