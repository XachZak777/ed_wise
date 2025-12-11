# EdWise - Educational Platform

EdWise is a comprehensive educational mobile application built with Flutter that combines study planning, AI-powered video generation, community forums, and AI learning assistance to enhance the learning experience.

## 🏗️ Architecture

This project uses the **BLoC (Business Logic Component) pattern** for state management, providing:
- Predictable state management
- Easy testing
- Separation of concerns
- Scalable architecture

### State Management: BLoC Pattern
- **Events**: User actions (load, create, update, delete)
- **States**: UI states (loading, loaded, error)
- **BLoCs**: Business logic handling
- **Repositories**: Data layer abstraction (Firebase/Mock)

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
  - Mock data for presentation

- **AI Video Generation**
  - Upload text content for video conversion
  - Multiple video styles (Educational, Presentation, Tutorial, Summary)
  - Real-time processing status
  - Video storage and playback

- **Community Forum**
  - Create and participate in discussions
  - Category-based organization
  - Upvote/downvote system
  - Comments system
  - Edit/Delete posts
  - Mock data for presentation

- **AI Learning Assistant**
  - Chat interface
  - Intelligent responses
  - Learning guidance
  - Course recommendations

- **User Profile**
  - Study statistics tracking
  - Profile customization
  - Edit profile functionality
  - Settings management

- **Certificates**
  - View earned certificates
  - Download certificates as PDF
  - Unique certificate IDs
  - Completion tracking
  - Mock certificates for demo

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup (optional - mock data available)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd final_project_edwise
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Configuration (Optional)**
   ```bash
   # Copy environment template
   cp .env.example .env
   
   # Update .env with your Firebase credentials (if using real Firebase)
   ```

4. **Firebase Setup (Optional - for production)**
   - Create a Firebase project at https://console.firebase.google.com
   - Enable Authentication (Email/Password, Google)
   - Create Firestore database
   - Enable Storage
   - Download configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`

5. **Run the app**
   ```bash
   # Web (Chrome)
   flutter run -d chrome
   
   # iOS Simulator
   flutter run -d ios
   
   # Android Emulator
   flutter run -d android
   ```

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/              # App configuration (mock data flags)
│   ├── constants/           # App constants
│   ├── repositories/        # Repository pattern (Firebase/Mock)
│   ├── services/            # Core services (Firebase, Router, Env)
│   └── theme/               # App theming
├── features/
│   ├── auth/                # Authentication (BLoC)
│   │   ├── bloc/
│   │   ├── repositories/
│   │   └── screens/
│   ├── study_plans/         # Study planning (BLoC)
│   │   ├── bloc/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── screens/
│   │   └── widgets/
│   ├── ai_video/            # AI video generation (BLoC)
│   │   ├── bloc/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── screens/
│   │   └── widgets/
│   ├── forum/               # Community forum (BLoC)
│   │   ├── bloc/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── screens/
│   │   └── widgets/
│   ├── ai_agent/            # AI assistant (BLoC)
│   │   ├── bloc/
│   │   ├── models/
│   │   └── screens/
│   └── profile/             # User profile (BLoC)
│       ├── bloc/
│       ├── models/
│       ├── repositories/
│       └── screens/
└── shared/
    └── widgets/             # Reusable UI components
```

## 🔧 Configuration

### Mock Data Configuration

The app supports mock data for demos and presentations. Configure in `lib/core/config/app_config.dart`:

```dart
static const bool useMockStudyPlans = true;  // Use mock study plans
static const bool useMockForum = true;        // Use mock forum posts
static const bool useMockAuth = false;        // Always use real Firebase Auth
```

### Firebase Configuration (Production)

1. **Authentication**
   - Enable Email/Password authentication
   - Configure Google Sign-In

2. **Firestore Database**
   - Set up security rules
   - Create collections: users, study_plans, forum_posts, forum_comments, ai_videos, certificates

3. **Cloud Storage**
   - Configure storage rules
   - Set up folders: profile_images, ai_videos, certificates

## 🧪 Testing

See [TESTING.md](TESTING.md) for comprehensive testing documentation.

### Quick Start

```bash
# Run all tests
flutter test

# Run with coverage and generate report
./test_coverage.sh

# Or manually:
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run integration tests
flutter test integration_test/
```

**Test Coverage Target**: 90%+

### Test Structure
- **Unit Tests**: BLoC logic, repositories, models
- **Integration Tests**: Complete user flows
- **Widget Tests**: UI component testing

All tests are located in `test/` directory with proper organization.

## 📦 Key Dependencies

### State Management
- `flutter_bloc: ^8.1.6` - BLoC pattern
- `equatable: ^2.0.5` - Value equality

### Firebase
- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - NoSQL database
- `firebase_storage` - File storage
- `google_sign_in` - Google Sign-In

### UI & Navigation
- `go_router: ^14.2.7` - Navigation
- `cached_network_image` - Image caching
- `shimmer` - Loading placeholders

### Utilities
- `shared_preferences` - Local storage
- `path_provider` - File system paths
- `open_filex` - File opening
- `permission_handler` - Permissions

## 📚 Documentation

- **PRESENTATION.md** - Presentation guide and demo flow
- **RUNNING.md** - Development and running instructions
- **SETUP.md** - Detailed setup guide
- **COMPREHENSIVE_STATUS.md** - Current implementation status

## 🎯 Key Features Highlight

### BLoC Architecture
- Clean separation of business logic and UI
- Easy to test and maintain
- Predictable state management

### Repository Pattern
- Easy switching between mock and Firebase data
- Perfect for demos and testing
- Scalable architecture

### Mock Data System
- Toggle between mock and real data
- No backend required for demos
- Interactive presentation data

## 🚀 Demo Mode

The app includes mock data for:
- Study Plans (2 demo plans with progress)
- Forum Posts (4 demo posts across categories)
- Certificates (6 demo certificates)
- Comments (demo comments on posts)

**Authentication**: Always uses real Firebase (no mock)

## 📝 Development Notes

- All state management uses BLoC pattern
- Repository pattern for data layer
- Mock data toggle in `AppConfig`
- Professional UI/UX with Material Design 3
- Dark mode support
- Responsive layouts

## 🤝 Contributing

1. Follow BLoC architecture pattern
2. Use repository pattern for data access
3. Write tests for new features
4. Maintain 90%+ test coverage
5. Update documentation

## 📄 License

This project is private and not licensed for public use.

**EdWise** - Empowering education through technology 🎓
