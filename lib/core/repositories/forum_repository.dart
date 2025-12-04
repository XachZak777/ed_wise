import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../../features/forum/models/forum_post.dart';
import '../../features/forum/repositories/mock_forum_repository.dart';

abstract class ForumRepository {
  static ForumRepository get instance {
    // Use mock data for presentation/demo
    if (AppConfig.useMockForum) {
      return MockForumRepository();
    }
    return FirebaseForumRepository();
  }

  Future<List<ForumPost>> getPosts({String? category});
  Future<ForumPost> createPost({
    required String userId,
    required String userName,
    required String userEmail,
    required String title,
    required String content,
    required String category,
    required List<String> tags,
  });
  Future<void> updatePost(String postId, Map<String, dynamic> updates);
  Future<void> deletePost(String postId);
  Future<void> upvotePost(String postId, String userId);
  Future<void> downvotePost(String postId, String userId);
}

class FirebaseForumRepository implements ForumRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ForumPost>> getPosts({String? category}) async {
    try {
      Query query = _firestore
          .collection(AppConstants.forumPostsCollection)
          .orderBy('createdAt', descending: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ForumPost.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  @override
  Future<ForumPost> createPost({
    required String userId,
    required String userName,
    required String userEmail,
    required String title,
    required String content,
    required String category,
    required List<String> tags,
  }) async {
    try {
      final post = ForumPost(
        id: '',
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        title: title,
        content: content,
        category: category,
        tags: tags,
        upvotes: 0,
        downvotes: 0,
        commentCount: 0,
        isPinned: false,
        isLocked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        upvotedBy: [],
        downvotedBy: [],
      );

      final docRef = await _firestore
          .collection(AppConstants.forumPostsCollection)
          .add(post.toMap());

      return post.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<void> upvotePost(String postId, String userId) async {
    try {
      final postRef = _firestore
          .collection(AppConstants.forumPostsCollection)
          .doc(postId);

      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('Post not found');
        }

        final postData = postDoc.data()!;
        final upvotedBy = List<String>.from(postData['upvotedBy'] ?? []);
        final downvotedBy = List<String>.from(postData['downvotedBy'] ?? []);

        if (upvotedBy.contains(userId)) {
          // Remove upvote
          upvotedBy.remove(userId);
        } else {
          // Add upvote, remove downvote if exists
          upvotedBy.add(userId);
          downvotedBy.remove(userId);
        }

        transaction.update(postRef, {
          'upvotes': upvotedBy.length,
          'downvotes': downvotedBy.length,
          'upvotedBy': upvotedBy,
          'downvotedBy': downvotedBy,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Failed to upvote post: $e');
    }
  }

  @override
  Future<void> downvotePost(String postId, String userId) async {
    try {
      final postRef = _firestore
          .collection(AppConstants.forumPostsCollection)
          .doc(postId);

      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('Post not found');
        }

        final postData = postDoc.data()!;
        final upvotedBy = List<String>.from(postData['upvotedBy'] ?? []);
        final downvotedBy = List<String>.from(postData['downvotedBy'] ?? []);

        if (downvotedBy.contains(userId)) {
          // Remove downvote
          downvotedBy.remove(userId);
        } else {
          // Add downvote, remove upvote if exists
          downvotedBy.add(userId);
          upvotedBy.remove(userId);
        }

        transaction.update(postRef, {
          'upvotes': upvotedBy.length,
          'downvotes': downvotedBy.length,
          'upvotedBy': upvotedBy,
          'downvotedBy': downvotedBy,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Failed to downvote post: $e');
    }
  }

  @override
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      final postRef = _firestore
          .collection(AppConstants.forumPostsCollection)
          .doc(postId);

      // Add updatedAt timestamp
      final updateData = {
        ...updates,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await postRef.update(updateData);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _firestore
          .collection(AppConstants.forumPostsCollection)
          .doc(postId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}

