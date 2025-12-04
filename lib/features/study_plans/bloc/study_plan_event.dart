import 'package:equatable/equatable.dart';
import '../models/study_plan.dart';

abstract class StudyPlanEvent extends Equatable {
  const StudyPlanEvent();

  @override
  List<Object?> get props => [];
}

class StudyPlanLoadRequested extends StudyPlanEvent {
  final String userId;

  const StudyPlanLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class StudyPlanCreateRequested extends StudyPlanEvent {
  final String userId;
  final String title;
  final String description;

  const StudyPlanCreateRequested({
    required this.userId,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [userId, title, description];
}

class StudyPlanUpdateRequested extends StudyPlanEvent {
  final String planId;
  final Map<String, dynamic> updates;

  const StudyPlanUpdateRequested({
    required this.planId,
    required this.updates,
  });

  @override
  List<Object?> get props => [planId, updates];
}

class StudyPlanDeleteRequested extends StudyPlanEvent {
  final String planId;

  const StudyPlanDeleteRequested({required this.planId});

  @override
  List<Object?> get props => [planId];
}

class StudyPlanAddSubjectRequested extends StudyPlanEvent {
  final String planId;
  final Subject subject;

  const StudyPlanAddSubjectRequested({
    required this.planId,
    required this.subject,
  });

  @override
  List<Object?> get props => [planId, subject];
}

class StudyPlanUpdateTaskStatusRequested extends StudyPlanEvent {
  final String planId;
  final String subjectId;
  final String taskId;
  final TaskStatus status;

  const StudyPlanUpdateTaskStatusRequested({
    required this.planId,
    required this.subjectId,
    required this.taskId,
    required this.status,
  });

  @override
  List<Object?> get props => [planId, subjectId, taskId, status];
}

