import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/config/app_config.dart';
import '../../../core/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  User? _currentUser;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  
  // Store mock user data
  String? _mockUid;
  String? _mockEmail;
  String? _mockDisplayName;
  
  // Mock users database
  final Map<String, Map<String, dynamic>> _mockUsers = {
    'user1@example.com': {
      'password': 'password123',
      'name': 'John Doe',
      'uid': 'mock_uid_1',
    },
    'user2@example.com': {
      'password': 'password123',
      'name': 'Jane Smith',
      'uid': 'mock_uid_2',
    },
  };

  final Map<String, Map<String, dynamic>> _mockProfiles = {
    'mock_uid_1': {
      'uid': 'mock_uid_1',
      'name': 'John Doe',
      'email': 'user1@example.com',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'studyStats': {
        'totalStudyTime': 120,
        'completedTasks': 15,
        'activePlans': 3,
        'forumPosts': 5,
      },
      'preferences': {
        'notifications': true,
        'darkMode': false,
        'language': 'en',
      },
    },
    'mock_uid_2': {
      'uid': 'mock_uid_2',
      'name': 'Jane Smith',
      'email': 'user2@example.com',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'studyStats': {
        'totalStudyTime': 200,
        'completedTasks': 25,
        'activePlans': 5,
        'forumPosts': 8,
      },
      'preferences': {
        'notifications': true,
        'darkMode': false,
        'language': 'en',
      },
    },
  };

  MockAuthRepository() {
    _authStateController.add(_currentUser);
  }

  @override
  User? get currentUser {
    // In mock mode, always return the internally maintained mock user
    // so that sign-in/sign-up/sign-out operations stay consistent.
    return _currentUser;
  }

  @override
  Stream<User?> get authStateChanges {
    // Combine Firebase stream with mock stream
    return _authStateController.stream;
  }

  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    
    if (_mockUsers.containsKey(email) && _mockUsers[email]!['password'] == password) {
      final userData = _mockUsers[email]!;
      _mockUid = userData['uid']!;
      _mockEmail = email;
      _mockDisplayName = userData['name']!;
      
      // Create a real Firebase user for mock mode
      // In production, this would be handled by Firebase Auth
      // For now, we'll use Firebase Auth to create a temporary user
      try {
        final credential = await FirebaseAuth.instance.signInAnonymously();
        if (credential.user != null) {
          await credential.user!.updateDisplayName(_mockDisplayName);
          await credential.user!.updateEmail(email);
          _currentUser = credential.user;
          _authStateController.add(_currentUser);
          return credential;
        }
      } catch (e) {
        // If anonymous sign-in fails, just update the stream
        _authStateController.add(_currentUser);
      }
      
      return null;
    }
    
    throw Exception('Invalid email or password');
  }

  @override
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    
    if (_mockUsers.containsKey(email)) {
      throw Exception('An account already exists with this email address.');
    }
    
    final uid = 'mock_uid_${_mockUsers.length + 1}';
    _mockUsers[email] = {
      'password': password,
      'name': name,
      'uid': uid,
    };
    
    _mockProfiles[uid] = {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'studyStats': {
        'totalStudyTime': 0,
        'completedTasks': 0,
        'activePlans': 0,
        'forumPosts': 0,
      },
      'preferences': {
        'notifications': true,
        'darkMode': false,
        'language': 'en',
      },
    };
    
    _updateMockUserData(uid, email, name);
    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        _currentUser = credential.user;
        _authStateController.add(_currentUser);
        return credential;
      }
    } catch (e) {
      _authStateController.add(_currentUser);
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    if (!_mockUsers.containsKey(email)) {
      throw Exception('No user found with this email address.');
    }
    // In mock, we just simulate success
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    // Simulate Google sign-in
    final uid = 'mock_google_uid_1';
    final email = 'google.user@example.com';
    final name = 'Google User';
    
    if (!_mockUsers.containsKey(email)) {
      _mockUsers[email] = {
        'password': '',
        'name': name,
        'uid': uid,
      };
      _mockProfiles[uid] = {
        'uid': uid,
        'name': name,
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'studyStats': {
          'totalStudyTime': 0,
          'completedTasks': 0,
          'activePlans': 0,
          'forumPosts': 0,
        },
        'preferences': {
          'notifications': true,
          'darkMode': false,
          'language': 'en',
        },
      };
    }
    
    _updateMockUserData(uid, email, name);
    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        _currentUser = credential.user;
        _authStateController.add(_currentUser);
        return credential;
      }
    } catch (e) {
      _authStateController.add(_currentUser);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    return _mockProfiles[uid]?.map((key, value) {
      if (key == 'createdAt' || key == 'updatedAt') {
        return MapEntry(key, DateTime.parse(value));
      }
      return MapEntry(key, value);
    });
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    if (_mockProfiles.containsKey(uid)) {
      _mockProfiles[uid] = {
        ..._mockProfiles[uid]!,
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }
  }

  // Helper method to update mock user data
  void _updateMockUserData(String uid, String email, String displayName) {
    _mockUid = uid;
    _mockEmail = email;
    _mockDisplayName = displayName;
  }
}

