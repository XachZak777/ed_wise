import 'package:uuid/uuid.dart';
import '../../../core/config/app_config.dart';
import '../../../core/repositories/study_plan_repository.dart';
import '../models/study_plan.dart';
import '../models/study_plan_progress_strategy.dart';

class MockStudyPlanRepository implements StudyPlanRepository {
  final List<StudyPlan> _mockStudyPlans = [];
  final StudyPlanProgressStrategy _progressStrategy;

  MockStudyPlanRepository({
    StudyPlanProgressStrategy? progressStrategy,
  }) : _progressStrategy = progressStrategy ?? SimpleStudyPlanProgressStrategy() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final uuid = Uuid();
    final now = DateTime.now();
    
    _mockStudyPlans.addAll([
      _progressStrategy.withUpdatedProgressForPlan(
        StudyPlan(
        id: 'plan_1',
        userId: 'demo_user',
        title: 'Flutter Development Course',
        description: 'Complete Flutter development course with hands-on projects and real-world examples',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
        subjects: [
          Subject(
            id: uuid.v4(),
            name: 'Dart Basics',
            description: 'Learn Dart programming fundamentals',
            color: '#2196F3',
            tasks: [
              Task(
                id: uuid.v4(),
                title: 'Variables and Data Types',
                description: 'Learn about Dart variables, types, and type inference',
                status: TaskStatus.completed,
                priority: 1,
                createdAt: now.subtract(const Duration(days: 25)),
                completedAt: now.subtract(const Duration(days: 24)),
              ),
              Task(
                id: uuid.v4(),
                title: 'Functions and Classes',
                description: 'Understand functions, classes, and object-oriented programming',
                status: TaskStatus.inProgress,
                priority: 2,
                createdAt: now.subtract(const Duration(days: 20)),
              ),
              Task(
                id: uuid.v4(),
                title: 'Collections and Generics',
                description: 'Master Lists, Maps, Sets, and generic types',
                status: TaskStatus.pending,
                priority: 2,
                createdAt: now.subtract(const Duration(days: 15)),
              ),
            ],
            totalTasks: 3,
            completedTasks: 1,
            progress: 0.33,
          ),
          Subject(
            id: uuid.v4(),
            name: 'Flutter Widgets',
            description: 'Understanding Flutter widget system',
            color: '#4CAF50',
            tasks: [
              Task(
                id: uuid.v4(),
                title: 'Stateless vs Stateful Widgets',
                description: 'Learn the difference and when to use each',
                status: TaskStatus.completed,
                priority: 1,
                createdAt: now.subtract(const Duration(days: 10)),
                completedAt: now.subtract(const Duration(days: 9)),
              ),
              Task(
                id: uuid.v4(),
                title: 'Layout Widgets',
                description: 'Row, Column, Stack, and Container widgets',
                status: TaskStatus.inProgress,
                priority: 1,
                createdAt: now.subtract(const Duration(days: 8)),
              ),
            ],
            totalTasks: 2,
            completedTasks: 1,
            progress: 0.5,
          ),
        ],
        status: StudyPlanStatus.active,
        totalTasks: 5,
        completedTasks: 2,
        progress: 0.0,
      ),
      ),
      _progressStrategy.withUpdatedProgressForPlan(
        StudyPlan(
        id: 'plan_2',
        userId: 'demo_user',
        title: 'Firebase Integration',
        description: 'Master Firebase services for Flutter apps - Authentication, Firestore, Storage',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 2)),
        subjects: [
          Subject(
            id: uuid.v4(),
            name: 'Firebase Auth',
            description: 'User authentication with Firebase',
            color: '#FF9800',
            tasks: [
              Task(
                id: uuid.v4(),
                title: 'Email/Password Authentication',
                description: 'Implement email and password sign-in',
                status: TaskStatus.completed,
                priority: 1,
                createdAt: now.subtract(const Duration(days: 12)),
                completedAt: now.subtract(const Duration(days: 11)),
              ),
              Task(
                id: uuid.v4(),
                title: 'Google Sign-In',
                description: 'Add Google authentication',
                status: TaskStatus.pending,
                priority: 2,
                createdAt: now.subtract(const Duration(days: 10)),
              ),
            ],
            totalTasks: 2,
            completedTasks: 1,
            progress: 0.5,
          ),
        ],
        status: StudyPlanStatus.active,
        totalTasks: 2,
        completedTasks: 1,
        progress: 0.0,
      ),
      ),
    ]);
  }

  @override
  Future<List<StudyPlan>> getStudyPlans(String userId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    // For presentation: Show demo plans for any user, plus user's own plans
    final userPlans = _mockStudyPlans.where((plan) => plan.userId == userId).toList();
    
    // If user has no plans, show demo plans with updated userId for presentation
    if (userPlans.isEmpty && _mockStudyPlans.isNotEmpty) {
      return _mockStudyPlans.map((plan) => plan.copyWith(userId: userId)).toList();
    }
    
    return userPlans;
  }

  @override
  Future<StudyPlan> createStudyPlan(String userId, String title, String description) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    final uuid = Uuid();
    final now = DateTime.now();
    
    final studyPlan = StudyPlan(
      id: 'plan_${_mockStudyPlans.length + 1}',
      userId: userId,
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
      subjects: [],
      status: StudyPlanStatus.active,
      totalTasks: 0,
      completedTasks: 0,
      progress: 0.0,
    );

    _mockStudyPlans.add(studyPlan);
    return studyPlan;
  }

  @override
  Future<void> updateStudyPlan(String planId, Map<String, dynamic> updates) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    final index = _mockStudyPlans.indexWhere((plan) => plan.id == planId);
    if (index != -1) {
      final plan = _mockStudyPlans[index];
      _mockStudyPlans[index] = StudyPlan(
        id: plan.id,
        userId: plan.userId,
        title: updates['title'] ?? plan.title,
        description: updates['description'] ?? plan.description,
        createdAt: plan.createdAt,
        updatedAt: DateTime.now(),
        subjects: plan.subjects,
        status: updates['status'] != null 
            ? StudyPlanStatus.values.firstWhere((e) => e.name == updates['status'])
            : plan.status,
        totalTasks: plan.totalTasks,
        completedTasks: plan.completedTasks,
        progress: plan.progress,
      );
    }
  }

  @override
  Future<void> deleteStudyPlan(String planId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    _mockStudyPlans.removeWhere((plan) => plan.id == planId);
  }

  @override
  Future<void> addSubject(String planId, Subject subject) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    final index = _mockStudyPlans.indexWhere((plan) => plan.id == planId);
    if (index != -1) {
      final plan = _mockStudyPlans[index];
      final updatedSubjects = [...plan.subjects, subject];
      final updatedPlan = _progressStrategy.withUpdatedProgressForPlan(
        plan.copyWith(
          subjects: updatedSubjects,
          updatedAt: DateTime.now(),
        ),
      );
      _mockStudyPlans[index] = updatedPlan;
    }
  }

  @override
  Future<void> updateTaskStatus(
    String planId,
    String subjectId,
    String taskId,
    TaskStatus status,
  ) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    final planIndex = _mockStudyPlans.indexWhere((plan) => plan.id == planId);
    if (planIndex != -1) {
      final plan = _mockStudyPlans[planIndex];
      final subjectIndex = plan.subjects.indexWhere((subj) => subj.id == subjectId);
      if (subjectIndex != -1) {
        final subject = plan.subjects[subjectIndex];
        final taskIndex = subject.tasks.indexWhere((task) => task.id == taskId);
        if (taskIndex != -1) {
          final task = subject.tasks[taskIndex];
          final updatedTask = Task(
            id: task.id,
            title: task.title,
            description: task.description,
            status: status,
            priority: task.priority,
            createdAt: task.createdAt,
            dueDate: task.dueDate,
            completedAt: status == TaskStatus.completed ? DateTime.now() : task.completedAt,
          );
          final updatedTasks = List<Task>.from(subject.tasks);
          updatedTasks[taskIndex] = updatedTask;

          final subjectWithUpdatedTasks = Subject(
            id: subject.id,
            name: subject.name,
            description: subject.description,
            color: subject.color,
            tasks: updatedTasks,
            // These will be recalculated by the strategy
            totalTasks: subject.totalTasks,
            completedTasks: subject.completedTasks,
            progress: subject.progress,
          );

          final updatedSubject =
              _progressStrategy.withUpdatedProgressForSubject(subjectWithUpdatedTasks);

          final updatedSubjects = List<Subject>.from(plan.subjects);
          updatedSubjects[subjectIndex] = updatedSubject;

          final updatedPlan = _progressStrategy.withUpdatedProgressForPlan(
            plan.copyWith(
              subjects: updatedSubjects,
              updatedAt: DateTime.now(),
            ),
          );

          _mockStudyPlans[planIndex] = updatedPlan;
        }
      }
    }
  }
}

