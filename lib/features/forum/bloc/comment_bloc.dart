import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/comment_repository.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository _repository;

  CommentBloc({CommentRepository? repository})
      : _repository = repository ?? CommentRepository.instance,
        super(const CommentInitial()) {
    on<CommentLoadRequested>(_onLoadRequested);
    on<CommentCreateRequested>(_onCreateRequested);
    on<CommentDeleteRequested>(_onDeleteRequested);
    on<CommentUpvoteRequested>(_onUpvoteRequested);
    on<CommentDownvoteRequested>(_onDownvoteRequested);
  }

  Future<void> _onLoadRequested(
    CommentLoadRequested event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());
    try {
      final comments = await _repository.getComments(event.postId);
      emit(CommentLoaded(comments: comments));
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    CommentCreateRequested event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());
    try {
      final comment = await _repository.createComment(
        postId: event.postId,
        userId: event.userId,
        userName: event.userName,
        userEmail: event.userEmail,
        content: event.content,
        parentCommentId: event.parentCommentId,
      );
      emit(CommentCreated(comment: comment));
      // Reload comments
      final comments = await _repository.getComments(event.postId);
      emit(CommentLoaded(comments: comments));
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    CommentDeleteRequested event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());
    try {
      // Get postId from current state if possible
      String? postId;
      if (state is CommentLoaded) {
        final loadedState = state as CommentLoaded;

        if (loadedState.comments.isNotEmpty) {
          // Try to find the matching comment; if it's not present but we still
          // have comments for the same post, fall back to the first one just
          // to recover the postId for reloading.
          final comment = loadedState.comments.firstWhere(
            (c) => c.id == event.commentId,
            orElse: () => loadedState.comments.first,
          );
          postId = comment.postId;
        }
      }

      await _repository.deleteComment(event.commentId);

      // Reload comments if we have postId
      if (postId != null) {
        final comments = await _repository.getComments(postId);
        emit(CommentLoaded(comments: comments));
      } else {
        emit(const CommentLoaded(comments: []));
      }
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> _onUpvoteRequested(
    CommentUpvoteRequested event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await _repository.upvoteComment(event.commentId, event.userId);

      // Reload comments only when we have a non-empty list to infer postId from
      if (state is CommentLoaded) {
        final loadedState = state as CommentLoaded;
        if (loadedState.comments.isNotEmpty) {
          final postId = loadedState.comments.first.postId;
          final comments = await _repository.getComments(postId);
          emit(CommentLoaded(comments: comments));
        }
      }
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> _onDownvoteRequested(
    CommentDownvoteRequested event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await _repository.downvoteComment(event.commentId, event.userId);

      // Reload comments only when we have a non-empty list to infer postId from
      if (state is CommentLoaded) {
        final loadedState = state as CommentLoaded;
        if (loadedState.comments.isNotEmpty) {
          final postId = loadedState.comments.first.postId;
          final comments = await _repository.getComments(postId);
          emit(CommentLoaded(comments: comments));
        }
      }
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }
}

