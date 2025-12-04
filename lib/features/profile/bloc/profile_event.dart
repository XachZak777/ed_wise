import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String uid;

  const ProfileLoadRequested({required this.uid});

  @override
  List<Object?> get props => [uid];
}

class ProfileUpdateRequested extends ProfileEvent {
  final String uid;
  final Map<String, dynamic> data;

  const ProfileUpdateRequested({
    required this.uid,
    required this.data,
  });

  @override
  List<Object?> get props => [uid, data];
}

class ProfileUpdateNameRequested extends ProfileEvent {
  final String name;

  const ProfileUpdateNameRequested({required this.name});

  @override
  List<Object?> get props => [name];
}

class ProfileUpdateEmailRequested extends ProfileEvent {
  final String email;

  const ProfileUpdateEmailRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class ProfileUpdatePasswordRequested extends ProfileEvent {
  final String password;

  const ProfileUpdatePasswordRequested({required this.password});

  @override
  List<Object?> get props => [password];
}

class ProfileUpdatePhotoRequested extends ProfileEvent {
  final String photoUrl;

  const ProfileUpdatePhotoRequested({required this.photoUrl});

  @override
  List<Object?> get props => [photoUrl];
}

