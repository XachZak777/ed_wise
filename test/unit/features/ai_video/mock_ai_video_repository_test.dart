import 'package:flutter_test/flutter_test.dart';

import 'package:ed_wise/features/ai_video/models/ai_video.dart';
import 'package:ed_wise/features/ai_video/repositories/mock_ai_video_repository.dart';

void main() {
  group('MockAiVideoRepository', () {
    test('getVideos returns initial mock videos for matching user', () async {
      final repository = MockAiVideoRepository();

      final videos = await repository.getVideos('mock_uid_1');
      expect(videos, isNotEmpty);
      expect(videos.first.userId, 'mock_uid_1');
    });

    test('getVideos returns empty list for user with no videos', () async {
      final repository = MockAiVideoRepository();

      final videos = await repository.getVideos('unknown_user');
      expect(videos, isEmpty);
    });

    test('createVideo adds a new video and returns it', () async {
      final repository = MockAiVideoRepository();

      final request = VideoGenerationRequest(
        text: 'Some educational content',
        title: 'My first AI video',
        style: VideoStyle.presentation,
        language: 'en',
        includeSubtitles: true,
      );

      final created = await repository.createVideo(request, 'user_123');

      expect(created.id, isNotEmpty);
      expect(created.userId, 'user_123');
      expect(created.title, request.title);
      expect(created.originalText, request.text);
      expect(created.processedText, request.text);
      expect(created.status, VideoStatus.completed);
      expect(created.duration, greaterThan(0));
      expect(created.metadata['style'], request.style.name);
      expect(created.metadata['language'], request.language);
      expect(created.metadata['includeSubtitles'], request.includeSubtitles);

      final videos = await repository.getVideos('user_123');
      expect(videos.length, 1);
      expect(videos.first.id, created.id);
    });
  });
}


