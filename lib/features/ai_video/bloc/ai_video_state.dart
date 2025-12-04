import 'package:equatable/equatable.dart';
import '../models/ai_video.dart';

abstract class AiVideoState extends Equatable {
  const AiVideoState();

  @override
  List<Object?> get props => [];
}

class AiVideoInitial extends AiVideoState {
  const AiVideoInitial();
}

class AiVideoLoading extends AiVideoState {
  const AiVideoLoading();
}

class AiVideoLoaded extends AiVideoState {
  final List<AiVideo> videos;

  const AiVideoLoaded({required this.videos});

  @override
  List<Object?> get props => [videos];
}

class AiVideoCreated extends AiVideoState {
  final AiVideo video;

  const AiVideoCreated({required this.video});

  @override
  List<Object?> get props => [video];
}

class AiVideoError extends AiVideoState {
  final String message;

  const AiVideoError({required this.message});

  @override
  List<Object?> get props => [message];
}

