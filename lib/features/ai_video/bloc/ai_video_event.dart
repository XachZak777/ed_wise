import 'package:equatable/equatable.dart';
import '../models/ai_video.dart';

abstract class AiVideoEvent extends Equatable {
  const AiVideoEvent();

  @override
  List<Object?> get props => [];
}

class AiVideoLoadRequested extends AiVideoEvent {
  final String userId;

  const AiVideoLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AiVideoCreateRequested extends AiVideoEvent {
  final VideoGenerationRequest request;
  final String userId;

  const AiVideoCreateRequested({
    required this.request,
    required this.userId,
  });

  @override
  List<Object?> get props => [request, userId];
}

