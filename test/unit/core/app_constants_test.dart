import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ed_wise/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('static app and collection constants have expected values', () {
      expect(AppConstants.appName, 'EdWise');
      expect(AppConstants.appVersion, '1.0.0');

      expect(AppConstants.usersCollection, 'users');
      expect(AppConstants.studyPlansCollection, 'study_plans');
      expect(AppConstants.subjectsCollection, 'subjects');
      expect(AppConstants.tasksCollection, 'tasks');
      expect(AppConstants.forumPostsCollection, 'forum_posts');
      expect(AppConstants.forumCommentsCollection, 'forum_comments');
      expect(AppConstants.aiVideosCollection, 'ai_videos');

      expect(AppConstants.profileImagesPath, 'profile_images');
      expect(AppConstants.aiVideosPath, 'ai_videos');
      expect(AppConstants.uploadedTextsPath, 'uploaded_texts');

      expect(AppConstants.maxSubjectsPerPlan, 10);
      expect(AppConstants.maxTasksPerSubject, 50);
      expect(
        AppConstants.studyReminderInterval,
        const Duration(hours: 24),
      );

      expect(AppConstants.maxPostsPerPage, 20);
      expect(AppConstants.maxCommentsPerPost, 100);

      expect(AppConstants.maxTextLength, 10000);
      expect(
        AppConstants.maxVideoDuration,
        const Duration(minutes: 10),
      );

      expect(AppConstants.defaultPadding, 16.0);
      expect(AppConstants.smallPadding, 8.0);
      expect(AppConstants.largePadding, 24.0);
      expect(AppConstants.borderRadius, 12.0);
      expect(AppConstants.cardElevation, 2.0);
    });

    test('API URL getters delegate to environment configuration', () async {
      dotenv.loadFromString('''
OPENAI_API_URL=https://api.custom-openai.test/v1
GOOGLE_TTS_API_URL=https://tts.custom.test/v1
''');

      expect(
        AppConstants.openAiApiUrl,
        'https://api.custom-openai.test/v1',
      );
      expect(
        AppConstants.textToSpeechApiUrl,
        'https://tts.custom.test/v1',
      );
    });
  });
}




