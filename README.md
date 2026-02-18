# ResumeIQ - AI Resume Builder with Live ATS Score

A complete, production-level Flutter application for building and analyzing resumes with AI-powered ATS (Applicant Tracking System) scoring. This is a **UI-ONLY** implementation with mock data, following Clean Architecture principles.

## 🎯 Features

### Core Features

1. **Authentication System**
   - Splash Screen with animations
   - Login Page with email/password
   - Register Page with form validation
   - Google Sign-In support (UI only)
   - Password reset functionality

2. **Resume Management**
   - Resume Dashboard with all user resumes
   - Create Resume flow
   - Resume Editor with multiple sections
   - Resume Preview with professional formatting
   - PDF Export with template selection

3. **ATS Analysis**
   - Live ATS scoring (65-95 range)
   - Keyword matching analysis
   - Missing keywords identification
   - Improvement suggestions
   - Animated score visualization

4. **Profile Management**
   - User profile display
   - Settings toggles (dark mode, notifications, language)
   - Logout functionality

## 🏗️ Architecture

### Clean Architecture Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # Material 3 color system
│   │   ├── app_routes.dart      # Route definitions
│   │   ├── app_strings.dart     # Centralized strings
│   │   └── app_theme.dart       # Material 3 themes
│   ├── errors/
│   │   ├── exceptions.dart      # Custom exceptions
│   │   └── failures.dart        # Failure types
│   ├── services/
│   │   ├── ai_service.dart      # Mock ATS analysis
│   │   └── firebase_service.dart # Mock auth service
│   └── utils/
│       ├── date_formatter.dart  # Date utilities
│       ├── pdf_helper.dart      # Mock PDF generation
│       └── validators.dart      # Form validators
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/     # Auth remote data source
│   │   │   ├── models/          # User model
│   │   │   └── repositories/    # Repository implementation
│   │   ├── domain/
│   │   │   ├── entities/        # User entity
│   │   │   ├── repositories/    # Repository interface
│   │   │   └── usecases/        # 5 use cases
│   │   └── presentation/
│   │       ├── bloc/            # Auth BLoC
│   │       └── pages/           # UI pages
│   ├── resume/
│   │   ├── data/
│   │   │   ├── datasources/     # Local data source with mock resumes
│   │   │   ├── models/          # Resume models (10 models)
│   │   │   └── repositories/    # Repository implementation
│   │   ├── domain/
│   │   │   ├── entities/        # Resume entities (10 entities)
│   │   │   ├── repositories/    # Repository interface
│   │   │   └── usecases/        # 5 CRUD use cases
│   │   └── presentation/
│   │       ├── bloc/            # Resume BLoC
│   │       └── pages/           # Dashboard, Preview, PDF Export
│   ├── ats_analysis/
│   │   ├── data/                # ATS data layer
│   │   ├── domain/              # ATS entities
│   │   └── presentation/        # ATS analysis page
│   └── profile/
│       └── profile_page.dart    # User profile
├── injection_container.dart     # GetIt dependency injection
└── main.dart                    # App entry point
```

## 🎨 Design System

### Color Palette

- **Primary**: Deep Blue (#1E3A8A) - Professional, trustworthy
- **Accent**: Emerald (#10B981) - Success, growth
- **Background**: Light Gray (#F9FAFB) for light mode
- **ATS Score Colors**:
  - Excellent (80-100): Emerald Green
  - Good (60-79): Blue
  - Average (40-59): Orange
  - Poor (0-39): Red

### Typography

- Material 3 typography system
- Font sizes: 11-32px
- Weights: Regular (400), Medium (500), Bold (700)

### UI Components

- 16px rounded corners on cards
- 12px rounded corners on inputs
- 2px elevation on cards
- Smooth animations (150-300ms)
- Mobile-first responsive design

## 📦 Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3 # State management
  get_it: ^8.0.2 # Dependency injection
  dartz: ^0.10.1 # Functional programming
  equatable: ^2.0.5 # Value equality
  intl: ^0.20.2 # Date formatting
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: ^3.10.7
- Dart SDK: ^3.0.0

### Installation

1. Clone the repository:

```bash
git clone <repository-url>
cd resumebuilder
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

### Build for Production

**Android:**

```bash
flutter build apk --release
```

**iOS:**

```bash
flutter build ios --release
```

**Web:**

```bash
flutter build web --release
```

## 📱 Screens & Navigation

### Navigation Flow

```
Splash → Login → Dashboard → Resume Editor
                          ↓
                    Resume Preview → PDF Export
                          ↓
                    ATS Analysis
```

### Screen List

1. **SplashPage** - Animated intro screen
2. **LoginPage** - Email/password login
3. **RegisterPage** - New user registration
4. **DashboardPage** - Resume list with actions
5. **CreateResumePage** - Start new resume (placeholder)
6. **ResumeEditorPage** - Edit resume sections (placeholder)
7. **ResumePreviewPage** - Professional resume view
8. **PDFExportPage** - Export with template selection
9. **ATSAnalysisPage** - ATS score and analysis
10. **ProfilePage** - User profile and settings

## 🧪 Mock Data

### Mock Services

- **FirebaseService**: Simulates authentication with 1-second delays
- **AIService**: Generates realistic ATS scores (65-95) with:
  - 8 matched keywords with counts
  - 7 missing keywords with importance
  - 3-6 improvement suggestions

### Mock Resumes

2 complete sample resumes included:

1. **Software Engineer Resume** (87 ATS score)
   - 5 skills, 2 experiences, 2 projects
   - 1 certification, 1 achievement
2. **Full Stack Developer Resume** (72 ATS score)
   - 3 skills, basic information

## 🔧 State Management

### BLoC Pattern

- **AuthBloc**: Authentication state
  - Events: SignIn, SignUp, SignOut, CheckAuth
  - States: Initial, Loading, Authenticated, Unauthenticated, Error

- **ResumeBloc**: Resume management
  - Events: LoadAll, LoadById, Create, Update, Delete, Select
  - States: Initial, Loading, ListLoaded, Loaded, Selected, Created, Updated, Deleted, Error

- **ATSBloc**: ATS analysis
  - Events: AnalyzeResume
  - States: Initial, Analyzing, AnalysisComplete, Error

## 🎯 Error Handling

### Failures

- **ServerFailure**: Mock server errors
- **CacheFailure**: Local storage errors
- **NetworkFailure**: Connection errors
- **AuthFailure**: Authentication errors

### Exceptions

- **AuthException**: Authentication issues
- **ServerException**: Server-side errors
- **CacheException**: Local data errors
- **NetworkException**: Network failures

## 📄 Resume Sections

1. **Personal Information**
   - First/Last Name, Email, Phone, Location, Website, Summary

2. **Education**
   - Degree, Institution, Field of Study, Dates, Grade

3. **Experience**
   - Job Title, Company, Employment Type, Dates, Responsibilities

4. **Skills**
   - Name, Category, Proficiency Level

5. **Projects**
   - Name, Description, Technologies, Link

6. **Certifications**
   - Name, Organization, Issue Date, Credential ID

7. **Achievements**
   - Title, Description, Date

8. **Languages**
   - Name, Proficiency Level

9. **Social Links**
   - LinkedIn, GitHub, Portfolio

## ⚠️ Important Notes

### UI Only - No Backend

- All authentication is mocked (no real Firebase)
- All API calls are simulated with delays
- PDF generation returns mock data
- No actual file operations or network requests

### Production Considerations

To make this production-ready, implement:

1. Real Firebase authentication
2. Backend API for resume storage
3. Actual PDF generation (e.g., using pdf package)
4. Real ATS analysis API integration
5. File upload/download functionality
6. Cloud storage for resumes
7. User analytics and tracking
8. Error reporting (e.g., Sentry)

## 🧩 Key Features to Implement

### Resume Editor Enhancement

The ResumeEditorPage is currently a placeholder. To complete:

1. Personal Info form
2. Education section with add/edit/delete
3. Experience section with responsibilities list
4. Skills section with categories
5. Projects section with technology chips
6. Certifications section
7. Achievements section
8. Languages section with proficiency selector
9. Social links section
10. Section reordering with ReorderableListView

### Additional Features

- Resume templates (Professional, Modern, Minimal, Creative)
- Resume duplication
- Version history
- Export to different formats (Word, PDF, JSON)
- Share resume via link
- Resume analytics (views, downloads)
- ATS tips and best practices section
- Resume comparison tool

## 🎓 Learning Outcomes

This project demonstrates:

- ✅ Clean Architecture implementation
- ✅ BLoC state management
- ✅ Dependency injection with GetIt
- ✅ Material 3 design system
- ✅ Functional programming with Dartz
- ✅ Form validation
- ✅ Custom animations
- ✅ Mock data patterns
- ✅ Error handling strategies
- ✅ Route management

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Material 3 Design](https://m3.material.io/)

## 📄 License

This project is for educational purposes. Use freely for learning and portfolio demonstration.

## 👨‍💻 Author

MCA Student - SEM 2 Project
Contact: [Your Email/GitHub]

---

**Note**: This is a UI-only demonstration application. No actual backend services, API integrations, or file operations are implemented. All data is mocked for demonstration purposes.
