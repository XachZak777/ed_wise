import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ed_wise/features/study_plans/bloc/study_plan_bloc.dart';
import 'package:ed_wise/features/study_plans/bloc/study_plan_event.dart';
import 'package:ed_wise/features/study_plans/bloc/study_plan_state.dart';
import 'package:ed_wise/core/repositories/study_plan_repository.dart';
import 'package:ed_wise/features/study_plans/models/study_plan.dart';

import 'study_plan_bloc_test.mocks.dart';

@GenerateMocks([StudyPlanRepository])
void main() {
  late MockStudyPlanRepository mockRepository;
  late List<StudyPlan> mockStudyPlans;
  late StudyPlan mockStudyPlan;

  setUp(() {
    mockRepository = MockStudyPlanRepository();
    
    mockStudyPlan = StudyPlan(
      id: 'plan_1',
      userId: 'user_1',
      title: 'Test Plan',
      description: 'Test Description',
      status: StudyPlanStatus.active,
      subjects: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      totalTasks: 0,
      completedTasks: 0,
      progress: 0.0,
    );
    
    mockStudyPlans = [mockStudyPlan];
  });

  group('StudyPlanBloc', () {
    test('initial state is StudyPlanInitial', () {
      expect(
        StudyPlanBloc(repository: mockRepository).state,
        equals(const StudyPlanInitial()),
      );
    });

    blocTest<StudyPlanBloc, StudyPlanState>(
      'emits [StudyPlanLoading, StudyPlanLoaded] when plans load successfully',
      build: () {
        when(mockRepository.getStudyPlans(any))
            .thenAnswer((_) async => mockStudyPlans);
        return StudyPlanBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const StudyPlanLoadRequested(userId: 'user_1')),
      expect: () => [
        const StudyPlanLoading(),
        StudyPlanLoaded(studyPlans: mockStudyPlans),
      ],
    );

    blocTest<StudyPlanBloc, StudyPlanState>(
      'emits [StudyPlanLoading, StudyPlanError] when load fails',
      build: () {
        when(mockRepository.getStudyPlans(any))
            .thenThrow(Exception('Failed to load'));
        return StudyPlanBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const StudyPlanLoadRequested(userId: 'user_1')),
      expect: () => [
        const StudyPlanLoading(),
        const StudyPlanError(message: 'Exception: Failed to load'),
      ],
    );

    blocTest<StudyPlanBloc, StudyPlanState>(
      'emits [StudyPlanLoading, StudyPlanCreated, StudyPlanLoaded] when plan created',
      build: () {
        when(mockRepository.createStudyPlan(any, any, any))
            .thenAnswer((_) async => mockStudyPlan);
        when(mockRepository.getStudyPlans(any))
            .thenAnswer((_) async => mockStudyPlans);
        return StudyPlanBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const StudyPlanCreateRequested(
          userId: 'user_1',
          title: 'New Plan',
          description: 'New Description',
        ),
      ),
      expect: () => [
        const StudyPlanLoading(),
        StudyPlanCreated(studyPlan: mockStudyPlan),
        StudyPlanLoaded(studyPlans: mockStudyPlans),
      ],
    );

    blocTest<StudyPlanBloc, StudyPlanState>(
      'emits [StudyPlanLoading, StudyPlanError] when createStudyPlan fails',
      build: () {
        when(mockRepository.createStudyPlan(any, any, any))
            .thenThrow(Exception('Failed to create'));
        return StudyPlanBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const StudyPlanCreateRequested(
          userId: 'user_1',
          title: 'New Plan',
          description: 'New Description',
        ),
      ),
      expect: () => [
        const StudyPlanLoading(),
        const StudyPlanError(message: 'Exception: Failed to create'),
      ],
    );

    blocTest<StudyPlanBloc, StudyPlanState>(
      'emits [StudyPlanError] when updating without loaded plans (no userId)',
      build: () => StudyPlanBloc(repository: mockRepository),
      act: (bloc) => bloc.add(
        const StudyPlanUpdateRequested(
          planId: 'unknown',
          updates: {'title': 'Updated'},
        ),
      ),
      expect: () => const <StudyPlanState>[
        StudyPlanError(message: 'Cannot update: User ID not found'),
      ],
    );

    blocTest<StudyPlanBloc, StudyPlanState>(
      'emits [StudyPlanLoading, StudyPlanLoaded] when study plan is updated successfully',
      build: () {
        when(mockRepository.updateStudyPlan(any, any))
            .thenAnswer((_) async => {});
        when(mockRepository.getStudyPlans(any))
            .thenAnswer((_) async => mockStudyPlans);
        return StudyPlanBloc(repository: mockRepository);
      },
      seed: () => StudyPlanLoaded(studyPlans: mockStudyPlans),
      act: (bloc) => bloc.add(
        const StudyPlanUpdateRequested(
          planId: 'plan_1',
          updates: {'title': 'Updated Title'},
        ),
      ),
      expect: () => [
        const StudyPlanLoading(),
        StudyPlanLoaded(studyPlans: mockStudyPlans),
      ],
    );

    blocTest<StudyPlanBloc, StudyPlanState>(
      'emits [StudyPlanLoading, StudyPlanError] when updateStudyPlan fails',
      build: () {
        when(mockRepository.updateStudyPlan(any, any))
            .thenThrow(Exception('Failed to update'));
        return StudyPlanBloc(repository: mockRepository);
      },
      seed: () => StudyPlanLoaded(studyPlans: mockStudyPlans),
      act: (bloc) => bloc.add(
        const StudyPlanUpdateRequested(
          planId: 'plan_1',
          updates: {'title': 'Updated Title'},
        ),
      ),
      expect: () => [
        const StudyPlanLoading(),
        const StudyPlanError(message: 'Exception: Failed to update'),
      ],
    );

    blocTest<StudyPlanBloc, StudyPlanState>(
      'emits [StudyPlanLoading, StudyPlanDeleted] when deleting without loaded plans (no userId)',
      build: () {
        when(mockRepository.deleteStudyPlan(any))
            .thenAnswer((_) async => {});
        return StudyPlanBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const StudyPlanDeleteRequested(planId: 'plan_1')),
      expect: () => const <StudyPlanState>[
        StudyPlanLoading(),
        StudyPlanDeleted(),
      ],
    );

    blocTest<StudyPlanBloc, StudyPlanState>(
      'emits [StudyPlanLoading, StudyPlanError] when deleteStudyPlan fails',
      build: () {
        when(mockRepository.deleteStudyPlan(any))
            .thenThrow(Exception('Failed to delete'));
        return StudyPlanBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const StudyPlanDeleteRequested(planId: 'plan_1')),
      expect: () => [
        const StudyPlanLoading(),
        const StudyPlanError(message: 'Exception: Failed to delete'),
      ],
    );
  });
}

