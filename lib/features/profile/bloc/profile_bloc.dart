import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/repositories/auth_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;

  ProfileBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository.instance,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileUpdateNameRequested>(_onProfileUpdateNameRequested);
    on<ProfileUpdateEmailRequested>(_onProfileUpdateEmailRequested);
    on<ProfileUpdatePasswordRequested>(_onProfileUpdatePasswordRequested);
    on<ProfileUpdatePhotoRequested>(_onProfileUpdatePhotoRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final profile = await _authRepository.getUserProfile(event.uid);
      if (profile != null) {
        emit(ProfileLoaded(profile: profile));
      } else {
        emit(const ProfileError(message: 'Profile not found'));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      await _authRepository.updateUserProfile(event.uid, event.data);
      final profile = await _authRepository.getUserProfile(event.uid);
      if (profile != null) {
        emit(ProfileUpdated(profile: profile));
      } else {
        emit(const ProfileError(message: 'Failed to reload profile'));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onProfileUpdateNameRequested(
    ProfileUpdateNameRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        await user.updateDisplayName(event.name);
        await _authRepository.updateUserProfile(user.uid, {'name': event.name});
        final profile = await _authRepository.getUserProfile(user.uid);
        if (profile != null) {
          emit(ProfileUpdated(profile: profile));
        }
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onProfileUpdateEmailRequested(
    ProfileUpdateEmailRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(event.email);
        await _authRepository.updateUserProfile(user.uid, {'email': event.email});
        final profile = await _authRepository.getUserProfile(user.uid);
        if (profile != null) {
          emit(ProfileUpdated(profile: profile));
        }
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onProfileUpdatePasswordRequested(
    ProfileUpdatePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        await user.updatePassword(event.password);
        emit(const ProfileUpdated(profile: {}));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onProfileUpdatePhotoRequested(
    ProfileUpdatePhotoRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        await user.updatePhotoURL(event.photoUrl);
        await _authRepository.updateUserProfile(user.uid, {'photoUrl': event.photoUrl});
        final profile = await _authRepository.getUserProfile(user.uid);
        if (profile != null) {
          emit(ProfileUpdated(profile: profile));
        }
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}

