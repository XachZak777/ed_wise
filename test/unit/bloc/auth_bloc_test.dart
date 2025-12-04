import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ed_wise/features/auth/bloc/auth_bloc.dart';
import 'package:ed_wise/features/auth/bloc/auth_event.dart';
import 'package:ed_wise/features/auth/bloc/auth_state.dart';
import 'package:ed_wise/core/repositories/auth_repository.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository, User, UserCredential])
void main() {
  late MockAuthRepository mockAuthRepository;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    
    when(mockUser.uid).thenReturn('test_uid');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUserCredential.user).thenReturn(mockUser);
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      // Use empty stream to avoid immediate emission
      when(mockAuthRepository.authStateChanges).thenAnswer((_) => const Stream<User?>.empty());
      expect(
        AuthBloc(authRepository: mockAuthRepository).state,
        equals(const AuthInitial()),
      );
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when AuthCheckRequested and no user',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(null);
        // Use empty stream to avoid immediate emission
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => const Stream<User?>.empty());
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when AuthCheckRequested and user exists',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(mockUser);
        // Use empty stream to avoid immediate emission
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => const Stream<User?>.empty());
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [AuthAuthenticated(user: mockUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
      build: () {
        when(mockAuthRepository.signInWithEmail(any, any))
            .thenAnswer((_) async => mockUserCredential);
        // Use empty stream to avoid immediate emission
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => const Stream.empty());
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthSignInRequested(
          email: 'test@example.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: mockUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when sign in fails',
      build: () {
        when(mockAuthRepository.signInWithEmail(any, any))
            .thenThrow(Exception('Sign in failed'));
        // Use empty stream to avoid immediate emission
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => const Stream.empty());
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthSignInRequested(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Exception: Sign in failed'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when sign up succeeds',
      build: () {
        when(mockAuthRepository.signUpWithEmail(any, any, any))
            .thenAnswer((_) async => mockUserCredential);
        // Use empty stream to avoid immediate emission
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => const Stream.empty());
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthSignUpRequested(
          email: 'new@example.com',
          password: 'password123',
          name: 'New User',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: mockUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when sign out succeeds',
      build: () {
        when(mockAuthRepository.signOut()).thenAnswer((_) async => {});
        // Use empty stream to avoid immediate emission
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => const Stream.empty());
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}

