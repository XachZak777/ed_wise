# EdWise - Educational Platform

EdWise is a comprehensive educational mobile application built with Flutter that combines study planning, AI-powered video generation, and community forums to enhance the learning experience.

## 🚀 Features

### Core Features ✅
- **Authentication System**
  - Email/password registration and login
  - Google Sign-In integration
  - Firebase Authentication integration
  - User profile management

- **Study Plans Module**
  - Create and manage study plans
  - Add subjects and tasks
  - Track progress with visual indicators
  - CRUD operations for study content

- **AI Video Generation**
  - Upload text content for video conversion
  - Multiple video styles (Educational, Presentation, Tutorial, Summary)
  - Real-time processing status
  - Video storage and playback

- **Community Forum**
  - Create and participate in discussions
  - Category-based organization
  - Upvote/downvote system
  - Real-time updates

- **User Profile**
  - Study statistics tracking
  - Profile customization
  - Settings management

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ed_wise
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication, Firestore, and Storage
   - Download configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Update `lib/firebase_options.dart` with your project credentials

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants and configuration
│   ├── services/           # Core services (Firebase, Router)
│   ├── theme/              # App theming and styling
│   └── utils/              # Utility functions
├── features/
│   ├── auth/               # Authentication feature
│   │   ├── models/
│   │   ├── providers/
│   │   └── screens/
│   ├── study_plans/        # Study planning feature
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── ai_video/           # AI video generation feature
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── forum/              # Community forum feature
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   └── profile/            # User profile feature
│       ├── models/
│       ├── providers/
│       └── screens/
├── shared/
│   ├── models/             # Shared data models
│   ├── services/           # Shared services
│   └── widgets/            # Reusable UI components
└── main.dart               # App entry point
```

## 🔧 Configuration

### Firebase Configuration

1. **Authentication**
   - Enable Email/Password authentication
   - Configure sign-in methods

2. **Firestore Database**
   - Set up security rules
   - Create collections: users, study_plans, forum_posts, ai_videos

3. **Cloud Storage**
   - Configure storage rules
   - Set up folders: profile_images, ai_videos, uploaded_texts

### Environment Variables

The app uses environment variables for sensitive configuration. Follow these steps:

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Update `.env` with your actual values:**
   - Firebase project credentials
   - API keys for external services
   - Any other sensitive configuration

3. **Never commit `.env` to version control** - it's already in `.gitignore`

The app will automatically load these variables at startup through the `EnvService`.

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 📦 Dependencies

Key dependencies used in this project:

- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `google_sign_in` - Google Sign-In integration
- `cloud_firestore` - NoSQL database
- `firebase_storage` - File storage
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `video_player` - Video playback
- `cached_network_image` - Image caching
- `flutter_local_notifications` - Local notifications

**EdWise** - Empowering education through technology 🎓