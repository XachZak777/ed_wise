import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../../features/ai_video/models/ai_video.dart';
import '../../features/ai_video/repositories/mock_ai_video_repository.dart';

abstract class AiVideoRepository {
  static AiVideoRepository get instance {
    if (AppConfig.useMockData) {
      return MockAiVideoRepository();
    }
    return FirebaseAiVideoRepository();
  }

  Future<List<AiVideo>> getVideos(String userId);
  Future<AiVideo> createVideo(VideoGenerationRequest request, String userId);
}

class FirebaseAiVideoRepository implements AiVideoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<AiVideo>> getVideos(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.aiVideosCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AiVideo.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to load videos: $e');
    }
  }

  @override
  Future<AiVideo> createVideo(VideoGenerationRequest request, String userId) async {
    try {
      final video = AiVideo(
        id: '',
        userId: userId,
        title: request.title,
        originalText: request.text,
        processedText: request.text,
        videoUrl: '',
        audioUrl: '',
        status: VideoStatus.pending,
        createdAt: DateTime.now(),
        duration: 0,
        thumbnailUrl: '',
        metadata: {
          'style': request.style.name,
          'language': request.language,
          'includeSubtitles': request.includeSubtitles,
        },
      );

      final docRef = await _firestore
          .collection(AppConstants.aiVideosCollection)
          .add(video.toMap());

      return video.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create video: $e');
    }
  }
}

