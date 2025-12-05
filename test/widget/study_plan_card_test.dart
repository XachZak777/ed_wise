import 'package:ed_wise/features/study_plans/models/study_plan.dart';
import 'package:ed_wise/features/study_plans/widgets/study_plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('StudyPlanCard', () {
    late StudyPlan plan;

    setUp(() {
      final now = DateTime.now();
      plan = StudyPlan(
        id: 'plan_1',
        userId: 'user_1',
        title: 'Test Plan',
        description: 'Test Description',
        createdAt: now,
        updatedAt: now,
        subjects: const [],
        status: StudyPlanStatus.active,
        totalTasks: 0,
        completedTasks: 0,
        progress: 0.0,
      );
    });

    testWidgets('renders title, description and stats', (tester) async {
      await tester.pumpWidget(
        TestHelper.createTestWidget(
          child: StudyPlanCard(studyPlan: plan),
        ),
      );

      expect(find.text('Test Plan'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('0 subjects'), findsOneWidget);
      expect(find.text('0/0 tasks'), findsOneWidget);
      expect(find.text('0% complete'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('invokes callbacks on tap and popup actions', (tester) async {
      var tapped = false;
      var edited = false;
      var deleted = false;

      await tester.pumpWidget(
        TestHelper.createTestWidget(
          child: StudyPlanCard(
            studyPlan: plan,
            onTap: () => tapped = true,
            onEdit: () => edited = true,
            onDelete: () => deleted = true,
          ),
        ),
      );

      // Tap the card body
      await tester.tap(find.byType(StudyPlanCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);

      // Open popup and select "Edit"
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(edited, isTrue);

      // Open popup and select "Delete"
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
    });

    testWidgets('shows correct status text for each StudyPlanStatus',
        (tester) async {
      Future<void> expectStatus(StudyPlanStatus status, String expectedText) async {
        await tester.pumpWidget(
          TestHelper.createTestWidget(
            child: StudyPlanCard(
              studyPlan: plan.copyWith(status: status),
            ),
          ),
        );
        expect(find.text(expectedText), findsOneWidget);
      }

      await expectStatus(StudyPlanStatus.active, 'Active');
      await expectStatus(StudyPlanStatus.paused, 'Paused');
      await expectStatus(StudyPlanStatus.completed, 'Completed');
      await expectStatus(StudyPlanStatus.archived, 'Archived');
    });
  });
}

