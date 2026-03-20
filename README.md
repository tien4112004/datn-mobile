# AI Primary Mobile

An AI-powered educational mobile application built with Flutter. AI Primary helps educators generate learning content (presentations, mindmaps, images, questions), manage classes and students, track assignments and submissions, and monitor student performance — all from a single mobile app.

## Features

- **AI Content Generation** — Create presentations, mindmaps, images, and assessment questions using AI
- **Class Management** — Create and manage classes, enroll students, post announcements
- **Assignments & Grading** — Create assignments, track submissions, and grade with feedback
- **Student Analytics** — Monitor performance metrics and identify at-risk students
- **Question Bank** — Build and manage reusable question sets
- **Resource Library** — Organize presentations, mindmaps, and generated images
- **Push Notifications** — Real-time updates via Firebase Cloud Messaging
- **Coin System** — In-app credits for accessing premium AI features
- **Multi-language** — English and Vietnamese support
- **Dark/Light Theme** — Adaptive theming with Flex Color Scheme

## Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter 3.8+ / Dart 3.8+ |
| State Management | Riverpod 3 + Flutter Hooks |
| Navigation | AutoRoute 10 |
| HTTP Client | Dio + Retrofit (code-gen) |
| Local Storage | Hive CE, Shared Preferences, Flutter Secure Storage |
| Push Notifications | Firebase Cloud Messaging |
| UI Components | Shadcn UI, Flutter Quill, Syncfusion Calendar, FL Chart |
| i18n | Slang |
| Code Generation | build_runner, Freezed, JSON Serializable |
| Linting | Flutter Lints, Riverpod Lint, Custom Lint |
| Scaffolding | Mason (riverpod_simple_architecture) |

## Prerequisites

- **Flutter SDK** >= 3.8.0 — [Install](https://flutter.dev/docs/get-started/install)
- **Dart SDK** >= 3.8.0 (bundled with Flutter)
- **Android Studio** (Android, min SDK 26 / Android 8.0+) or **Xcode** (iOS, macOS only)
- **Git**

Recommended: **VS Code** with Flutter/Dart extensions, plus an Android Emulator or iOS Simulator.

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd datn_mobile
```

### 2. Setup

#### Option A: Using Makefile (Recommended)

```bash
make init
```

This will automatically:
- Copy config sample if needed
- Install Flutter dependencies
- Setup pre-commit hooks
- Run build_runner for code generation
- Run Slang for translations
- Analyze the project

#### Option B: Using init script

```bash
chmod +x init.sh
./init.sh
```

#### Option C: Step by Step

```bash
# 1. Copy config file
cp lib/core/config/config.dart.sample lib/core/config/config.dart

# 2. Install dependencies
flutter pub get

# 3. Setup pre-commit hooks
dart pub global activate flutter_pre_commit
flutter_pre_commit install

# 4. Generate code
dart run build_runner build --delete-conflicting-outputs

# 5. Generate translations
dart run slang
```

### 3. Run the App

```bash
# Debug mode
make run-dev

# Release mode
make run-prod

# Or directly with Flutter CLI
flutter run
flutter run -d <device_id>
flutter run --release
```

### 4. Testing

```bash
make test

# Or with coverage
flutter test --coverage
```

### 5. Code Quality

```bash
make analyze       # Static analysis
make format        # Format code
```

### 6. Build for Production

```bash
make build-apk     # Android APK
make build-ios     # iOS (macOS only)

# Or using Flutter CLI
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

## Makefile Commands

```
make help          Show all available commands
make init          Initialize project (run init.sh)
make clean         Clean build artifacts
make get           Get Flutter dependencies
make build-runner  Run build_runner for code generation
make slang         Run Slang for translations
make slang-clean   Remove Slang generated files
make analyze       Analyze code for issues
make format        Format code
make test          Run tests
make run-dev       Run app in debug mode
make run-prod      Run app in release mode
make build-apk     Build Android APK
make build-ios     Build iOS app
make hooks         Setup pre-commit hooks
make add pub=<pkg> Add a Flutter package
```

## Project Structure

```
lib/
├── app/                    # App-level configuration and Material App
├── core/                   # Core infrastructure
│   ├── config/             #   API configuration
│   ├── local_storage/      #   AppStorage (SharedPreferences)
│   ├── router/             #   AutoRoute navigation
│   ├── secure_storage/     #   Encrypted credential storage
│   ├── services/           #   Core services (notifications)
│   └── theme/              #   App theming
├── features/               # Feature modules
│   ├── auth/               #   Authentication (sign-in/up, OAuth)
│   ├── home/               #   Dashboard
│   ├── generate/           #   AI content generation
│   ├── projects/           #   Resource management
│   ├── classes/            #   Class management
│   ├── students/           #   Student management
│   ├── assignments/        #   Assignment/exam management
│   ├── submissions/        #   Submission tracking & grading
│   ├── posts/              #   Class announcements
│   ├── questions/          #   Question bank
│   ├── payment/            #   Payment & coin purchase
│   ├── coins/              #   Coin system
│   ├── notification/       #   Notifications
│   ├── profile/            #   User profile
│   ├── setting/            #   App settings
│   └── splash/             #   Splash screen
├── shared/                 # Shared code
│   ├── api_client/         #   Dio HTTP client & interceptors
│   ├── exception/          #   Exception handling
│   ├── extension/          #   Dart extensions
│   ├── helper/             #   Utility helpers
│   ├── models/             #   Shared data models
│   ├── pods/               #   Global Riverpod providers
│   ├── riverpod_ext/       #   Riverpod extensions
│   ├── services/           #   Shared services
│   ├── utils/              #   Utilities
│   └── widgets/            #   Reusable UI components
├── i18n/                   # Internationalization (en, vi)
├── const/                  # App constants
├── main.dart               # Entry point
├── bootstrap.dart          # App initialization
├── init.dart               # System initialization
└── splasher.dart           # Splash screen with setup
```

## Development Workflow

1. **Before starting**: Run `make init` or `make get && make build-runner`
2. **Before committing**: Pre-commit hooks run automatically via `flutter_pre_commit`
3. **When adding new models/routes**: Run `make build-runner`
4. **When updating translations**: Run `make slang`
5. **Clean rebuild**: Run `make clean` then `make init`

## CI/CD

GitHub Actions workflow (manual trigger via `workflow_dispatch`):

**Build job:**
- Installs Flutter and dependencies (with pub cache)
- Generates code (build_runner, Slang)
- Runs static analysis
- Executes tests with coverage
- Uploads coverage to Codecov

**Lint job:**
- Runs custom_lint checks
- Runs riverpod_lint checks

## Troubleshooting

| Issue | Solution |
|---|---|
| Build runner conflicts | `make clean` then `make build-runner` |
| Dependency conflicts | Delete `pubspec.lock` and run `make get` |
| Flutter setup issues | Run `flutter doctor` |
| Pre-commit failures | Run `flutter_pre_commit` manually for details |
| Full clean rebuild | `make clean` followed by `make init` |

## Developer Guides

See `dev_guide/` for implementation examples:
- `create_page_guide.md` — How to create a new page/feature
- `home_page_implementation.md` — Home page architecture
- `home_page_i18n_implementation.md` — Adding translations
- `recent_documents_enhancement.md` — Feature enhancement example

## Contributing

1. Run `make init` to set up the project
2. Make your changes
3. Run `make test` and `make analyze`
4. Commit (pre-commit hooks run automatically)
5. Push and create a pull request
