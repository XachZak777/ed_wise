import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ed_wise/features/forum/bloc/forum_bloc.dart';
import 'package:ed_wise/features/forum/bloc/forum_event.dart';
import 'package:ed_wise/features/forum/bloc/forum_state.dart';
import 'package:ed_wise/core/repositories/forum_repository.dart';
import 'package:ed_wise/features/forum/models/forum_post.dart';

import 'forum_bloc_test.mocks.dart';

@GenerateMocks([ForumRepository])
void main() {
  late MockForumRepository mockRepository;
  late List<ForumPost> mockPosts;

  setUp(() {
    mockRepository = MockForumRepository();
    mockPosts = [
      ForumPost(
        id: 'post_1',
        userId: 'user_1',
        userEmail: 'test@example.com',
        userName: 'Test User',
        title: 'Test Post',
        content: 'Test Content',
        category: 'Flutter',
        tags: ['test'],
        upvotes: 0,
        downvotes: 0,
        commentCount: 0,
        isPinned: false,
        isLocked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        upvotedBy: [],
        downvotedBy: [],
      ),
    ];
  });

  group('ForumBloc', () {
    test('initial state is ForumInitial', () {
      expect(
        ForumBloc(repository: mockRepository).state,
        equals(const ForumInitial()),
      );
    });

    blocTest<ForumBloc, ForumState>(
      'emits [ForumLoading, ForumLoaded] when posts load successfully',
      build: () {
        when(mockRepository.getPosts(category: anyNamed('category')))
            .thenAnswer((_) async => mockPosts);
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const ForumLoadRequested()),
      expect: () => [
        const ForumLoading(),
        ForumLoaded(posts: mockPosts),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [ForumLoading, ForumError] when posts load fails',
      build: () {
        when(mockRepository.getPosts(category: anyNamed('category')))
            .thenThrow(Exception('Failed to load'));
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const ForumLoadRequested()),
      expect: () => [
        const ForumLoading(),
        const ForumError(message: 'Exception: Failed to load'),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [ForumLoading, ForumPostCreated, ForumLoaded] when post created',
      build: () {
        when(mockRepository.createPost(
          userId: anyNamed('userId'),
          userName: anyNamed('userName'),
          userEmail: anyNamed('userEmail'),
          title: anyNamed('title'),
          content: anyNamed('content'),
          category: anyNamed('category'),
          tags: anyNamed('tags'),
        )).thenAnswer((_) async => mockPosts.first);
        when(mockRepository.getPosts()).thenAnswer((_) async => mockPosts);
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ForumPostCreateRequested(
          userId: 'user_1',
          userName: 'Test User',
          userEmail: 'test@example.com',
          title: 'New Post',
          content: 'New Content',
          category: 'Flutter',
          tags: ['new'],
        ),
      ),
      expect: () => [
        const ForumLoading(),
        ForumPostCreated(post: mockPosts.first),
        ForumLoaded(posts: mockPosts),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [ForumLoading, ForumError] when createPost fails',
      build: () {
        when(mockRepository.createPost(
          userId: anyNamed('userId'),
          userName: anyNamed('userName'),
          userEmail: anyNamed('userEmail'),
          title: anyNamed('title'),
          content: anyNamed('content'),
          category: anyNamed('category'),
          tags: anyNamed('tags'),
        )).thenThrow(Exception('Failed to create'));
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ForumPostCreateRequested(
          userId: 'user_1',
          userName: 'Test User',
          userEmail: 'test@example.com',
          title: 'New Post',
          content: 'New Content',
          category: 'Flutter',
          tags: ['new'],
        ),
      ),
      expect: () => [
        const ForumLoading(),
        const ForumError(message: 'Exception: Failed to create'),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [ForumLoaded] when post upvoted successfully',
      build: () {
        final updatedPosts = [
          mockPosts.first.copyWith(upvotes: mockPosts.first.upvotes + 1),
        ];

        when(mockRepository.upvotePost(any, any))
            .thenAnswer((_) async => {});
        when(mockRepository.getPosts())
            .thenAnswer((_) async => updatedPosts);
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ForumPostUpvoteRequested(
          postId: 'post_1',
          userId: 'user_1',
        ),
      ),
      expect: () => [
        isA<ForumLoaded>().having(
          (s) => s.posts.first.upvotes,
          'upvotes',
          1,
        ),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [ForumError] when upvotePost fails',
      build: () {
        when(mockRepository.upvotePost(any, any))
            .thenThrow(Exception('Failed to upvote'));
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ForumPostUpvoteRequested(
          postId: 'post_1',
          userId: 'user_1',
        ),
      ),
      expect: () => [
        const ForumError(message: 'Exception: Failed to upvote'),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [ForumLoaded] when post downvoted successfully',
      build: () {
        final updatedPosts = [
          mockPosts.first.copyWith(downvotes: mockPosts.first.downvotes + 1),
        ];

        when(mockRepository.downvotePost(any, any))
            .thenAnswer((_) async => {});
        when(mockRepository.getPosts())
            .thenAnswer((_) async => updatedPosts);
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ForumPostDownvoteRequested(
          postId: 'post_1',
          userId: 'user_1',
        ),
      ),
      expect: () => [
        isA<ForumLoaded>().having(
          (s) => s.posts.first.downvotes,
          'downvotes',
          1,
        ),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [ForumError] when downvotePost fails',
      build: () {
        when(mockRepository.downvotePost(any, any))
            .thenThrow(Exception('Failed to downvote'));
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ForumPostDownvoteRequested(
          postId: 'post_1',
          userId: 'user_1',
        ),
      ),
      expect: () => [
        const ForumError(message: 'Exception: Failed to downvote'),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [ForumLoading, ForumLoaded] when post edited successfully',
      build: () {
        when(mockRepository.updatePost(any, any))
            .thenAnswer((_) async => {});
        when(mockRepository.getPosts())
            .thenAnswer((_) async => mockPosts);
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ForumPostEditRequested(
          postId: 'post_1',
          title: 'Updated',
          content: 'Updated content',
          category: 'Flutter',
          tags: ['updated'],
        ),
      ),
      expect: () => [
        const ForumLoading(),
        ForumLoaded(posts: mockPosts),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [ForumLoading, ForumError] when updatePost fails',
      build: () {
        when(mockRepository.updatePost(any, any))
            .thenThrow(Exception('Failed to update'));
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ForumPostEditRequested(
          postId: 'post_1',
          title: 'Updated',
          content: 'Updated content',
          category: 'Flutter',
          tags: ['updated'],
        ),
      ),
      expect: () => [
        const ForumLoading(),
        const ForumError(message: 'Exception: Failed to update'),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [ForumLoading, ForumLoaded] when post deleted successfully',
      build: () {
        when(mockRepository.deletePost(any))
            .thenAnswer((_) async => {});
        when(mockRepository.getPosts())
            .thenAnswer((_) async => mockPosts);
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ForumPostDeleteRequested(postId: 'post_1'),
      ),
      expect: () => [
        const ForumLoading(),
        ForumLoaded(posts: mockPosts),
      ],
    );

    blocTest<ForumBloc, ForumState>(
      'emits [ForumLoading, ForumError] when deletePost fails',
      build: () {
        when(mockRepository.deletePost(any))
            .thenThrow(Exception('Failed to delete'));
        return ForumBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ForumPostDeleteRequested(postId: 'post_1'),
      ),
      expect: () => [
        const ForumLoading(),
        const ForumError(message: 'Exception: Failed to delete'),
      ],
    );
  });
}

