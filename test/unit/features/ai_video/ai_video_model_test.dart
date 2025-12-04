import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ed_wise/features/ai_video/models/ai_video.dart';

void main() {
  group('AiVideo model', () {
    test('fromMap and toMap are inverse operations', () {
      final createdAt = DateTime.utc(2024, 1, 2, 3, 4, 5);
      final completedAt = DateTime.utc(2024, 1, 2, 4, 5, 6);

      final map = {
        'userId': 'user_1',
        'title': 'Test title',
        'originalText': 'Original text',
        'processedText': 'Processed text',
        'videoUrl': 'https://example.com/video.mp4',
        'audioUrl': 'https://example.com/audio.mp3',
        'status': 'completed',
        'createdAt': Timestamp.fromDate(createdAt),
        'completedAt': Timestamp.fromDate(completedAt),
        'duration': 120,
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'metadata': {'key': 'value'},
      };

      final video = AiVideo.fromMap(map, 'video_1');
      expect(video.id, 'video_1');
      expect(video.userId, 'user_1');
      expect(video.title, 'Test title');
      expect(video.originalText, 'Original text');
      expect(video.processedText, 'Processed text');
      expect(video.videoUrl, 'https://example.com/video.mp4');
      expect(video.audioUrl, 'https://example.com/audio.mp3');
      expect(video.status, VideoStatus.completed);
      expect(video.createdAt, createdAt);
      expect(video.completedAt, completedAt);
      expect(video.duration, 120);
      expect(video.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(video.metadata, {'key': 'value'});

      final toMap = video.toMap();
      expect(toMap['userId'], map['userId']);
      expect(toMap['title'], map['title']);
      expect(toMap['originalText'], map['originalText']);
      expect(toMap['processedText'], map['processedText']);
      expect(toMap['videoUrl'], map['videoUrl']);
      expect(toMap['audioUrl'], map['audioUrl']);
      expect(toMap['status'], 'completed');
      expect(toMap['createdAt'], Timestamp.fromDate(createdAt));
      expect(toMap['completedAt'], Timestamp.fromDate(completedAt));
      expect(toMap['duration'], 120);
      expect(toMap['thumbnailUrl'], map['thumbnailUrl']);
      expect(toMap['metadata'], map['metadata']);
    });

    test('fromMap applies defaults and fallback status', () {
      final createdAt = DateTime.utc(2024, 1, 1);

      final map = {
        'createdAt': Timestamp.fromDate(createdAt),
        // No completedAt, status is unknown
        'status': 'unknown-status',
      };

      final video = AiVideo.fromMap(map, 'id');
      expect(video.id, 'id');
      expect(video.userId, '');
      expect(video.title, '');
      expect(video.originalText, '');
      expect(video.processedText, '');
      expect(video.videoUrl, '');
      expect(video.audioUrl, '');
      expect(video.status, VideoStatus.pending);
      expect(video.createdAt, createdAt);
      expect(video.completedAt, isNull);
      expect(video.duration, 0);
      expect(video.thumbnailUrl, '');
      expect(video.metadata, isEmpty);
    });

    test('copyWith returns updated copy while preserving other fields', () {
      final video = AiVideo(
        id: 'id',
        userId: 'user',
        title: 'title',
        originalText: 'original',
        processedText: 'processed',
        videoUrl: 'video-url',
        audioUrl: 'audio-url',
        status: VideoStatus.pending,
        createdAt: DateTime.utc(2024, 1, 1),
        completedAt: null,
        duration: 10,
        thumbnailUrl: 'thumb',
        metadata: const {'a': 1},
      );

      final updated = video.copyWith(
        title: 'new title',
        status: VideoStatus.completed,
        duration: 20,
      );

      expect(updated.id, video.id);
      expect(updated.userId, video.userId);
      expect(updated.title, 'new title');
      expect(updated.status, VideoStatus.completed);
      expect(updated.duration, 20);
      expect(updated.originalText, video.originalText);
      expect(updated.metadata, video.metadata);
    });
  });

  group('VideoGenerationRequest', () {
    test('toMap serializes all fields correctly', () {
      final request = VideoGenerationRequest(
        text: 'content',
        title: 'Title',
        style: VideoStyle.tutorial,
        language: 'fr',
        includeSubtitles: false,
      );

      final map = request.toMap();
      expect(map['text'], 'content');
      expect(map['title'], 'Title');
      expect(map['style'], 'tutorial');
      expect(map['language'], 'fr');
      expect(map['includeSubtitles'], isFalse);
    });

    test('defaults are applied when optional parameters are omitted', () {
      final request = VideoGenerationRequest(
        text: 'content',
        title: 'Title',
      );

      final map = request.toMap();
      expect(map['style'], VideoStyle.educational.name);
      expect(map['language'], 'en');
      expect(map['includeSubtitles'], isTrue);
    });
  });
}



