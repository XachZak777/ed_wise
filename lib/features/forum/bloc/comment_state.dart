import 'package:equatable/equatable.dart';
import '../models/forum_post.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {
  const CommentInitial();
}

class CommentLoading extends CommentState {
  const CommentLoading();
}

class CommentLoaded extends CommentState {
  final List<ForumComment> comments;

  const CommentLoaded({required this.comments});

  @override
  List<Object?> get props => [comments];
}

class CommentCreated extends CommentState {
  final ForumComment comment;

  const CommentCreated({required this.comment});

  @override
  List<Object?> get props => [comment];
}

class CommentError extends CommentState {
  final String message;

  const CommentError({required this.message});

  @override
  List<Object?> get props => [message];
}

