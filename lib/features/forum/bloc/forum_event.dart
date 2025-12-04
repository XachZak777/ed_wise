import 'package:equatable/equatable.dart';
import '../models/forum_post.dart';

abstract class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

class ForumLoadRequested extends ForumEvent {
  final String? category;

  const ForumLoadRequested({this.category});

  @override
  List<Object?> get props => [category];
}

class ForumPostCreateRequested extends ForumEvent {
  final String userId;
  final String userName;
  final String userEmail;
  final String title;
  final String content;
  final String category;
  final List<String> tags;

  const ForumPostCreateRequested({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
  });

  @override
  List<Object?> get props => [userId, userName, userEmail, title, content, category, tags];
}

class ForumPostUpvoteRequested extends ForumEvent {
  final String postId;
  final String userId;

  const ForumPostUpvoteRequested({
    required this.postId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, userId];
}

class ForumPostDownvoteRequested extends ForumEvent {
  final String postId;
  final String userId;

  const ForumPostDownvoteRequested({
    required this.postId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, userId];
}

class ForumPostEditRequested extends ForumEvent {
  final String postId;
  final String title;
  final String content;
  final String category;
  final List<String> tags;

  const ForumPostEditRequested({
    required this.postId,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
  });

  @override
  List<Object?> get props => [postId, title, content, category, tags];
}

class ForumPostDeleteRequested extends ForumEvent {
  final String postId;

  const ForumPostDeleteRequested({required this.postId});

  @override
  List<Object?> get props => [postId];
}

