import 'package:equatable/equatable.dart';
import '../models/forum_post.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class CommentLoadRequested extends CommentEvent {
  final String postId;

  const CommentLoadRequested({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class CommentCreateRequested extends CommentEvent {
  final String postId;
  final String userId;
  final String userName;
  final String userEmail;
  final String content;
  final String? parentCommentId;

  const CommentCreateRequested({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.content,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [postId, userId, userName, userEmail, content, parentCommentId];
}

class CommentDeleteRequested extends CommentEvent {
  final String commentId;

  const CommentDeleteRequested({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class CommentUpvoteRequested extends CommentEvent {
  final String commentId;
  final String userId;

  const CommentUpvoteRequested({
    required this.commentId,
    required this.userId,
  });

  @override
  List<Object?> get props => [commentId, userId];
}

class CommentDownvoteRequested extends CommentEvent {
  final String commentId;
  final String userId;

  const CommentDownvoteRequested({
    required this.commentId,
    required this.userId,
  });

  @override
  List<Object?> get props => [commentId, userId];
}

