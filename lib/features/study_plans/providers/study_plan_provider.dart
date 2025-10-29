import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../models/study_plan.dart';

class StudyPlanProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<StudyPlan>> _studyPlansController = 
      StreamController<List<StudyPlan>>.broadcast();

  Stream<List<StudyPlan>> get studyPlansStream => _studyPlansController.stream;

  Future<void> loadStudyPlans(String userId) async {
    try {
      _firestore
          .collection(AppConstants.studyPlansCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        final studyPlans = snapshot.docs
            .map((doc) => StudyPlan.fromMap(doc.data(), doc.id))
            .toList();
        _studyPlansController.add(studyPlans);
      });
    } catch (e) {
      _studyPlansController.addError(e);
    }
  }

  Future<String> createStudyPlan(
    String userId,
    String title,
    String description,
  ) async {
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

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create study plan: $e');
    }
  }

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

  Future<void> addSubject(String planId, Subject subject) async {
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

  Future<void> updateSubject(String planId, String subjectId, Subject updatedSubject) async {
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

        subjects[subjectIndex] = updatedSubject.toMap();

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
      throw Exception('Failed to update subject: $e');
    }
  }

  Future<void> deleteSubject(String planId, String subjectId) async {
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
        
        subjects.removeWhere((s) => s['id'] == subjectId);

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
      throw Exception('Failed to delete subject: $e');
    }
  }

  Future<void> updateTaskStatus(
    String planId,
    String subjectId,
    String taskId,
    TaskStatus status,
  ) async {
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

  void dispose() {
    _studyPlansController.close();
  }
}
