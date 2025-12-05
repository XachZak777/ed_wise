import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_wise/features/study_plans/models/study_plan.dart';

void main() {
  group('StudyPlan Model Tests', () {
    final now = DateTime.now();
    final timestamp = Timestamp.fromDate(now);

    test('StudyPlan.fromMap creates instance correctly', () {
      final map = {
        'userId': 'user_1',
        'title': 'Test Plan',
        'description': 'Test Description',
        'createdAt': timestamp,
        'updatedAt': timestamp,
        'subjects': [],
        'status': 'active',
        'totalTasks': 5,
        'completedTasks': 2,
        'progress': 0.4,
      };

      final studyPlan = StudyPlan.fromMap(map, 'plan_1');

      expect(studyPlan.id, 'plan_1');
      expect(studyPlan.userId, 'user_1');
      expect(studyPlan.title, 'Test Plan');
      expect(studyPlan.description, 'Test Description');
      expect(studyPlan.status, StudyPlanStatus.active);
      expect(studyPlan.totalTasks, 5);
      expect(studyPlan.completedTasks, 2);
      expect(studyPlan.progress, 0.4);
    });

    test('StudyPlan.toMap converts to map correctly', () {
      final studyPlan = StudyPlan(
        id: 'plan_1',
        userId: 'user_1',
        title: 'Test Plan',
        description: 'Test Description',
        createdAt: now,
        updatedAt: now,
        subjects: [],
        status: StudyPlanStatus.active,
        totalTasks: 5,
        completedTasks: 2,
        progress: 0.4,
      );

      final map = studyPlan.toMap();

      expect(map['userId'], 'user_1');
      expect(map['title'], 'Test Plan');
      expect(map['description'], 'Test Description');
      expect(map['status'], 'active');
      expect(map['totalTasks'], 5);
      expect(map['completedTasks'], 2);
      expect(map['progress'], 0.4);
    });

    test('StudyPlan.copyWith creates modified copy', () {
      final original = StudyPlan(
        id: 'plan_1',
        userId: 'user_1',
        title: 'Original',
        description: 'Original Desc',
        createdAt: now,
        updatedAt: now,
        subjects: [],
        status: StudyPlanStatus.active,
        totalTasks: 0,
        completedTasks: 0,
        progress: 0.0,
      );

      final modified = original.copyWith(
        title: 'Modified',
        status: StudyPlanStatus.completed,
      );

      expect(modified.id, original.id);
      expect(modified.userId, original.userId);
      expect(modified.title, 'Modified');
      expect(modified.description, original.description);
      expect(modified.status, StudyPlanStatus.completed);
    });
  });

  group('Subject Model Tests', () {
    final now = DateTime.now();
    final timestamp = Timestamp.fromDate(now);

    test('Subject.fromMap creates instance correctly', () {
      final map = {
        'id': 'subj_1',
        'name': 'Mathematics',
        'description': 'Math subject',
        'color': '#FF0000',
        'tasks': [],
        'totalTasks': 3,
        'completedTasks': 1,
        'progress': 0.33,
      };

      final subject = Subject.fromMap(map);

      expect(subject.id, 'subj_1');
      expect(subject.name, 'Mathematics');
      expect(subject.description, 'Math subject');
      expect(subject.color, '#FF0000');
      expect(subject.totalTasks, 3);
      expect(subject.completedTasks, 1);
      expect(subject.progress, 0.33);
    });

    test('Subject.toMap converts to map correctly', () {
      final subject = Subject(
        id: 'subj_1',
        name: 'Mathematics',
        description: 'Math subject',
        color: '#FF0000',
        tasks: [],
        totalTasks: 3,
        completedTasks: 1,
        progress: 0.33,
      );

      final map = subject.toMap();

      expect(map['id'], 'subj_1');
      expect(map['name'], 'Mathematics');
      expect(map['description'], 'Math subject');
      expect(map['color'], '#FF0000');
      expect(map['totalTasks'], 3);
      expect(map['completedTasks'], 1);
      expect(map['progress'], 0.33);
    });
  });

  group('Task Model Tests', () {
    final now = DateTime.now();
    final dueDate = now.add(const Duration(days: 7));
    final timestamp = Timestamp.fromDate(now);
    final dueTimestamp = Timestamp.fromDate(dueDate);

    test('Task.fromMap creates instance correctly', () {
      final map = {
        'id': 'task_1',
        'title': 'Complete assignment',
        'description': 'Finish the homework',
        'status': 'pending',
        'dueDate': dueTimestamp,
        'priority': 2,
        'createdAt': timestamp,
        'completedAt': null,
      };

      final task = Task.fromMap(map);

      expect(task.id, 'task_1');
      expect(task.title, 'Complete assignment');
      expect(task.description, 'Finish the homework');
      expect(task.status, TaskStatus.pending);
      expect(task.priority, 2);
    });

    test('Task.toMap converts to map correctly', () {
      final task = Task(
        id: 'task_1',
        title: 'Complete assignment',
        description: 'Finish the homework',
        status: TaskStatus.pending,
        dueDate: dueDate,
        priority: 2,
        createdAt: now,
      );

      final map = task.toMap();

      expect(map['id'], 'task_1');
      expect(map['title'], 'Complete assignment');
      expect(map['description'], 'Finish the homework');
      expect(map['status'], 'pending');
      expect(map['priority'], 2);
    });
  });
}

