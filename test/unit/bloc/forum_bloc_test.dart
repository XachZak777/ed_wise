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
  });
}

