import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../../features/forum/models/forum_post.dart';
import '../../features/forum/repositories/mock_comment_repository.dart';

abstract class CommentRepository {
  static CommentRepository get instance {
    if (AppConfig.useMockForum) {
      return MockCommentRepository();
    }
    return FirebaseCommentRepository();
  }

  Future<List<ForumComment>> getComments(String postId);
  Future<ForumComment> createComment({
    required String postId,
    required String userId,
    required String userName,
    required String userEmail,
    required String content,
    String? parentCommentId,
  });
  Future<void> deleteComment(String commentId);
  Future<void> upvoteComment(String commentId, String userId);
  Future<void> downvoteComment(String commentId, String userId);
}

class FirebaseCommentRepository implements CommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ForumComment>> getComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.forumCommentsCollection)
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => ForumComment.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  @override
  Future<ForumComment> createComment({
    required String postId,
    required String userId,
    required String userName,
    required String userEmail,
    required String content,
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

      final docRef = await _firestore
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

      return comment.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      // Get comment to find postId
      final commentDoc = await _firestore
          .collection(AppConstants.forumCommentsCollection)
          .doc(commentId)
          .get();

      if (commentDoc.exists) {
        final data = commentDoc.data() as Map<String, dynamic>;
        final postId = data['postId'] as String;

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
      }
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  @override
  Future<void> upvoteComment(String commentId, String userId) async {
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

        if (upvotedBy.contains(userId)) {
          upvotedBy.remove(userId);
        } else {
          upvotedBy.add(userId);
          downvotedBy.remove(userId);
        }

        transaction.update(commentRef, {
          'upvotes': upvotedBy.length,
          'downvotes': downvotedBy.length,
          'upvotedBy': upvotedBy,
          'downvotedBy': downvotedBy,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Failed to upvote comment: $e');
    }
  }

  @override
  Future<void> downvoteComment(String commentId, String userId) async {
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

        if (downvotedBy.contains(userId)) {
          downvotedBy.remove(userId);
        } else {
          downvotedBy.add(userId);
          upvotedBy.remove(userId);
        }

        transaction.update(commentRef, {
          'upvotes': upvotedBy.length,
          'downvotes': downvotedBy.length,
          'upvotedBy': upvotedBy,
          'downvotedBy': downvotedBy,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Failed to downvote comment: $e');
    }
  }
}

