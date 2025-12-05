import 'package:ed_wise/features/forum/models/forum_post.dart';
import 'package:ed_wise/features/forum/widgets/forum_post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ForumPostCard', () {
    late ForumPost post;

    setUp(() {
      final now = DateTime.now();
      post = ForumPost(
        id: 'post_1',
        userId: 'user_1',
        userEmail: 'test@example.com',
        userName: 'Test User',
        title: 'Test Post',
        content: 'This is a test post content',
        category: 'Flutter',
        tags: const ['tag1', 'tag2', 'tag3', 'tag4'],
        upvotes: 1,
        downvotes: 2,
        commentCount: 3,
        isPinned: true,
        isLocked: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now,
        upvotedBy: const [],
        downvotedBy: const [],
      );
    });

    testWidgets('renders title, content and metadata', (tester) async {
      await tester.pumpWidget(
        TestHelper.createTestWidget(
          child: ForumPostCard(post: post),
        ),
      );

      expect(find.text('Test Post'), findsOneWidget);
      expect(find.textContaining('This is a test post content'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Pinned'), findsOneWidget);
      expect(find.text('3'), findsWidgets); // upvotes/downvotes/comments counts
      expect(find.text('#tag1'), findsOneWidget);
      expect(find.text('#tag2'), findsOneWidget);
      expect(find.text('#tag3'), findsOneWidget);
      // Only first 3 tags should be shown
      expect(find.text('#tag4'), findsNothing);
    });

    testWidgets('invokes callbacks on tap and vote actions', (tester) async {
      var tapped = false;
      var upvoted = false;
      var downvoted = false;

      await tester.pumpWidget(
        TestHelper.createTestWidget(
          child: ForumPostCard(
            post: post,
            onTap: () => tapped = true,
            onUpvote: () => upvoted = true,
            onDownvote: () => downvoted = true,
          ),
        ),
      );

      await tester.tap(find.byType(ForumPostCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);

      await tester.tap(find.byIcon(Icons.thumb_up_outlined));
      await tester.pumpAndSettle();
      expect(upvoted, isTrue);

      await tester.tap(find.byIcon(Icons.thumb_down_outlined));
      await tester.pumpAndSettle();
      expect(downvoted, isTrue);
    });
  });
}

