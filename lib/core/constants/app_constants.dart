import '../services/env_service.dart';

class AppConstants {
  // App Info
  static const String appName = 'EdWise';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static String get openAiApiUrl => EnvService.openAiApiUrl;
  static String get textToSpeechApiUrl => EnvService.googleTtsApiUrl;
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String studyPlansCollection = 'study_plans';
  static const String subjectsCollection = 'subjects';
  static const String tasksCollection = 'tasks';
  static const String forumPostsCollection = 'forum_posts';
  static const String forumCommentsCollection = 'forum_comments';
  static const String aiVideosCollection = 'ai_videos';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String aiVideosPath = 'ai_videos';
  static const String uploadedTextsPath = 'uploaded_texts';
  
  // Study Plan Constants
  static const int maxSubjectsPerPlan = 10;
  static const int maxTasksPerSubject = 50;
  static const Duration studyReminderInterval = Duration(hours: 24);
  
  // Forum Constants
  static const int maxPostsPerPage = 20;
  static const int maxCommentsPerPost = 100;
  
  // AI Video Constants
  static const int maxTextLength = 10000;
  static const Duration maxVideoDuration = Duration(minutes: 10);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
}
