import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/ai_video_repository.dart';
import 'ai_video_event.dart';
import 'ai_video_state.dart';

class AiVideoBloc extends Bloc<AiVideoEvent, AiVideoState> {
  final AiVideoRepository _repository;

  AiVideoBloc({AiVideoRepository? repository})
      : _repository = repository ?? AiVideoRepository.instance,
        super(const AiVideoInitial()) {
    on<AiVideoLoadRequested>(_onLoadRequested);
    on<AiVideoCreateRequested>(_onCreateRequested);
  }

  Future<void> _onLoadRequested(
    AiVideoLoadRequested event,
    Emitter<AiVideoState> emit,
  ) async {
    emit(const AiVideoLoading());
    try {
      final videos = await _repository.getVideos(event.userId);
      emit(AiVideoLoaded(videos: videos));
    } catch (e) {
      emit(AiVideoError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    AiVideoCreateRequested event,
    Emitter<AiVideoState> emit,
  ) async {
    emit(const AiVideoLoading());
    try {
      final video = await _repository.createVideo(event.request, event.userId);
      emit(AiVideoCreated(video: video));
      // Reload videos
      final videos = await _repository.getVideos(event.userId);
      emit(AiVideoLoaded(videos: videos));
    } catch (e) {
      emit(AiVideoError(message: e.toString()));
    }
  }
}

