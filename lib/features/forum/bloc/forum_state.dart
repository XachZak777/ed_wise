import 'package:equatable/equatable.dart';
import '../models/forum_post.dart';

abstract class ForumState extends Equatable {
  const ForumState();

  @override
  List<Object?> get props => [];
}

class ForumInitial extends ForumState {
  const ForumInitial();
}

class ForumLoading extends ForumState {
  const ForumLoading();
}

class ForumLoaded extends ForumState {
  final List<ForumPost> posts;

  const ForumLoaded({required this.posts});

  @override
  List<Object?> get props => [posts];
}

class ForumPostCreated extends ForumState {
  final ForumPost post;

  const ForumPostCreated({required this.post});

  @override
  List<Object?> get props => [post];
}

class ForumError extends ForumState {
  final String message;

  const ForumError({required this.message});

  @override
  List<Object?> get props => [message];
}

