import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ed_wise/core/services/env_service.dart';

void main() {
  group('EnvService', () {
    setUp(() {
      // Use loadFromString so we don't rely on a real .env file on disk
      dotenv.loadFromString(
        fileInput: '''
FIREBASE_PROJECT_ID=test-project
FIREBASE_WEB_API_KEY=test-web-api-key
FIREBASE_WEB_APP_ID=test-web-app-id
FIREBASE_WEB_MESSAGING_SENDER_ID=1234567890
FIREBASE_WEB_AUTH_DOMAIN=test-auth-domain
FIREBASE_WEB_STORAGE_BUCKET=test-storage-bucket
FIREBASE_ANDROID_API_KEY=test-android-api-key
FIREBASE_ANDROID_APP_ID=test-android-app-id
FIREBASE_ANDROID_MESSAGING_SENDER_ID=0987654321
FIREBASE_ANDROID_STORAGE_BUCKET=test-android-storage
FIREBASE_IOS_API_KEY=test-ios-api-key
FIREBASE_IOS_APP_ID=test-ios-app-id
FIREBASE_IOS_MESSAGING_SENDER_ID=111222333
FIREBASE_IOS_STORAGE_BUCKET=test-ios-storage
FIREBASE_IOS_BUNDLE_ID=com.example.test
FIREBASE_MACOS_API_KEY=test-macos-api-key
FIREBASE_MACOS_APP_ID=test-macos-app-id
FIREBASE_MACOS_MESSAGING_SENDER_ID=444555666
FIREBASE_MACOS_STORAGE_BUCKET=test-macos-storage
FIREBASE_MACOS_BUNDLE_ID=com.example.test.macos
OPENAI_API_URL=https://api.test-openai.com/v1
GOOGLE_TTS_API_URL=https://tts.test.example.com
OPENAI_API_KEY=test-openai-key
GOOGLE_TTS_API_KEY=test-google-tts-key
GOOGLE_SIGN_IN_WEB_CLIENT_ID=test-web-client-id
GOOGLE_SIGN_IN_IOS_CLIENT_ID=test-ios-client-id
GOOGLE_SIGN_IN_ANDROID_CLIENT_ID=test-android-client-id
''',
      );
    });

    test('firebase configuration getters read from env', () {
      expect(EnvService.firebaseProjectId, 'test-project');

      expect(EnvService.firebaseWebApiKey, 'test-web-api-key');
      expect(EnvService.firebaseWebAppId, 'test-web-app-id');
      expect(EnvService.firebaseWebMessagingSenderId, '1234567890');
      expect(EnvService.firebaseWebAuthDomain, 'test-auth-domain');
      expect(EnvService.firebaseWebStorageBucket, 'test-storage-bucket');

      expect(EnvService.firebaseAndroidApiKey, 'test-android-api-key');
      expect(EnvService.firebaseAndroidAppId, 'test-android-app-id');
      expect(EnvService.firebaseAndroidMessagingSenderId, '0987654321');
      expect(EnvService.firebaseAndroidStorageBucket, 'test-android-storage');

      expect(EnvService.firebaseIosApiKey, 'test-ios-api-key');
      expect(EnvService.firebaseIosAppId, 'test-ios-app-id');
      expect(EnvService.firebaseIosMessagingSenderId, '111222333');
      expect(EnvService.firebaseIosStorageBucket, 'test-ios-storage');
      expect(EnvService.firebaseIosBundleId, 'com.example.test');

      expect(EnvService.firebaseMacosApiKey, 'test-macos-api-key');
      expect(EnvService.firebaseMacosAppId, 'test-macos-app-id');
      expect(EnvService.firebaseMacosMessagingSenderId, '444555666');
      expect(EnvService.firebaseMacosStorageBucket, 'test-macos-storage');
      expect(
        EnvService.firebaseMacosBundleId,
        'com.example.test.macos',
      );
    });

    test('external API configuration getters read from env', () {
      expect(
        EnvService.openAiApiUrl,
        'https://api.test-openai.com/v1',
      );
      expect(
        EnvService.googleTtsApiUrl,
        'https://tts.test.example.com',
      );
      expect(EnvService.openAiApiKey, 'test-openai-key');
      expect(EnvService.googleTtsApiKey, 'test-google-tts-key');
    });

    test('google sign-in configuration getters read from env', () {
      expect(
        EnvService.googleSignInWebClientId,
        'test-web-client-id',
      );
      expect(
        EnvService.googleSignInIosClientId,
        'test-ios-client-id',
      );
      expect(
        EnvService.googleSignInAndroidClientId,
        'test-android-client-id',
      );
    });

    test('defaults are used when env vars are missing', () async {
      // Reset env to empty to verify default fallbacks
      dotenv.loadFromString(fileInput: '');

      expect(EnvService.firebaseProjectId, 'edwise-app');
      expect(EnvService.firebaseWebAuthDomain, 'edwise-app.firebaseapp.com');
      expect(
        EnvService.firebaseWebStorageBucket,
        'edwise-app.appspot.com',
      );
      expect(
        EnvService.firebaseAndroidStorageBucket,
        'edwise-app.appspot.com',
      );
      expect(
        EnvService.firebaseIosStorageBucket,
        'edwise-app.appspot.com',
      );
      expect(
        EnvService.firebaseMacosStorageBucket,
        'edwise-app.appspot.com',
      );
      expect(EnvService.openAiApiUrl, 'https://api.openai.com/v1');
      expect(
        EnvService.googleTtsApiUrl,
        'https://texttospeech.googleapis.com/v1',
      );
      expect(EnvService.googleSignInWebClientId, '');
      expect(EnvService.googleSignInIosClientId, '');
      expect(EnvService.googleSignInAndroidClientId, '');
    });
  });
}




