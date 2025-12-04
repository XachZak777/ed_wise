import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../../features/study_plans/models/study_plan.dart';
import '../../features/study_plans/repositories/mock_study_plan_repository.dart';

abstract class StudyPlanRepository {
  static StudyPlanRepository get instance {
    // Use mock data for presentation/demo
    if (AppConfig.useMockStudyPlans) {
      return MockStudyPlanRepository();
    }
    return FirebaseStudyPlanRepository();
  }

  Future<List<StudyPlan>> getStudyPlans(String userId);
  Future<StudyPlan> createStudyPlan(String userId, String title, String description);
  Future<void> updateStudyPlan(String planId, Map<String, dynamic> updates);
  Future<void> deleteStudyPlan(String planId);
  Future<void> addSubject(String planId, Subject subject);
  Future<void> updateTaskStatus(String planId, String subjectId, String taskId, TaskStatus status);
}

class FirebaseStudyPlanRepository implements StudyPlanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<StudyPlan>> getStudyPlans(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.studyPlansCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StudyPlan.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to load study plans: $e');
    }
  }

  @override
  Future<StudyPlan> createStudyPlan(String userId, String title, String description) async {
    try {
      final studyPlan = StudyPlan(
        id: '',
        userId: userId,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subjects: [],
        status: StudyPlanStatus.active,
        totalTasks: 0,
        completedTasks: 0,
        progress: 0.0,
      );

      final docRef = await _firestore
          .collection(AppConstants.studyPlansCollection)
          .add(studyPlan.toMap());

      return studyPlan.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create study plan: $e');
    }
  }

  @override
  Future<void> updateStudyPlan(String planId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(AppConstants.studyPlansCollection)
          .doc(planId)
          .update({
        ...updates,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update study plan: $e');
    }
  }

  @override
  Future<void> deleteStudyPlan(String planId) async {
    try {
      await _firestore
          .collection(AppConstants.studyPlansCollection)
          .doc(planId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete study plan: $e');
    }
  }

  @override
  Future<void> addSubject(String planId, Subject subject) async {
    // Implementation similar to provider
    try {
      final planRef = _firestore
          .collection(AppConstants.studyPlansCollection)
          .doc(planId);

      await _firestore.runTransaction((transaction) async {
        final planDoc = await transaction.get(planRef);
        if (!planDoc.exists) {
          throw Exception('Study plan not found');
        }

        final planData = planDoc.data()!;
        final subjects = List<Map<String, dynamic>>.from(planData['subjects'] ?? []);
        subjects.add(subject.toMap());

        final totalTasks = subjects.fold<int>(
          0,
          (total, subject) => total + ((subject['totalTasks'] ?? 0) as int),
        );

        transaction.update(planRef, {
          'subjects': subjects,
          'totalTasks': totalTasks,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Failed to add subject: $e');
    }
  }

  @override
  Future<void> updateTaskStatus(
    String planId,
    String subjectId,
    String taskId,
    TaskStatus status,
  ) async {
    // Implementation similar to provider
    try {
      final planRef = _firestore
          .collection(AppConstants.studyPlansCollection)
          .doc(planId);

      await _firestore.runTransaction((transaction) async {
        final planDoc = await transaction.get(planRef);
        if (!planDoc.exists) {
          throw Exception('Study plan not found');
        }

        final planData = planDoc.data()!;
        final subjects = List<Map<String, dynamic>>.from(planData['subjects'] ?? []);
        
        final subjectIndex = subjects.indexWhere((s) => s['id'] == subjectId);
        if (subjectIndex == -1) {
          throw Exception('Subject not found');
        }

        final subject = subjects[subjectIndex];
        final tasks = List<Map<String, dynamic>>.from(subject['tasks'] ?? []);
        
        final taskIndex = tasks.indexWhere((t) => t['id'] == taskId);
        if (taskIndex == -1) {
          throw Exception('Task not found');
        }

        tasks[taskIndex]['status'] = status.name;
        if (status == TaskStatus.completed) {
          tasks[taskIndex]['completedAt'] = Timestamp.fromDate(DateTime.now());
        }

        subject['tasks'] = tasks;
        subject['completedTasks'] = tasks.where((t) => t['status'] == TaskStatus.completed.name).length;
        subject['progress'] = subject['totalTasks'] > 0 
            ? subject['completedTasks'] / subject['totalTasks'] 
            : 0.0;

        subjects[subjectIndex] = subject;

        final totalTasks = subjects.fold<int>(
          0,
          (total, subject) => total + ((subject['totalTasks'] ?? 0) as int),
        );

        final completedTasks = subjects.fold<int>(
          0,
          (total, subject) => total + ((subject['completedTasks'] ?? 0) as int),
        );

        final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

        transaction.update(planRef, {
          'subjects': subjects,
          'totalTasks': totalTasks,
          'completedTasks': completedTasks,
          'progress': progress,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }
}

