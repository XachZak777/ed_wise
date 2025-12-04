import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  final bool isPinned;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> upvotedBy;
  final List<String> downvotedBy;

  ForumPost({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.isPinned,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
    required this.upvotedBy,
    required this.downvotedBy,
  });

  factory ForumPost.fromMap(Map<String, dynamic> map, String id) {
    return ForumPost(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      isPinned: map['isPinned'] ?? false,
      isLocked: map['isLocked'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      upvotedBy: List<String>.from(map['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(map['downvotedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentCount': commentCount,
      'isPinned': isPinned,
      'isLocked': isLocked,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
    };
  }

  ForumPost copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    int? upvotes,
    int? downvotes,
    int? commentCount,
    bool? isPinned,
    bool? isLocked,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
  }) {
    return ForumPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
    );
  }

  int get score => upvotes - downvotes;
}

class ForumComment {
  final String id;
  final String postId;
  final String userId;
  final String userEmail;
  final String userName;
  final String content;
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final String? parentCommentId; // For nested comments

  ForumComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.content,
    required this.upvotes,
    required this.downvotes,
    required this.createdAt,
    required this.updatedAt,
    required this.upvotedBy,
    required this.downvotedBy,
    this.parentCommentId,
  });

  factory ForumComment.fromMap(Map<String, dynamic> map, String id) {
    return ForumComment(
      id: id,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      content: map['content'] ?? '',
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      upvotedBy: List<String>.from(map['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(map['downvotedBy'] ?? []),
      parentCommentId: map['parentCommentId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'content': content,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'parentCommentId': parentCommentId,
    };
  }

  ForumComment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userEmail,
    String? userName,
    String? content,
    int? upvotes,
    int? downvotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
    String? parentCommentId,
  }) {
    return ForumComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      parentCommentId: parentCommentId ?? this.parentCommentId,
    );
  }

  int get score => upvotes - downvotes;
}

class ForumCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final int postCount;
  final DateTime createdAt;

  ForumCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.postCount,
    required this.createdAt,
  });

  factory ForumCategory.fromMap(Map<String, dynamic> map, String id) {
    return ForumCategory(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? 'forum',
      color: map['color'] ?? '#2196F3',
      postCount: map['postCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'postCount': postCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
