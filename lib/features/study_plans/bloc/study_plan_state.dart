import 'package:equatable/equatable.dart';
import '../models/study_plan.dart';

abstract class StudyPlanState extends Equatable {
  const StudyPlanState();

  @override
  List<Object?> get props => [];
}

class StudyPlanInitial extends StudyPlanState {
  const StudyPlanInitial();
}

class StudyPlanLoading extends StudyPlanState {
  const StudyPlanLoading();
}

class StudyPlanLoaded extends StudyPlanState {
  final List<StudyPlan> studyPlans;

  const StudyPlanLoaded({required this.studyPlans});

  @override
  List<Object?> get props => [studyPlans];
}

class StudyPlanCreated extends StudyPlanState {
  final StudyPlan studyPlan;

  const StudyPlanCreated({required this.studyPlan});

  @override
  List<Object?> get props => [studyPlan];
}

class StudyPlanUpdated extends StudyPlanState {
  final StudyPlan studyPlan;

  const StudyPlanUpdated({required this.studyPlan});

  @override
  List<Object?> get props => [studyPlan];
}

class StudyPlanDeleted extends StudyPlanState {
  const StudyPlanDeleted();
}

class StudyPlanError extends StudyPlanState {
  final String message;

  const StudyPlanError({required this.message});

  @override
  List<Object?> get props => [message];
}

