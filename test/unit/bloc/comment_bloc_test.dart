import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ed_wise/features/forum/bloc/comment_bloc.dart';
import 'package:ed_wise/features/forum/bloc/comment_event.dart';
import 'package:ed_wise/features/forum/bloc/comment_state.dart';
import 'package:ed_wise/core/repositories/comment_repository.dart';
import 'package:ed_wise/features/forum/models/forum_post.dart';

import 'comment_bloc_test.mocks.dart';

@GenerateMocks([CommentRepository])
void main() {
  late MockCommentRepository mockRepository;
  late List<ForumComment> mockComments;
  late ForumComment mockComment;

  setUp(() {
    mockRepository = MockCommentRepository();
    
    mockComment = ForumComment(
      id: 'comment_1',
      postId: 'post_1',
      userId: 'user_1',
      userEmail: 'test@example.com',
      userName: 'Test User',
      content: 'Test comment',
      upvotes: 0,
      downvotes: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      upvotedBy: [],
      downvotedBy: [],
    );
    
    mockComments = [mockComment];
  });

  group('CommentBloc', () {
    test('initial state is CommentInitial', () {
      expect(
        CommentBloc(repository: mockRepository).state,
        equals(const CommentInitial()),
      );
    });

    blocTest<CommentBloc, CommentState>(
      'emits [CommentLoading, CommentLoaded] when comments load successfully',
      build: () {
        when(mockRepository.getComments(any))
            .thenAnswer((_) async => mockComments);
        return CommentBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const CommentLoadRequested(postId: 'post_1')),
      expect: () => [
        const CommentLoading(),
        CommentLoaded(comments: mockComments),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'emits [CommentLoading, CommentError] when load fails',
      build: () {
        when(mockRepository.getComments(any))
            .thenThrow(Exception('Failed to load'));
        return CommentBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const CommentLoadRequested(postId: 'post_1')),
      expect: () => [
        const CommentLoading(),
        const CommentError(message: 'Exception: Failed to load'),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'emits [CommentLoading, CommentCreated, CommentLoaded] when comment created',
      build: () {
        when(mockRepository.createComment(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
          userName: anyNamed('userName'),
          userEmail: anyNamed('userEmail'),
          content: anyNamed('content'),
          parentCommentId: anyNamed('parentCommentId'),
        )).thenAnswer((_) async => mockComment);
        when(mockRepository.getComments(any))
            .thenAnswer((_) async => mockComments);
        return CommentBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const CommentCreateRequested(
          postId: 'post_1',
          userId: 'user_1',
          userName: 'Test User',
          userEmail: 'test@example.com',
          content: 'New comment',
        ),
      ),
      expect: () => [
        const CommentLoading(),
        CommentCreated(comment: mockComment),
        CommentLoaded(comments: mockComments),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'handles delete when comments list is empty without crashing',
      build: () {
        when(mockRepository.deleteComment(any))
            .thenAnswer((_) async => {});
        when(mockRepository.getComments(any))
            .thenAnswer((_) async => <ForumComment>[]);
        return CommentBloc(repository: mockRepository);
      },
      seed: () => CommentLoaded(comments: const []),
      act: (bloc) => bloc.add(const CommentDeleteRequested(commentId: 'unknown')),
      expect: () => [
        const CommentLoading(),
        isA<CommentLoaded>().having(
          (s) => s.comments.length,
          'comments length',
          0,
        ),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'reloads comments after upvote when comments are loaded',
      build: () {
        final updatedComments = [
          mockComment.copyWith(upvotes: mockComment.upvotes + 1),
        ];

        when(mockRepository.upvoteComment(any, any))
            .thenAnswer((_) async => {});
        when(mockRepository.getComments(any))
            .thenAnswer((_) async => updatedComments);

        return CommentBloc(repository: mockRepository);
      },
      seed: () => CommentLoaded(comments: [mockComment]),
      act: (bloc) => bloc.add(
        const CommentUpvoteRequested(
          commentId: 'comment_1',
          userId: 'user_1',
        ),
      ),
      expect: () => [
        isA<CommentLoaded>().having(
          (s) => s.comments.first.upvotes,
          'upvotes',
          1,
        ),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'does not crash on upvote when comments list is empty',
      build: () {
        when(mockRepository.upvoteComment(any, any))
            .thenAnswer((_) async => {});
        // No comments to reload; getComments should never be called, but
        // we still provide a safe stub in case.
        when(mockRepository.getComments(any))
            .thenAnswer((_) async => <ForumComment>[]);
        return CommentBloc(repository: mockRepository);
      },
      seed: () => CommentLoaded(comments: const []),
      act: (bloc) => bloc.add(
        const CommentUpvoteRequested(
          commentId: 'comment_1',
          userId: 'user_1',
        ),
      ),
      expect: () => <CommentState>[],
    );

    blocTest<CommentBloc, CommentState>(
      'does not crash on downvote when comments list is empty',
      build: () {
        when(mockRepository.downvoteComment(any, any))
            .thenAnswer((_) async => {});
        when(mockRepository.getComments(any))
            .thenAnswer((_) async => <ForumComment>[]);
        return CommentBloc(repository: mockRepository);
      },
      seed: () => CommentLoaded(comments: const []),
      act: (bloc) => bloc.add(
        const CommentDownvoteRequested(
          commentId: 'comment_1',
          userId: 'user_1',
        ),
      ),
      expect: () => <CommentState>[],
    );
  });
}

