import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  // Firebase Configuration
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? 'edwise-app';
  
  // Web Configuration
  static String get firebaseWebApiKey => dotenv.env['FIREBASE_WEB_API_KEY'] ?? 'your-web-api-key';
  static String get firebaseWebAppId => dotenv.env['FIREBASE_WEB_APP_ID'] ?? 'your-web-app-id';
  static String get firebaseWebMessagingSenderId => dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID'] ?? 'your-sender-id';
  static String get firebaseWebAuthDomain => dotenv.env['FIREBASE_WEB_AUTH_DOMAIN'] ?? 'edwise-app.firebaseapp.com';
  static String get firebaseWebStorageBucket => dotenv.env['FIREBASE_WEB_STORAGE_BUCKET'] ?? 'edwise-app.appspot.com';

  // Android Configuration
  static String get firebaseAndroidApiKey => dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? 'your-android-api-key';
  static String get firebaseAndroidAppId => dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? 'your-android-app-id';
  static String get firebaseAndroidMessagingSenderId => dotenv.env['FIREBASE_ANDROID_MESSAGING_SENDER_ID'] ?? 'your-sender-id';
  static String get firebaseAndroidStorageBucket => dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET'] ?? 'edwise-app.appspot.com';

  // iOS Configuration
  static String get firebaseIosApiKey => dotenv.env['FIREBASE_IOS_API_KEY'] ?? 'your-ios-api-key';
  static String get firebaseIosAppId => dotenv.env['FIREBASE_IOS_APP_ID'] ?? 'your-ios-app-id';
  static String get firebaseIosMessagingSenderId => dotenv.env['FIREBASE_IOS_MESSAGING_SENDER_ID'] ?? 'your-sender-id';
  static String get firebaseIosStorageBucket => dotenv.env['FIREBASE_IOS_STORAGE_BUCKET'] ?? 'edwise-app.appspot.com';
  static String get firebaseIosBundleId => dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? 'com.edwise.app.edWise';

  // macOS Configuration
  static String get firebaseMacosApiKey => dotenv.env['FIREBASE_MACOS_API_KEY'] ?? 'your-macos-api-key';
  static String get firebaseMacosAppId => dotenv.env['FIREBASE_MACOS_APP_ID'] ?? 'your-macos-app-id';
  static String get firebaseMacosMessagingSenderId => dotenv.env['FIREBASE_MACOS_MESSAGING_SENDER_ID'] ?? 'your-sender-id';
  static String get firebaseMacosStorageBucket => dotenv.env['FIREBASE_MACOS_STORAGE_BUCKET'] ?? 'edwise-app.appspot.com';
  static String get firebaseMacosBundleId => dotenv.env['FIREBASE_MACOS_BUNDLE_ID'] ?? 'com.edwise.app.edWise';

  // External API Configuration
  static String get openAiApiUrl => dotenv.env['OPENAI_API_URL'] ?? 'https://api.openai.com/v1';
  static String get googleTtsApiUrl => dotenv.env['GOOGLE_TTS_API_URL'] ?? 'https://texttospeech.googleapis.com/v1';
  
  // External API Keys (optional)
  static String? get openAiApiKey => dotenv.env['OPENAI_API_KEY'];
  static String? get googleTtsApiKey => dotenv.env['GOOGLE_TTS_API_KEY'];

  // Google Sign-In Configuration
  static String get googleSignInWebClientId => dotenv.env['GOOGLE_SIGN_IN_WEB_CLIENT_ID'] ?? '';
  static String get googleSignInIosClientId => dotenv.env['GOOGLE_SIGN_IN_IOS_CLIENT_ID'] ?? '';
  static String get googleSignInAndroidClientId => dotenv.env['GOOGLE_SIGN_IN_ANDROID_CLIENT_ID'] ?? '';
}
