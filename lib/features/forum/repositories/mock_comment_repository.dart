import '../../../core/config/app_config.dart';
import '../../../core/repositories/comment_repository.dart';
import '../models/forum_post.dart';

class MockCommentRepository implements CommentRepository {
  final Map<String, List<ForumComment>> _commentsByPost = {};

  MockCommentRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    
    _commentsByPost['post_1'] = [
      ForumComment(
        id: 'comment_1',
        postId: 'post_1',
        userId: 'user_1',
        userEmail: 'commenter1@example.com',
        userName: 'Alice Commenter',
        content: 'Great question! I started with the official Flutter documentation. It\'s very comprehensive.',
        upvotes: 5,
        downvotes: 0,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        upvotedBy: ['user1', 'user2', 'user3', 'user4', 'user5'],
        downvotedBy: [],
      ),
      ForumComment(
        id: 'comment_2',
        postId: 'post_1',
        userId: 'user_2',
        userEmail: 'commenter2@example.com',
        userName: 'Bob Helper',
        content: 'Also check out Flutter.dev tutorials - they have great step-by-step guides!',
        upvotes: 3,
        downvotes: 1,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        upvotedBy: ['user1', 'user2', 'user3'],
        downvotedBy: ['user4'],
      ),
    ];

    _commentsByPost['post_2'] = [
      ForumComment(
        id: 'comment_3',
        postId: 'post_2',
        userId: 'user_3',
        userEmail: 'commenter3@example.com',
        userName: 'Charlie Expert',
        content: 'For large apps, I recommend BLoC pattern. It\'s what we use in production and it scales well.',
        upvotes: 8,
        downvotes: 0,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
        upvotedBy: ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7', 'user8'],
        downvotedBy: [],
      ),
    ];
  }

  @override
  Future<List<ForumComment>> getComments(String postId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    return _commentsByPost[postId] ?? [];
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
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    final now = DateTime.now();
    
    final comment = ForumComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      content: content,
      upvotes: 0,
      downvotes: 0,
      createdAt: now,
      updatedAt: now,
      upvotedBy: [],
      downvotedBy: [],
      parentCommentId: parentCommentId,
    );

    if (!_commentsByPost.containsKey(postId)) {
      _commentsByPost[postId] = [];
    }
    _commentsByPost[postId]!.add(comment);
    return comment;
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    for (final postId in _commentsByPost.keys) {
      _commentsByPost[postId]!.removeWhere((comment) => comment.id == commentId);
    }
  }

  @override
  Future<void> upvoteComment(String commentId, String userId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    for (final comments in _commentsByPost.values) {
      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final comment = comments[index];
        final upvotedBy = List<String>.from(comment.upvotedBy);
        final downvotedBy = List<String>.from(comment.downvotedBy);

        if (upvotedBy.contains(userId)) {
          upvotedBy.remove(userId);
        } else {
          upvotedBy.add(userId);
          downvotedBy.remove(userId);
        }

        comments[index] = ForumComment(
          id: comment.id,
          postId: comment.postId,
          userId: comment.userId,
          userEmail: comment.userEmail,
          userName: comment.userName,
          content: comment.content,
          upvotes: upvotedBy.length,
          downvotes: downvotedBy.length,
          createdAt: comment.createdAt,
          updatedAt: DateTime.now(),
          upvotedBy: upvotedBy,
          downvotedBy: downvotedBy,
          parentCommentId: comment.parentCommentId,
        );
        break;
      }
    }
  }

  @override
  Future<void> downvoteComment(String commentId, String userId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    for (final comments in _commentsByPost.values) {
      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final comment = comments[index];
        final upvotedBy = List<String>.from(comment.upvotedBy);
        final downvotedBy = List<String>.from(comment.downvotedBy);

        if (downvotedBy.contains(userId)) {
          downvotedBy.remove(userId);
        } else {
          downvotedBy.add(userId);
          upvotedBy.remove(userId);
        }

        comments[index] = ForumComment(
          id: comment.id,
          postId: comment.postId,
          userId: comment.userId,
          userEmail: comment.userEmail,
          userName: comment.userName,
          content: comment.content,
          upvotes: upvotedBy.length,
          downvotes: downvotedBy.length,
          createdAt: comment.createdAt,
          updatedAt: DateTime.now(),
          upvotedBy: upvotedBy,
          downvotedBy: downvotedBy,
          parentCommentId: comment.parentCommentId,
        );
        break;
      }
    }
  }
}

