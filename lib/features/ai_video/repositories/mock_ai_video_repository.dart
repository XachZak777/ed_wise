import '../../../core/config/app_config.dart';
import '../../../core/repositories/ai_video_repository.dart';
import '../models/ai_video.dart';

class MockAiVideoRepository implements AiVideoRepository {
  final List<AiVideo> _mockVideos = [];

  MockAiVideoRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _mockVideos.addAll([
      AiVideo(
        id: 'video_1',
        userId: 'mock_uid_1',
        title: 'Introduction to Flutter',
        originalText: 'Flutter is a UI toolkit for building beautiful applications.',
        processedText: 'Flutter is a UI toolkit for building beautiful applications.',
        videoUrl: 'https://example.com/videos/video_1.mp4',
        audioUrl: 'https://example.com/audio/video_1.mp3',
        status: VideoStatus.completed,
        createdAt: now.subtract(const Duration(days: 5)),
        completedAt: now.subtract(const Duration(days: 4)),
        duration: 300,
        thumbnailUrl: 'https://example.com/thumbnails/video_1.jpg',
        metadata: {
          'style': 'educational',
          'language': 'en',
        },
      ),
    ]);
  }

  @override
  Future<List<AiVideo>> getVideos(String userId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    return _mockVideos.where((video) => video.userId == userId).toList();
  }

  @override
  Future<AiVideo> createVideo(VideoGenerationRequest request, String userId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay + 1000));
    final now = DateTime.now();
    final video = AiVideo(
      id: 'video_${_mockVideos.length + 1}',
      userId: userId,
      title: request.title,
      originalText: request.text,
      processedText: request.text,
      videoUrl: 'https://example.com/videos/video_${_mockVideos.length + 1}.mp4',
      audioUrl: 'https://example.com/audio/video_${_mockVideos.length + 1}.mp3',
      status: VideoStatus.completed,
      createdAt: now,
      completedAt: now.add(const Duration(seconds: 2)),
      duration: (request.text.length / 10).round(),
      thumbnailUrl: 'https://example.com/thumbnails/video_${_mockVideos.length + 1}.jpg',
      metadata: {
        'style': request.style.name,
        'language': request.language,
        'includeSubtitles': request.includeSubtitles,
      },
    );
    _mockVideos.add(video);
    return video;
  }
}

