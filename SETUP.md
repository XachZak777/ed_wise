# EdWise Setup Guide

## 🚀 Quick Start

### 1. Prerequisites
- Flutter SDK (3.9.2 or higher)
- Android Studio / VS Code
- Firebase account

### 2. Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Create a project"
   - Name it "edwise-app" (or your preferred name)

2. **Enable Services**
   - **Authentication**: Enable Email/Password and Google sign-in
   - **Firestore Database**: Create in production mode
   - **Storage**: Create with default rules

3. **Download Configuration Files**
   - **Android**: Download `google-services.json` and place in `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` and place in `ios/Runner/`

4. **Configure Environment Variables**
   - Copy `.env.example` to `.env`: `cp .env.example .env`
   - Open `.env` and replace placeholder values with your actual Firebase project credentials:
     ```
     FIREBASE_PROJECT_ID=your-actual-project-id
     FIREBASE_WEB_API_KEY=your-actual-web-api-key
     FIREBASE_WEB_APP_ID=your-actual-web-app-id
     FIREBASE_WEB_MESSAGING_SENDER_ID=your-actual-sender-id
     FIREBASE_WEB_AUTH_DOMAIN=your-actual-project-id.firebaseapp.com
     FIREBASE_WEB_STORAGE_BUCKET=your-actual-project-id.appspot.com
     # ... and so on for other platforms
     
     # Google Sign-In Configuration
     GOOGLE_SIGN_IN_WEB_CLIENT_ID=your-google-web-client-id
     GOOGLE_SIGN_IN_IOS_CLIENT_ID=your-google-ios-client-id
     GOOGLE_SIGN_IN_ANDROID_CLIENT_ID=your-google-android-client-id
     ```

### 5. Google Sign-In Setup

1. **Enable Google Sign-In in Firebase Console**
   - Go to Authentication > Sign-in method
   - Enable Google provider
   - Add your project's support email

2. **Get Google Client IDs**
   - **Web**: Use the Web client ID from Firebase Console > Project Settings > General
   - **Android**: Use the Android client ID from Firebase Console > Project Settings > General
   - **iOS**: Use the iOS client ID from Firebase Console > Project Settings > General

3. **Update .env file** with your Google client IDs:
   ```
   GOOGLE_SIGN_IN_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
   GOOGLE_SIGN_IN_ANDROID_CLIENT_ID=your-android-client-id.apps.googleusercontent.com
   GOOGLE_SIGN_IN_IOS_CLIENT_ID=your-ios-client-id.apps.googleusercontent.com
   ```

### 3. Install Dependencies
```bash
cd ed_wise
flutter pub get
```

### 4. Run the App
```bash
flutter run
```

## 🔧 Configuration

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Study plans - users can read/write their own
    match /study_plans/{planId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Forum posts - authenticated users can read, authors can write
    match /forum_posts/{postId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.userId == request.auth.uid);
    }
    
    // AI videos - users can read/write their own
    match /ai_videos/{videoId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📱 Features Overview

### ✅ Implemented Features
- **Authentication**: Email/password registration and login
- **Study Plans**: Create, manage, and track study progress
- **AI Video Generation**: Convert text to educational videos
- **Community Forum**: Post discussions and interact with community
- **User Profile**: Manage profile and view statistics

### 🚧 Coming Soon
- Google Sign-In integration
- Push notifications
- Offline mode
- Advanced AI features

## 🐛 Troubleshooting

### Common Issues

1. **Firebase connection errors**
   - Verify your `firebase_options.dart` has correct credentials
   - Check that configuration files are in the right locations

2. **Build errors**
   - Run `flutter clean && flutter pub get`
   - Ensure all dependencies are properly installed

3. **Authentication issues**
   - Verify Firebase Authentication is enabled
   - Check that Email/Password sign-in is enabled

### Getting Help
- Check the [Flutter documentation](https://docs.flutter.dev/)
- Review [Firebase documentation](https://firebase.google.com/docs)
- Create an issue in the repository

## 🎯 Next Steps

1. Set up your Firebase project
2. Configure the app with your credentials
3. Run the app and test the features
4. Customize the UI and add your own branding
5. Deploy to app stores when ready

---

**Happy coding! 🚀**
