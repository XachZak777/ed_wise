import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ed_wise/features/study_plans/models/study_plan.dart';

void main() {
  group('StudyPlan model', () {
    test('fromMap and toMap are inverse operations', () {
      final createdAt = DateTime.utc(2024, 1, 1);
      final updatedAt = DateTime.utc(2024, 1, 2);

      final map = {
        'userId': 'user_1',
        'title': 'My Study Plan',
        'description': 'Description',
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'subjects': [
          {
            'id': 'sub_1',
            'name': 'Math',
            'description': 'Algebra',
            'color': '#FFFFFF',
            'tasks': [
              {
                'id': 'task_1',
                'title': 'Read chapter 1',
                'description': 'Introduction',
                'status': 'completed',
                'dueDate': Timestamp.fromDate(createdAt),
                'priority': 1,
                'createdAt': Timestamp.fromDate(createdAt),
                'completedAt': Timestamp.fromDate(updatedAt),
              },
            ],
            'totalTasks': 1,
            'completedTasks': 1,
            'progress': 1.0,
          },
        ],
        'status': 'active',
        'totalTasks': 1,
        'completedTasks': 1,
        'progress': 1.0,
      };

      final plan = StudyPlan.fromMap(map, 'plan_1');
      expect(plan.id, 'plan_1');
      expect(plan.userId, 'user_1');
      expect(plan.title, 'My Study Plan');
      expect(plan.description, 'Description');
      expect(plan.createdAt, createdAt);
      expect(plan.updatedAt, updatedAt);
      expect(plan.status, StudyPlanStatus.active);
      expect(plan.totalTasks, 1);
      expect(plan.completedTasks, 1);
      expect(plan.progress, 1.0);
      expect(plan.subjects.length, 1);

      final subject = plan.subjects.first;
      expect(subject.id, 'sub_1');
      expect(subject.name, 'Math');
      expect(subject.description, 'Algebra');
      expect(subject.color, '#FFFFFF');
      expect(subject.totalTasks, 1);
      expect(subject.completedTasks, 1);
      expect(subject.progress, 1.0);
      expect(subject.tasks.length, 1);

      final task = subject.tasks.first;
      expect(task.id, 'task_1');
      expect(task.title, 'Read chapter 1');
      expect(task.description, 'Introduction');
      expect(task.status, TaskStatus.completed);
      expect(task.dueDate, createdAt);
      expect(task.priority, 1);
      expect(task.createdAt, createdAt);
      expect(task.completedAt, updatedAt);

      final toMap = plan.toMap();
      expect(toMap['userId'], map['userId']);
      expect(toMap['title'], map['title']);
      expect(toMap['description'], map['description']);
      expect(toMap['createdAt'], Timestamp.fromDate(createdAt));
      expect(toMap['updatedAt'], Timestamp.fromDate(updatedAt));
      expect(toMap['status'], 'active');
      expect(toMap['totalTasks'], 1);
      expect(toMap['completedTasks'], 1);
      expect(toMap['progress'], 1.0);
      expect(toMap['subjects'], isA<List>());
    });

    test('fromMap applies defaults and status fallbacks', () {
      final now = DateTime.utc(2024, 1, 1);

      final map = {
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'subjects': [],
        'status': 'unknown-status',
      };

      final plan = StudyPlan.fromMap(map, 'id');
      expect(plan.id, 'id');
      expect(plan.userId, '');
      expect(plan.title, '');
      expect(plan.description, '');
      expect(plan.status, StudyPlanStatus.active);
      expect(plan.totalTasks, 0);
      expect(plan.completedTasks, 0);
      expect(plan.progress, 0.0);
      expect(plan.subjects, isEmpty);
    });

    test('copyWith returns updated instance while preserving other fields', () {
      final base = StudyPlan(
        id: 'id',
        userId: 'user',
        title: 'title',
        description: 'desc',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 2),
        subjects: const [],
        status: StudyPlanStatus.active,
        totalTasks: 0,
        completedTasks: 0,
        progress: 0.0,
      );

      final updated = base.copyWith(
        title: 'new title',
        description: 'new desc',
        status: StudyPlanStatus.completed,
        progress: 1.0,
      );

      expect(updated.id, base.id);
      expect(updated.userId, base.userId);
      expect(updated.title, 'new title');
      expect(updated.description, 'new desc');
      expect(updated.status, StudyPlanStatus.completed);
      expect(updated.progress, 1.0);
      expect(updated.totalTasks, base.totalTasks);
      expect(updated.completedTasks, base.completedTasks);
    });
  });

  group('Subject model', () {
    test('fromMap and toMap are inverse operations', () {
      final map = {
        'id': 'sub_1',
        'name': 'Math',
        'description': 'Algebra',
        'color': '#FFFFFF',
        'tasks': [
          {
            'id': 'task_1',
            'title': 'Task',
            'description': 'Desc',
            'status': 'pending',
            'createdAt': Timestamp.fromDate(DateTime.utc(2024, 1, 1)),
            'priority': 1,
          },
        ],
        'totalTasks': 1,
        'completedTasks': 0,
        'progress': 0.0,
      };

      final subject = Subject.fromMap(map);
      expect(subject.id, 'sub_1');
      expect(subject.name, 'Math');
      expect(subject.description, 'Algebra');
      expect(subject.color, '#FFFFFF');
      expect(subject.totalTasks, 1);
      expect(subject.completedTasks, 0);
      expect(subject.progress, 0.0);
      expect(subject.tasks.length, 1);

      final toMap = subject.toMap();
      expect(toMap['id'], map['id']);
      expect(toMap['name'], map['name']);
      expect(toMap['description'], map['description']);
      expect(toMap['color'], map['color']);
      expect(toMap['totalTasks'], map['totalTasks']);
      expect(toMap['completedTasks'], map['completedTasks']);
      expect(toMap['progress'], map['progress']);
      expect(toMap['tasks'], isA<List>());
    });

    test('fromMap applies defaults when fields are missing', () {
      final subject = Subject.fromMap({});
      expect(subject.id, '');
      expect(subject.name, '');
      expect(subject.description, '');
      expect(subject.color, '#2196F3');
      expect(subject.tasks, isEmpty);
      expect(subject.totalTasks, 0);
      expect(subject.completedTasks, 0);
      expect(subject.progress, 0.0);
    });
  });

  group('Task model', () {
    test('fromMap and toMap are inverse operations', () {
      final createdAt = DateTime.utc(2024, 1, 1);
      final completedAt = DateTime.utc(2024, 1, 2);

      final map = {
        'id': 'task_1',
        'title': 'Task',
        'description': 'Desc',
        'status': 'inProgress',
        'dueDate': Timestamp.fromDate(createdAt),
        'priority': 2,
        'createdAt': Timestamp.fromDate(createdAt),
        'completedAt': Timestamp.fromDate(completedAt),
      };

      final task = Task.fromMap(map);
      expect(task.id, 'task_1');
      expect(task.title, 'Task');
      expect(task.description, 'Desc');
      expect(task.status, TaskStatus.inProgress);
      expect(task.dueDate, createdAt);
      expect(task.priority, 2);
      expect(task.createdAt, createdAt);
      expect(task.completedAt, completedAt);

      final toMap = task.toMap();
      expect(toMap['id'], map['id']);
      expect(toMap['title'], map['title']);
      expect(toMap['description'], map['description']);
      expect(toMap['status'], 'inProgress');
      expect(toMap['dueDate'], Timestamp.fromDate(createdAt));
      expect(toMap['priority'], 2);
      expect(toMap['createdAt'], Timestamp.fromDate(createdAt));
      expect(toMap['completedAt'], Timestamp.fromDate(completedAt));
    });

    test('fromMap uses default values for missing fields and status', () {
      final now = DateTime.utc(2024, 1, 1);

      final map = {
        'createdAt': Timestamp.fromDate(now),
        'status': 'unknown',
      };

      final task = Task.fromMap(map);
      expect(task.id, '');
      expect(task.title, '');
      expect(task.description, '');
      expect(task.status, TaskStatus.pending);
      expect(task.dueDate, isNull);
      expect(task.priority, 1);
      expect(task.createdAt, now);
      expect(task.completedAt, isNull);
    });
  });
}


