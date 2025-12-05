import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  
  /// Initialize Firebase if not already initialized.
  /// Note: Firebase should already be initialized in main.dart.
  /// This is a safety check method only.
  static Future<void> initialize() async {
    // Firebase should already be initialized in main.dart
    // Only initialize if not already initialized (safety check)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }
  
  // Auth Methods
  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }
  
  static Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }
  
  static Future<void> signOut() async {
    await auth.signOut();
  }
  
  static User? get currentUser => auth.currentUser;
  
  static Stream<User?> get authStateChanges => auth.authStateChanges();
  
  // Firestore Methods
  static Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      await firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Failed to add document: $e');
    }
  }
  
  static Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }
  
  static Future<void> deleteDocument(String collection, String docId) async {
    try {
      await firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
  
  static Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }
  
  static Stream<QuerySnapshot> getCollectionStream(String collection) {
    return firestore.collection(collection).snapshots();
  }
  
  static Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await firestore.collection(collection).get();
    } catch (e) {
      throw Exception('Failed to get collection: $e');
    }
  }
  
  // Storage Methods
  static Future<String> uploadFile(String path, Uint8List data) async {
    try {
      final ref = storage.ref().child(path);
      final uploadTask = ref.putData(data);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
  
  static Future<void> deleteFile(String path) async {
    try {
      await storage.ref().child(path).delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
