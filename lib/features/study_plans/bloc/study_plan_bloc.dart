import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/study_plan_repository.dart';
import 'study_plan_event.dart';
import 'study_plan_state.dart';

class StudyPlanBloc extends Bloc<StudyPlanEvent, StudyPlanState> {
  final StudyPlanRepository _repository;

  StudyPlanBloc({StudyPlanRepository? repository})
      : _repository = repository ?? StudyPlanRepository.instance,
        super(const StudyPlanInitial()) {
    on<StudyPlanLoadRequested>(_onLoadRequested);
    on<StudyPlanCreateRequested>(_onCreateRequested);
    on<StudyPlanUpdateRequested>(_onUpdateRequested);
    on<StudyPlanDeleteRequested>(_onDeleteRequested);
    on<StudyPlanAddSubjectRequested>(_onAddSubjectRequested);
    on<StudyPlanUpdateTaskStatusRequested>(_onUpdateTaskStatusRequested);
  }

  Future<void> _onLoadRequested(
    StudyPlanLoadRequested event,
    Emitter<StudyPlanState> emit,
  ) async {
    emit(const StudyPlanLoading());
    try {
      final studyPlans = await _repository.getStudyPlans(event.userId);
      emit(StudyPlanLoaded(studyPlans: studyPlans));
    } catch (e) {
      emit(StudyPlanError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    StudyPlanCreateRequested event,
    Emitter<StudyPlanState> emit,
  ) async {
    emit(const StudyPlanLoading());
    try {
      final studyPlan = await _repository.createStudyPlan(
        event.userId,
        event.title,
        event.description,
      );
      emit(StudyPlanCreated(studyPlan: studyPlan));
      // Reload plans
      final studyPlans = await _repository.getStudyPlans(event.userId);
      emit(StudyPlanLoaded(studyPlans: studyPlans));
    } catch (e) {
      emit(StudyPlanError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    StudyPlanUpdateRequested event,
    Emitter<StudyPlanState> emit,
  ) async {
    emit(const StudyPlanLoading());
    try {
      await _repository.updateStudyPlan(event.planId, event.updates);
      // Reload to get updated plan
      final plans = await _repository.getStudyPlans(
        (state as StudyPlanLoaded).studyPlans.firstWhere((p) => p.id == event.planId).userId,
      );
      emit(StudyPlanLoaded(studyPlans: plans));
    } catch (e) {
      emit(StudyPlanError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    StudyPlanDeleteRequested event,
    Emitter<StudyPlanState> emit,
  ) async {
    emit(const StudyPlanLoading());
    try {
      // Get userId before deleting
      String? userId;
      if (state is StudyPlanLoaded) {
        final plan = (state as StudyPlanLoaded).studyPlans.firstWhere(
          (p) => p.id == event.planId,
          orElse: () => (state as StudyPlanLoaded).studyPlans.first,
        );
        userId = plan.userId;
      }
      
      await _repository.deleteStudyPlan(event.planId);
      
      // Reload plans if we have userId
      if (userId != null) {
        final studyPlans = await _repository.getStudyPlans(userId);
        emit(StudyPlanLoaded(studyPlans: studyPlans));
      } else {
        emit(const StudyPlanDeleted());
      }
    } catch (e) {
      emit(StudyPlanError(message: e.toString()));
    }
  }

  Future<void> _onAddSubjectRequested(
    StudyPlanAddSubjectRequested event,
    Emitter<StudyPlanState> emit,
  ) async {
    emit(const StudyPlanLoading());
    try {
      await _repository.addSubject(event.planId, event.subject);
      // Reload plans
      if (state is StudyPlanLoaded) {
        final userId = (state as StudyPlanLoaded).studyPlans.first.userId;
        final studyPlans = await _repository.getStudyPlans(userId);
        emit(StudyPlanLoaded(studyPlans: studyPlans));
      }
    } catch (e) {
      emit(StudyPlanError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTaskStatusRequested(
    StudyPlanUpdateTaskStatusRequested event,
    Emitter<StudyPlanState> emit,
  ) async {
    emit(const StudyPlanLoading());
    try {
      await _repository.updateTaskStatus(
        event.planId,
        event.subjectId,
        event.taskId,
        event.status,
      );
      // Reload plans
      if (state is StudyPlanLoaded) {
        final userId = (state as StudyPlanLoaded).studyPlans.first.userId;
        final studyPlans = await _repository.getStudyPlans(userId);
        emit(StudyPlanLoaded(studyPlans: studyPlans));
      }
    } catch (e) {
      emit(StudyPlanError(message: e.toString()));
    }
  }
}

