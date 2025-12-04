import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/forum_repository.dart';
import 'forum_event.dart';
import 'forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final ForumRepository _repository;

  ForumBloc({ForumRepository? repository})
      : _repository = repository ?? ForumRepository.instance,
        super(const ForumInitial()) {
    on<ForumLoadRequested>(_onLoadRequested);
    on<ForumPostCreateRequested>(_onCreateRequested);
    on<ForumPostUpvoteRequested>(_onUpvoteRequested);
    on<ForumPostDownvoteRequested>(_onDownvoteRequested);
    on<ForumPostEditRequested>(_onEditRequested);
    on<ForumPostDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    ForumLoadRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(const ForumLoading());
    try {
      final posts = await _repository.getPosts(category: event.category);
      emit(ForumLoaded(posts: posts));
    } catch (e) {
      emit(ForumError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    ForumPostCreateRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(const ForumLoading());
    try {
      final post = await _repository.createPost(
        userId: event.userId,
        userName: event.userName,
        userEmail: event.userEmail,
        title: event.title,
        content: event.content,
        category: event.category,
        tags: event.tags,
      );
      emit(ForumPostCreated(post: post));
      // Reload posts
      final posts = await _repository.getPosts();
      emit(ForumLoaded(posts: posts));
    } catch (e) {
      emit(ForumError(message: e.toString()));
    }
  }

  Future<void> _onUpvoteRequested(
    ForumPostUpvoteRequested event,
    Emitter<ForumState> emit,
  ) async {
    try {
      await _repository.upvotePost(event.postId, event.userId);
      // Reload posts
      final posts = await _repository.getPosts();
      emit(ForumLoaded(posts: posts));
    } catch (e) {
      emit(ForumError(message: e.toString()));
    }
  }

  Future<void> _onDownvoteRequested(
    ForumPostDownvoteRequested event,
    Emitter<ForumState> emit,
  ) async {
    try {
      await _repository.downvotePost(event.postId, event.userId);
      // Reload posts
      final posts = await _repository.getPosts();
      emit(ForumLoaded(posts: posts));
    } catch (e) {
      emit(ForumError(message: e.toString()));
    }
  }

  Future<void> _onEditRequested(
    ForumPostEditRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(const ForumLoading());
    try {
      await _repository.updatePost(event.postId, {
        'title': event.title,
        'content': event.content,
        'category': event.category,
        'tags': event.tags,
      });
      // Reload posts
      final posts = await _repository.getPosts();
      emit(ForumLoaded(posts: posts));
    } catch (e) {
      emit(ForumError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    ForumPostDeleteRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(const ForumLoading());
    try {
      await _repository.deletePost(event.postId);
      // Reload posts
      final posts = await _repository.getPosts();
      emit(ForumLoaded(posts: posts));
    } catch (e) {
      emit(ForumError(message: e.toString()));
    }
  }
}

