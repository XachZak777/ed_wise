import 'package:flutter_test/flutter_test.dart';

import 'package:ed_wise/features/study_plans/models/study_plan.dart';
import 'package:ed_wise/features/study_plans/repositories/mock_study_plan_repository.dart';

void main() {
  group('MockStudyPlanRepository', () {
    test('getStudyPlans returns demo plans for demo_user', () async {
      final repository = MockStudyPlanRepository();

      final plans = await repository.getStudyPlans('demo_user');
      expect(plans, isNotEmpty);
      expect(plans.first.userId, 'demo_user');
    });

    test('getStudyPlans returns demo plans mapped to requesting user when none exist', () async {
      final repository = MockStudyPlanRepository();

      final plans = await repository.getStudyPlans('new_user');
      expect(plans, isNotEmpty);
      expect(plans.every((plan) => plan.userId == 'new_user'), isTrue);
    });

    test('createStudyPlan adds a new plan and returns it', () async {
      final repository = MockStudyPlanRepository();

      final created = await repository.createStudyPlan(
        'user_1',
        'New Plan',
        'New description',
      );

      expect(created.id, isNotEmpty);
      expect(created.userId, 'user_1');
      expect(created.title, 'New Plan');
      expect(created.description, 'New description');
      expect(created.subjects, isEmpty);
      expect(created.status, StudyPlanStatus.active);
      expect(created.totalTasks, 0);
      expect(created.completedTasks, 0);
      expect(created.progress, 0.0);

      final plans = await repository.getStudyPlans('user_1');
      expect(plans, isNotEmpty);
      expect(plans.any((plan) => plan.id == created.id), isTrue);
    });

    test('updateStudyPlan updates existing plan fields', () async {
      final repository = MockStudyPlanRepository();
      final initialPlans = await repository.getStudyPlans('demo_user');
      final plan = initialPlans.first;

      final originalUpdatedAt = plan.updatedAt;

      await repository.updateStudyPlan(plan.id, {
        'title': 'Updated Title',
        'description': 'Updated Description',
        'status': StudyPlanStatus.completed.name,
      });

      final updatedPlans = await repository.getStudyPlans('demo_user');
      final updatedPlan = updatedPlans.firstWhere((p) => p.id == plan.id);

      expect(updatedPlan.title, 'Updated Title');
      expect(updatedPlan.description, 'Updated Description');
      expect(updatedPlan.status, StudyPlanStatus.completed);
      expect(updatedPlan.updatedAt.isAfter(originalUpdatedAt), isTrue);
    });

    test('deleteStudyPlan removes the plan', () async {
      final repository = MockStudyPlanRepository();
      final plans = await repository.getStudyPlans('demo_user');
      final plan = plans.first;

      await repository.deleteStudyPlan(plan.id);

      final updatedPlans = await repository.getStudyPlans('demo_user');
      expect(updatedPlans.any((p) => p.id == plan.id), isFalse);
    });

    test('addSubject appends subject and updates totalTasks', () async {
      final repository = MockStudyPlanRepository();
      final plans = await repository.getStudyPlans('demo_user');
      final plan = plans.first;

      final newSubject = Subject(
        id: 'subject_new',
        name: 'New Subject',
        description: 'Description',
        color: '#FFFFFF',
        tasks: const [],
        totalTasks: 2,
        completedTasks: 0,
        progress: 0.0,
      );

      final initialTotalTasks = plan.totalTasks;

      await repository.addSubject(plan.id, newSubject);

      final updatedPlans = await repository.getStudyPlans('demo_user');
      final updatedPlan = updatedPlans.firstWhere((p) => p.id == plan.id);

      expect(updatedPlan.subjects.length, plan.subjects.length + 1);
      expect(updatedPlan.totalTasks, initialTotalTasks + newSubject.totalTasks);
    });

    test('updateTaskStatus updates task and progress calculations', () async {
      final repository = MockStudyPlanRepository();
      final plans = await repository.getStudyPlans('demo_user');
      final plan = plans.first;

      final subject = plan.subjects.first;
      final task = subject.tasks.first;

      final previousPlanCompletedTasks = plan.completedTasks;
      final previousSubjectCompletedTasks = subject.completedTasks;

      await repository.updateTaskStatus(
        plan.id,
        subject.id,
        task.id,
        TaskStatus.completed,
      );

      final updatedPlans = await repository.getStudyPlans('demo_user');
      final updatedPlan = updatedPlans.firstWhere((p) => p.id == plan.id);
      final updatedSubject =
          updatedPlan.subjects.firstWhere((s) => s.id == subject.id);
      final updatedTask =
          updatedSubject.tasks.firstWhere((t) => t.id == task.id);

      expect(updatedTask.status, TaskStatus.completed);
      expect(
        updatedSubject.completedTasks,
        greaterThanOrEqualTo(previousSubjectCompletedTasks),
      );
      expect(
        updatedPlan.completedTasks,
        greaterThanOrEqualTo(previousPlanCompletedTasks),
      );
      expect(updatedSubject.progress, inInclusiveRange(0.0, 1.0));
      expect(updatedPlan.progress, inInclusiveRange(0.0, 1.0));
    });
  });
}


