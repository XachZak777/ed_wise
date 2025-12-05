import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ed_wise/features/profile/bloc/profile_bloc.dart';
import 'package:ed_wise/features/profile/bloc/profile_event.dart';
import 'package:ed_wise/features/profile/bloc/profile_state.dart';
import 'package:ed_wise/core/repositories/auth_repository.dart';

import 'profile_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockRepository;
  final mockProfile = {'name': 'Test User', 'email': 'test@example.com'};

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('ProfileBloc', () {
    test('initial state is ProfileInitial', () {
      expect(
        ProfileBloc(authRepository: mockRepository).state,
        equals(const ProfileInitial()),
      );
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when profile loads successfully',
      build: () {
        when(mockRepository.getUserProfile(any))
            .thenAnswer((_) async => mockProfile);
        return ProfileBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested(uid: 'user_1')),
      expect: () => [
        const ProfileLoading(),
        ProfileLoaded(profile: mockProfile),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when profile not found',
      build: () {
        when(mockRepository.getUserProfile(any))
            .thenAnswer((_) async => null);
        return ProfileBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested(uid: 'user_1')),
      expect: () => [
        const ProfileLoading(),
        const ProfileError(message: 'Profile not found'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when load fails',
      build: () {
        when(mockRepository.getUserProfile(any))
            .thenThrow(Exception('Failed to load'));
        return ProfileBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested(uid: 'user_1')),
      expect: () => [
        const ProfileLoading(),
        const ProfileError(message: 'Exception: Failed to load'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileUpdated] when profile is updated successfully',
      build: () {
        when(mockRepository.updateUserProfile(any, any))
            .thenAnswer((_) async => {});
        when(mockRepository.getUserProfile(any))
            .thenAnswer((_) async => mockProfile);
        return ProfileBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ProfileUpdateRequested(
          uid: 'user_1',
          data: {'name': 'Updated User'},
        ),
      ),
      expect: () => [
        const ProfileLoading(),
        ProfileUpdated(profile: mockProfile),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when updated profile cannot be reloaded',
      build: () {
        when(mockRepository.updateUserProfile(any, any))
            .thenAnswer((_) async => {});
        when(mockRepository.getUserProfile(any))
            .thenAnswer((_) async => null);
        return ProfileBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ProfileUpdateRequested(
          uid: 'user_1',
          data: {'name': 'Updated User'},
        ),
      ),
      expect: () => [
        const ProfileLoading(),
        const ProfileError(message: 'Failed to reload profile'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when updateUserProfile fails',
      build: () {
        when(mockRepository.updateUserProfile(any, any))
            .thenThrow(Exception('Failed to update'));
        return ProfileBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const ProfileUpdateRequested(
          uid: 'user_1',
          data: {'name': 'Updated User'},
        ),
      ),
      expect: () => [
        const ProfileLoading(),
        const ProfileError(message: 'Exception: Failed to update'),
      ],
    );
  });
}

