import 'package:cloud_firestore/cloud_firestore.dart';

class AiVideo {
  final String id;
  final String userId;
  final String title;
  final String originalText;
  final String processedText;
  final String videoUrl;
  final String audioUrl;
  final VideoStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int duration; // in seconds
  final String thumbnailUrl;
  final Map<String, dynamic> metadata;

  AiVideo({
    required this.id,
    required this.userId,
    required this.title,
    required this.originalText,
    required this.processedText,
    required this.videoUrl,
    required this.audioUrl,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.duration,
    required this.thumbnailUrl,
    required this.metadata,
  });

  factory AiVideo.fromMap(Map<String, dynamic> map, String id) {
    return AiVideo(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      originalText: map['originalText'] ?? '',
      processedText: map['processedText'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      status: VideoStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => VideoStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      duration: map['duration'] ?? 0,
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'originalText': originalText,
      'processedText': processedText,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'duration': duration,
      'thumbnailUrl': thumbnailUrl,
      'metadata': metadata,
    };
  }

  AiVideo copyWith({
    String? id,
    String? userId,
    String? title,
    String? originalText,
    String? processedText,
    String? videoUrl,
    String? audioUrl,
    VideoStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    int? duration,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
  }) {
    return AiVideo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      originalText: originalText ?? this.originalText,
      processedText: processedText ?? this.processedText,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum VideoStatus {
  pending,
  processing,
  completed,
  failed,
}

class VideoGenerationRequest {
  final String text;
  final String title;
  final VideoStyle style;
  final String language;
  final bool includeSubtitles;

  VideoGenerationRequest({
    required this.text,
    required this.title,
    this.style = VideoStyle.educational,
    this.language = 'en',
    this.includeSubtitles = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'title': title,
      'style': style.name,
      'language': language,
      'includeSubtitles': includeSubtitles,
    };
  }
}

enum VideoStyle {
  educational,
  presentation,
  tutorial,
  summary,
}
