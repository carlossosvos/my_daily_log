# My Daily Log

A Flutter application for creating and managing daily logs with multi-user support and local persistence.

## Features

### ✅ Current Features

- **Multi-User Authentication**
  - Auth0 integration for secure login/logout
  - Email verification enforcement
  - User-specific data isolation

- **Daily Log Management**
  - Create, read, update, and delete daily logs
  - Each log has a title and content
  - Automatic timestamps (created/updated)
  - Swipeable actions for quick edit/delete

- **Local Database**
  - Drift (SQLite) for offline-first data persistence
  - Per-user data isolation in the database
  - Automatic cleanup on logout for privacy

- **Clean Architecture**
  - Domain, Data, and Presentation layers
  - Repository pattern for data access
  - BLoC for state management
  - Dependency Injection with GetIt

## Architecture

```
lib/
├── core/                    # Core functionality
│   ├── auth/               # Authentication (Auth0)
│   ├── config/             # App configuration
│   ├── di/                 # Dependency injection
│   ├── router/             # Navigation (GoRouter)
│   └── utils/              # Utilities
├── data/                    # Data layer
│   ├── datasources/
│   │   └── local/          # Drift database & DAOs
│   │       ├── tables/     # Table definitions
│   │       ├── daos/       # Data Access Objects
│   │       └── app_database.dart
│   ├── models/             # Data models & converters
│   └── repositories/       # Repository implementations
├── domain/                  # Domain layer
│   ├── entities/           # Business entities
│   └── repositories/       # Repository interfaces
└── presentation/            # UI layer
    ├── bloc/               # BLoC state management
    ├── screens/            # App screens
    └── widgets/            # Reusable widgets
```

## Tech Stack

- **Framework:** Flutter 3.10+
- **State Management:** flutter_bloc
- **Local Database:** Drift (SQLite)
- **Authentication:** Auth0
- **Navigation:** GoRouter
- **Dependency Injection:** GetIt
- **UI Components:** flutter_slidable

## Getting Started

### Prerequisites

- Flutter SDK 3.10.1 or higher
- Dart 3.10.1 or higher
- iOS/Android development environment

### Environments

The app supports multiple environments with separate configurations:

| Environment | File | Purpose |
|------------|------|---------|
| **Development** | `dart_defines.dev.json` | Local development with debug features |
| **Staging** | `dart_defines.staging.json` | Pre-production testing environment |
| **Production** | `dart_defines.prod.json` | Live production environment |

**Environment Configuration:**
Each environment file contains:
- `ENVIRONMENT` - Environment name
- `APP_NAME` - Display name for the app
- `ENABLE_LOGGING` - Debug logging toggle
- `AUTH0_DOMAIN` - Auth0 domain
- `AUTH0_CLIENT_ID` - Auth0 client ID
- `SUPABASE_URL` - Supabase project URL (future use)
- `SUPABASE_ANON_KEY` - Supabase anonymous key (future use)
- `API_BASE_URL` - API endpoint (future use)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd my_daily_log
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment**
   - Copy `dart_defines.example.json` to create your environment files:
     ```bash
     cp dart_defines.example.json dart_defines.dev.json
     cp dart_defines.example.json dart_defines.staging.json
     cp dart_defines.example.json dart_defines.prod.json
     ```
   - Update Auth0 credentials in each environment file:
     ```json
     {
       "ENVIRONMENT": "development",
       "APP_NAME": "My Daily Log (Dev)",
       "ENABLE_LOGGING": "true",
       "AUTH0_DOMAIN": "your-domain.auth0.com",
       "AUTH0_CLIENT_ID": "your-client-id"
     }
     ```

4. **Generate code** (if needed)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   
   Choose your environment:
   
   ```bash
   # Development
   flutter run --dart-define-from-file=dart_defines.dev.json
   
   # Staging
   flutter run --dart-define-from-file=dart_defines.staging.json
   
   # Production
   flutter run --dart-define-from-file=dart_defines.prod.json
   ```

## Project Structure Details

### Data Layer

**Database Tables:**
- `daily_logs` - Stores user daily logs with user isolation via `user_id`

**DAOs (Data Access Objects):**
- `DailyLogDao` - CRUD operations for daily logs
  - `getAllLogsByUser(userId)` - Fetch all logs for a user
  - `watchAllLogsByUser(userId)` - Reactive stream for logs
  - `createLog()`, `updateLog()`, `deleteLog()`
  - `deleteAllLogsByUser()` - Cleanup on logout

### Domain Layer

**Entities:**
- `DailyLog` - Core business entity
- `User` - User information from Auth0

**Repositories:**
- `DailyLogRepository` - Abstract interface for log operations
- `AuthRepository` - Abstract interface for authentication

### Presentation Layer

**BLoCs:**
- `AuthBloc` - Manages authentication state
- `DailyLogBloc` - Manages daily log CRUD operations

**Screens:**
- `DailyLogListScreen` - Main screen showing all logs
- Login/Logout flows integrated with Auth0

## User Data Privacy

The app implements automatic data cleanup:
- All user logs are stored with a `user_id` reference
- On logout, all local data for that user is automatically deleted
- Each login session starts with a clean slate
- No data leakage between user sessions

## Development

### Code Generation

When you modify Drift tables or DAOs:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
flutter test
```

### Analysis

```bash
flutter analyze
```
