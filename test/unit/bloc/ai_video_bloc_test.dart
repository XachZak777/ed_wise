import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ed_wise/features/ai_video/bloc/ai_video_bloc.dart';
import 'package:ed_wise/features/ai_video/bloc/ai_video_event.dart';
import 'package:ed_wise/features/ai_video/bloc/ai_video_state.dart';
import 'package:ed_wise/core/repositories/ai_video_repository.dart';
import 'package:ed_wise/features/ai_video/models/ai_video.dart';

import 'ai_video_bloc_test.mocks.dart';

@GenerateMocks([AiVideoRepository])
void main() {
  late MockAiVideoRepository mockRepository;
  late List<AiVideo> mockVideos;
  late AiVideo mockVideo;
  late VideoGenerationRequest mockRequest;

  setUp(() {
    mockRepository = MockAiVideoRepository();
    
    mockRequest = VideoGenerationRequest(
      text: 'Test content',
      title: 'Test Video',
      style: VideoStyle.educational,
    );
    
    mockVideo = AiVideo(
      id: 'video_1',
      userId: 'user_1',
      title: 'Test Video',
      originalText: 'Test content',
      processedText: 'Test content',
      videoUrl: 'https://example.com/video.mp4',
      audioUrl: 'https://example.com/audio.mp3',
      status: VideoStatus.completed,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
      duration: 120,
      thumbnailUrl: 'https://example.com/thumb.jpg',
      metadata: {},
    );
    
    mockVideos = [mockVideo];
  });

  group('AiVideoBloc', () {
    test('initial state is AiVideoInitial', () {
      expect(
        AiVideoBloc(repository: mockRepository).state,
        equals(const AiVideoInitial()),
      );
    });

    blocTest<AiVideoBloc, AiVideoState>(
      'emits [AiVideoLoading, AiVideoLoaded] when videos load successfully',
      build: () {
        when(mockRepository.getVideos(any))
            .thenAnswer((_) async => mockVideos);
        return AiVideoBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const AiVideoLoadRequested(userId: 'user_1')),
      expect: () => [
        const AiVideoLoading(),
        AiVideoLoaded(videos: mockVideos),
      ],
    );

    blocTest<AiVideoBloc, AiVideoState>(
      'emits [AiVideoLoading, AiVideoError] when load fails',
      build: () {
        when(mockRepository.getVideos(any))
            .thenThrow(Exception('Failed to load'));
        return AiVideoBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const AiVideoLoadRequested(userId: 'user_1')),
      expect: () => [
        const AiVideoLoading(),
        const AiVideoError(message: 'Exception: Failed to load'),
      ],
    );

    blocTest<AiVideoBloc, AiVideoState>(
      'emits [AiVideoLoading, AiVideoCreated, AiVideoLoaded] when video created',
      build: () {
        when(mockRepository.createVideo(any, any))
            .thenAnswer((_) async => mockVideo);
        when(mockRepository.getVideos(any))
            .thenAnswer((_) async => mockVideos);
        return AiVideoBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        AiVideoCreateRequested(
          request: mockRequest,
          userId: 'user_1',
        ),
      ),
      expect: () => [
        const AiVideoLoading(),
        AiVideoCreated(video: mockVideo),
        AiVideoLoaded(videos: mockVideos),
      ],
    );
  });
}

