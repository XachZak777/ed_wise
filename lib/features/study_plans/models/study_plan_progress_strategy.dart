import 'study_plan.dart';

/// Strategy interface for calculating progress and task counters
/// for a [StudyPlan] and its [Subject]s.
abstract class StudyPlanProgressStrategy {
  /// Returns a new [Subject] instance with updated [totalTasks],
  /// [completedTasks] and [progress] values based on its [tasks].
  Subject withUpdatedProgressForSubject(Subject subject);

  /// Returns a new [StudyPlan] instance with updated [totalTasks],
  /// [completedTasks] and [progress] values based on its [subjects].
  StudyPlan withUpdatedProgressForPlan(StudyPlan plan);
}

/// Default implementation that:
/// - treats every [Task] as having equal weight
/// - calculates progress as completed / total
class SimpleStudyPlanProgressStrategy implements StudyPlanProgressStrategy {
  @override
  Subject withUpdatedProgressForSubject(Subject subject) {
    final totalTasks = subject.tasks.length;
    final completedTasks =
        subject.tasks.where((t) => t.status == TaskStatus.completed).length;
    final progress =
        totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Subject(
      id: subject.id,
      name: subject.name,
      description: subject.description,
      color: subject.color,
      tasks: subject.tasks,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      progress: progress,
    );
  }

  @override
  StudyPlan withUpdatedProgressForPlan(StudyPlan plan) {
    // First update all subjects based on their tasks
    final updatedSubjects = plan.subjects
        .map(withUpdatedProgressForSubject)
        .toList();

    final totalTasks = updatedSubjects.fold<int>(
      0,
      (total, subj) => total + subj.totalTasks,
    );
    final completedTasks = updatedSubjects.fold<int>(
      0,
      (total, subj) => total + subj.completedTasks,
    );
    final progress =
        totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return plan.copyWith(
      subjects: updatedSubjects,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      progress: progress,
    );
  }
}

