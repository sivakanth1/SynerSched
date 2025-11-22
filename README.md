# 📚 SynerSched

> **Smart Academic Scheduling & Collaboration Platform for University Students**

SynerSched is a comprehensive Flutter mobile application designed to revolutionize how university students manage their academic schedules, tasks, and collaborations. With an intelligent scheduling algorithm, real-time collaboration features, and intuitive task management, SynerSched helps students stay organized and productive throughout their academic journey.

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Private-red.svg)]()

---

## ✨ Features

### 🎯 Smart Scheduling
- **Intelligent Time Allocation**: Automatically allocates tasks into your weekly schedule based on deadlines and preferences
- **10-Minute Granularity**: Precise time slot management for detailed scheduling
- **Preference-Based Scheduling**: Customize schedules based on preferred study times (morning, afternoon, evening)
- **Workload Management**: Adjust schedule intensity (light, medium, intense)
- **Automatic Semester Detection**: Automatically detects new semesters and prompts for schedule updates

### ✅ Task Management
- **Encrypted Task Storage**: Task titles are encrypted using AES encryption for privacy
- **Deadline Tracking**: Visual countdown and sorting by due dates
- **Smart Notifications**: Automated reminders at 1 hour, 30 minutes, and 15 minutes before deadlines
- **Quick Task Creation**: Floating action button for rapid task entry
- **Task Completion Tracking**: Mark tasks as complete and track your progress

### 👥 Collaboration Features
- **Real-Time Chat**: Powered by Stream Chat for instant messaging
- **Collaboration Boards**: Create or join study groups and project teams
- **Search & Filter**: Find collaborations by department, skills, and tags
- **Member Management**: Track collaboration members and participation

### 🌍 Localization
- **Multi-Language Support**: Full support for English and Spanish
- **Dynamic Language Switching**: Change language on-the-fly without restarting
- **154+ Translated Strings**: Complete UI translation coverage

### 🔐 Security & Privacy
- **AES Encryption**: User-specific encryption for sensitive data
- **Firebase Authentication**: Secure email/password authentication
- **User-Scoped Data**: All data isolated per user for privacy

### 📱 User Experience
- **Material 3 Design**: Modern and intuitive UI following Material Design 3 guidelines
- **Offline Support**: Firestore offline persistence with unlimited cache
- **Portrait-Lock**: Optimized for mobile portrait orientation
- **Custom Navigation**: Smooth bottom navigation with state persistence

---

## 🛠️ Technology Stack

| Category | Technology | Purpose |
|----------|-----------|---------|
| **Framework** | Flutter 3.8.1+ | Cross-platform mobile development |
| **Language** | Dart ^3.8.1 | Programming language |
| **Backend** | Firebase | Authentication, database, cloud functions |
| **Database** | Cloud Firestore | NoSQL cloud database with offline support |
| **Chat** | Stream Chat 9.15.0 | Real-time messaging infrastructure |
| **Notifications** | flutter_local_notifications | Local push notifications |
| **Storage** | SharedPreferences | Local key-value storage |
| **Encryption** | encrypt package (AES) | Data encryption/decryption |
| **Timezone** | timezone package | Cross-timezone scheduling |

---

## 📁 Project Structure

```
lib/
├── features/              # Feature modules (screens & logic)
│   ├── auth/             # Login & signup
│   ├── home/             # Dashboard with deadlines & highlights
│   ├── schedule/         # Schedule builder & result viewer
│   ├── collab_match/     # Collaboration boards & chat
│   ├── profile/          # User profile management
│   ├── onboarding/       # Welcome & tutorial screens
│   ├── splash/           # Initial loading screen
│   ├── settings/         # App settings
│   └── notifications/    # Notification center
│
├── firebase/             # Firebase service layer
│   ├── auth_service.dart           # Authentication operations
│   ├── task_service.dart           # Task CRUD operations
│   ├── schedule_service.dart       # Schedule management
│   ├── smart_scheduler.dart        # Intelligent scheduling algorithm
│   ├── firestore_service.dart      # General Firestore operations
│   └── class_service.dart          # Class schedule operations
│
├── shared/               # Reusable components & utilities
│   ├── custom_app_bar.dart         # Reusable app bar
│   ├── custom_nav_bar.dart         # Bottom navigation
│   ├── custom_button.dart          # Styled buttons
│   ├── encryption_helper.dart      # AES encryption utilities
│   ├── notification_service.dart   # Notification management
│   ├── stream_helper.dart          # Stream Chat utilities
│   ├── theme.dart                  # App themes (light/dark)
│   └── utils.dart                  # Helper functions
│
├── localization/         # Internationalization
│   ├── app_localizations.dart      # Localization delegate
│   └── inherited_locale.dart       # Locale state management
│
├── routes/               # Navigation configuration
│   └── app_routes.dart             # Route definitions
│
└── main.dart             # Application entry point
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.8.1 or higher
- **Dart SDK**: 3.8.1 or higher
- **Android Studio** or **Xcode** (for iOS)
- **Firebase Project**: Set up a Firebase project with Authentication and Firestore
- **Stream Chat Account**: Get API key from [Stream](https://getstream.io/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/sivakanth1/SynerSched.git
   cd SynerSched
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Configure Stream Chat**
   - Create a `.env` file or update `main.dart` with your Stream API key
   - Replace the hardcoded API key in `main.dart:58`

5. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS (macOS only)
   flutter run -d ios
   ```

---

## 🏗️ Architecture

SynerSched follows a **feature-based architecture** with clear separation of concerns:

```
┌─────────────────────────────────────┐
│          UI Layer (Features)         │
│  (Screens, Widgets, User Interaction)│
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Service Layer (Firebase)       │
│  (Business Logic, Data Operations)   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Data Layer (Firestore/Local)    │
│   (Cloud Database, Local Storage)    │
└─────────────────────────────────────┘
```

### Key Design Patterns

- **Service Layer Pattern**: Abstraction for Firebase operations
- **Repository Pattern**: Data access abstraction
- **Provider/Inherited Widget**: State management for locale
- **Singleton Pattern**: Notification and encryption services

---

## 📊 Smart Scheduler Algorithm

The heart of SynerSched is its intelligent scheduling algorithm:

### Algorithm Overview

1. **Time Grid Generation**
   - Creates 10-minute time slots based on user preferences
   - Supports morning (8 AM-12 PM), afternoon (1-5 PM), evening (6-9 PM)
   - Adjusts density based on workload (light/medium/intense)

2. **Slot Marking**
   - Marks class times as occupied
   - Identifies break periods
   - Detects time conflicts

3. **Task Allocation**
   - Sorts tasks chronologically by deadline
   - Allocates tasks to free slots before their due dates
   - Assigns 1-hour blocks per task

### Example

```
Monday 9:00 AM - 10:00 AM: Data Structures (Class)
Monday 10:00 AM - 11:00 AM: Free
Monday 11:00 AM - 12:00 PM: Complete Assignment #3 (Task)
Monday 12:00 PM - 1:00 PM: Lunch Break
...
```

---

## 🔒 Security Considerations

### Current Implementation

- ✅ **AES Encryption**: Sensitive task data encrypted with user-specific keys
- ✅ **Firebase Authentication**: Secure user authentication
- ✅ **Data Isolation**: User-scoped Firestore collections
- ✅ **HTTPS**: All Firebase communication over secure connections

### Known Issues & Improvements Needed

⚠️ **Before deploying to production:**

1. **Fix Encryption IV**: Currently uses a fixed IV (security vulnerability)
2. **Environment Variables**: Move API keys from source code to `.env`
3. **Input Validation**: Add client-side validation for all forms
4. **Password Strength**: Enforce stronger password requirements

See the [codebase analysis report](./docs/codebase_analysis_report.md) for detailed security recommendations.

---

## 🧪 Testing

Currently, the project has minimal test coverage. To run existing tests:

```bash
flutter test
```

**Testing Roadmap:**
- [ ] Unit tests for services (target: 80% coverage)
- [ ] Widget tests for UI components
- [ ] Integration tests for full user flows
- [ ] End-to-end tests with Firebase emulator

---

## 📱 Screenshots

<!-- Add screenshots here when available -->

> **Note**: Screenshots coming soon! Add images to showcase:
> - Home dashboard
> - Schedule builder
> - Weekly schedule view
> - Collaboration boards
> - Task management

---

## 🗺️ Roadmap

### Phase 1: Security & Stability ✅
- [x] Core features implementation
- [x] Firebase integration
- [x] Smart scheduler algorithm
- [ ] Fix security vulnerabilities
- [ ] Add comprehensive tests

### Phase 2: Enhanced Features 🚧
- [ ] Dark mode implementation
- [ ] Social features (profile pictures, friend connections)
- [ ] Calendar sync (Google Calendar integration)
- [ ] Advanced notifications with custom sounds

### Phase 3: Advanced Scheduling 📋
- [ ] Recurring tasks
- [ ] Variable task durations
- [ ] Task priority system
- [ ] AI-powered deadline suggestions

### Phase 4: Cross-Platform 🌐
- [ ] Web version
- [ ] Desktop support (Windows, macOS, Linux)
- [ ] Tablet optimization

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/AmazingFeature`
3. **Commit your changes**: `git commit -m 'Add some AmazingFeature'`
4. **Push to the branch**: `git push origin feature/AmazingFeature`
5. **Open a Pull Request**

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting with `dart format`

---

## 📄 License

This project is private and not licensed for public use.

---

## 👨‍💻 Author

**Sivakanth**
- GitHub: [@sivakanth1](https://github.com/sivakanth1)

---

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Firebase** for backend infrastructure
- **Stream** for chat functionality
- **University Community** for feature feedback and testing

---

## 📞 Support

For support, please open an issue in the GitHub repository or contact the development team.

---

## 📚 Documentation

- [Codebase Analysis Report](./docs/codebase_analysis_report.md) - Comprehensive technical analysis
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Stream Chat Documentation](https://getstream.io/chat/docs/flutter/)

---

**Made with ❤️ for students, by students**
