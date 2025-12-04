import '../../../core/config/app_config.dart';
import '../../../core/repositories/forum_repository.dart';
import '../models/forum_post.dart';

class MockForumRepository implements ForumRepository {
  final List<ForumPost> _mockPosts = [];

  MockForumRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _mockPosts.addAll([
      ForumPost(
        id: 'post_1',
        userId: 'demo_user_1',
        userEmail: 'john.doe@example.com',
        userName: 'John Doe',
        title: 'How to get started with Flutter?',
        content: 'I\'m new to Flutter and would like some guidance on getting started. Any tips for a beginner? I\'ve heard great things about Flutter\'s hot reload feature.',
        category: 'Flutter',
        tags: ['flutter', 'beginner', 'help', 'tutorial'],
        upvotes: 15,
        downvotes: 2,
        commentCount: 8,
        isPinned: true,
        isLocked: false,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        upvotedBy: ['user1', 'user2', 'user3'],
        downvotedBy: ['user4'],
      ),
      ForumPost(
        id: 'post_2',
        userId: 'demo_user_2',
        userEmail: 'jane.smith@example.com',
        userName: 'Jane Smith',
        title: 'Best practices for state management',
        content: 'What are the best practices for managing state in Flutter applications? I\'m currently using Provider but wondering if BLoC would be better for my use case.',
        category: 'Flutter',
        tags: ['flutter', 'state-management', 'best-practices', 'bloc'],
        upvotes: 22,
        downvotes: 1,
        commentCount: 12,
        isPinned: false,
        isLocked: false,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
        upvotedBy: ['user1', 'user2', 'user3', 'user4'],
        downvotedBy: [],
      ),
      ForumPost(
        id: 'post_3',
        userId: 'demo_user_3',
        userEmail: 'bob.johnson@example.com',
        userName: 'Bob Johnson',
        title: 'Firebase Authentication Setup Help',
        content: 'Having trouble setting up Firebase Authentication. Can someone help me with the configuration steps?',
        category: 'Firebase',
        tags: ['firebase', 'authentication', 'help', 'setup'],
        upvotes: 8,
        downvotes: 0,
        commentCount: 5,
        isPinned: false,
        isLocked: false,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        upvotedBy: ['user1', 'user2'],
        downvotedBy: [],
      ),
      ForumPost(
        id: 'post_4',
        userId: 'demo_user_4',
        userEmail: 'alice.williams@example.com',
        userName: 'Alice Williams',
        title: 'Dart Language Tips and Tricks',
        content: 'Share your favorite Dart language tips and tricks! Let\'s help each other write better code.',
        category: 'Dart',
        tags: ['dart', 'tips', 'tricks', 'programming'],
        upvotes: 18,
        downvotes: 0,
        commentCount: 15,
        isPinned: false,
        isLocked: false,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 6)),
        upvotedBy: ['user1', 'user2', 'user3', 'user4', 'user5'],
        downvotedBy: [],
      ),
    ]);
  }

  @override
  Future<List<ForumPost>> getPosts({String? category}) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    if (category != null && category.isNotEmpty) {
      return _mockPosts.where((post) => post.category == category).toList();
    }
    return List.from(_mockPosts);
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
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    final now = DateTime.now();
    final post = ForumPost(
      id: 'post_${_mockPosts.length + 1}',
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
      createdAt: now,
      updatedAt: now,
      upvotedBy: [],
      downvotedBy: [],
    );
    _mockPosts.add(post);
    return post;
  }

  @override
  Future<void> upvotePost(String postId, String userId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    final index = _mockPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _mockPosts[index];
      final upvotedBy = List<String>.from(post.upvotedBy);
      final downvotedBy = List<String>.from(post.downvotedBy);

      if (upvotedBy.contains(userId)) {
        upvotedBy.remove(userId);
      } else {
        upvotedBy.add(userId);
        downvotedBy.remove(userId);
      }

      _mockPosts[index] = post.copyWith(
        upvotes: upvotedBy.length,
        downvotes: downvotedBy.length,
        upvotedBy: upvotedBy,
        downvotedBy: downvotedBy,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> downvotePost(String postId, String userId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    final index = _mockPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _mockPosts[index];
      final upvotedBy = List<String>.from(post.upvotedBy);
      final downvotedBy = List<String>.from(post.downvotedBy);

      if (downvotedBy.contains(userId)) {
        downvotedBy.remove(userId);
      } else {
        downvotedBy.add(userId);
        upvotedBy.remove(userId);
      }

      _mockPosts[index] = post.copyWith(
        upvotes: upvotedBy.length,
        downvotes: downvotedBy.length,
        upvotedBy: upvotedBy,
        downvotedBy: downvotedBy,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    final index = _mockPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _mockPosts[index];
      _mockPosts[index] = post.copyWith(
        title: updates['title'] as String? ?? post.title,
        content: updates['content'] as String? ?? post.content,
        category: updates['category'] as String? ?? post.category,
        tags: updates['tags'] as List<String>? ?? post.tags,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    _mockPosts.removeWhere((post) => post.id == postId);
  }
}

