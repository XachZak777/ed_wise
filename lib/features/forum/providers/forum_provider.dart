import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../models/forum_post.dart';

class ForumProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<ForumPost>> _postsController = 
      StreamController<List<ForumPost>>.broadcast();

  Stream<List<ForumPost>> get postsStream => _postsController.stream;

  Future<void> loadPosts() async {
    try {
      _firestore
          .collection(AppConstants.forumPostsCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        final posts = snapshot.docs
            .map((doc) => ForumPost.fromMap(doc.data(), doc.id))
            .toList();
        _postsController.add(posts);
      });
    } catch (e) {
      _postsController.addError(e);
    }
  }

  Future<String> createPost(
    String userId,
    String userEmail,
    String userName,
    String title,
    String content,
    String category,
    List<String> tags,
  ) async {
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

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(AppConstants.forumPostsCollection)
          .doc(postId)
          .update({
        ...updates,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      // Delete all comments for this post first
      final commentsSnapshot = await _firestore
          .collection(AppConstants.forumCommentsCollection)
          .where('postId', isEqualTo: postId)
          .get();

      for (final doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the post
      await _firestore
          .collection(AppConstants.forumPostsCollection)
          .doc(postId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  Future<void> toggleUpvote(String postId, String userId) async {
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
        int upvotes = postData['upvotes'] ?? 0;
        int downvotes = postData['downvotes'] ?? 0;

        if (upvotedBy.contains(userId)) {
          // Remove upvote
          upvotedBy.remove(userId);
          upvotes--;
        } else {
          // Add upvote, remove downvote if exists
          if (downvotedBy.contains(userId)) {
            downvotedBy.remove(userId);
            downvotes--;
          }
          upvotedBy.add(userId);
          upvotes++;
        }

        transaction.update(postRef, {
          'upvotes': upvotes,
          'downvotes': downvotes,
          'upvotedBy': upvotedBy,
          'downvotedBy': downvotedBy,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Failed to toggle upvote: $e');
    }
  }

  Future<void> toggleDownvote(String postId, String userId) async {
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
        int upvotes = postData['upvotes'] ?? 0;
        int downvotes = postData['downvotes'] ?? 0;

        if (downvotedBy.contains(userId)) {
          // Remove downvote
          downvotedBy.remove(userId);
          downvotes--;
        } else {
          // Add downvote, remove upvote if exists
          if (upvotedBy.contains(userId)) {
            upvotedBy.remove(userId);
            upvotes--;
          }
          downvotedBy.add(userId);
          downvotes++;
        }

        transaction.update(postRef, {
          'upvotes': upvotes,
          'downvotes': downvotes,
          'upvotedBy': upvotedBy,
          'downvotedBy': downvotedBy,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Failed to toggle downvote: $e');
    }
  }

  Future<void> addComment(
    String postId,
    String userId,
    String userEmail,
    String userName,
    String content, {
    String? parentCommentId,
  }) async {
    try {
      final comment = ForumComment(
        id: '',
        postId: postId,
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        content: content,
        upvotes: 0,
        downvotes: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        upvotedBy: [],
        downvotedBy: [],
        parentCommentId: parentCommentId,
      );

      // Add comment
      await _firestore
          .collection(AppConstants.forumCommentsCollection)
          .add(comment.toMap());

      // Update post comment count
      await _firestore
          .collection(AppConstants.forumPostsCollection)
          .doc(postId)
          .update({
        'commentCount': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> deleteComment(String commentId, String postId) async {
    try {
      // Delete comment
      await _firestore
          .collection(AppConstants.forumCommentsCollection)
          .doc(commentId)
          .delete();

      // Update post comment count
      await _firestore
          .collection(AppConstants.forumPostsCollection)
          .doc(postId)
          .update({
        'commentCount': FieldValue.increment(-1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<void> toggleCommentUpvote(String commentId, String userId) async {
    try {
      final commentRef = _firestore
          .collection(AppConstants.forumCommentsCollection)
          .doc(commentId);

      await _firestore.runTransaction((transaction) async {
        final commentDoc = await transaction.get(commentRef);
        if (!commentDoc.exists) {
          throw Exception('Comment not found');
        }

        final commentData = commentDoc.data()!;
        final upvotedBy = List<String>.from(commentData['upvotedBy'] ?? []);
        final downvotedBy = List<String>.from(commentData['downvotedBy'] ?? []);
        int upvotes = commentData['upvotes'] ?? 0;
        int downvotes = commentData['downvotes'] ?? 0;

        if (upvotedBy.contains(userId)) {
          upvotedBy.remove(userId);
          upvotes--;
        } else {
          if (downvotedBy.contains(userId)) {
            downvotedBy.remove(userId);
            downvotes--;
          }
          upvotedBy.add(userId);
          upvotes++;
        }

        transaction.update(commentRef, {
          'upvotes': upvotes,
          'downvotes': downvotes,
          'upvotedBy': upvotedBy,
          'downvotedBy': downvotedBy,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Failed to toggle comment upvote: $e');
    }
  }

  Future<void> toggleCommentDownvote(String commentId, String userId) async {
    try {
      final commentRef = _firestore
          .collection(AppConstants.forumCommentsCollection)
          .doc(commentId);

      await _firestore.runTransaction((transaction) async {
        final commentDoc = await transaction.get(commentRef);
        if (!commentDoc.exists) {
          throw Exception('Comment not found');
        }

        final commentData = commentDoc.data()!;
        final upvotedBy = List<String>.from(commentData['upvotedBy'] ?? []);
        final downvotedBy = List<String>.from(commentData['downvotedBy'] ?? []);
        int upvotes = commentData['upvotes'] ?? 0;
        int downvotes = commentData['downvotes'] ?? 0;

        if (downvotedBy.contains(userId)) {
          downvotedBy.remove(userId);
          downvotes--;
        } else {
          if (upvotedBy.contains(userId)) {
            upvotedBy.remove(userId);
            upvotes--;
          }
          downvotedBy.add(userId);
          downvotes++;
        }

        transaction.update(commentRef, {
          'upvotes': upvotes,
          'downvotes': downvotes,
          'upvotedBy': upvotedBy,
          'downvotedBy': downvotedBy,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Failed to toggle comment downvote: $e');
    }
  }

  void dispose() {
    _postsController.close();
  }
}
