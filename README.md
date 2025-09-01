# 🚀 GitHub PR Viewer - Flutter Assignment

A beautiful, performant Flutter app that displays GitHub pull requests with rich UI animations, comprehensive monitoring, and excellent user experience.

## ✨ Features

### Core Features
- 🔐 **Simulated Authentication** with secure token storage
- 📋 **Pull Request Listing** from GitHub REST API
- 🔍 **Real-time Search** through PR titles, descriptions, and authors
- 📊 **Repository Statistics** with visual metrics
- 🌓 **Dark/Light Mode** with smooth transitions
- 📱 **Responsive Design** for phones and tablets

### Rich UI Experience
- 🎭 **Smooth Animations** throughout the app (60fps target)
- ✨ **Shimmer Loading** with realistic placeholders
- 🎨 **Material Design 3** with custom theming
- 💫 **Micro-interactions** and haptic feedback
- 🎯 **Pull-to-Refresh** with custom indicators
- 🌈 **Gradient Overlays** and modern visual effects



## 🏗️ Project Structure

```
lib/
├── core/ # Reusable core utilities
│ ├── router/ # App navigation
│ │ └── app_router.dart
│ ├── theme/ # App-wide theming
│ │ └── app_theme.dart
│ └── utils/ # Helpers & common tools
│ ├── app_logger.dart
│ └── common_exports.dart
│
├── data/ # API & models
│ ├── api/
│ │ └── github_api_service.dart # GitHub API integration
│ └── models/
│ └── pull_request.dart # Pull Request model
│
├── features/ # Feature-based modules
│ ├── auth/ # Authentication
│ │ └── presentation/
│ │ ├── providers/
│ │ │ └── auth_provider.dart
│ │ ├── screens/
│ │ │ └── login_screen.dart
│ │ └── widgets/
│ │ └── login_form.dart
│ │
│ └── pr/ # Pull Requests
│ └── presentation/
│ ├── providers/
│ │ ├── pr_provider.dart
│ │ └── theme_provider.dart
│ ├── screens/
│ │ └── pr_list_screen.dart
│ └── widgets/
│ ├── pr_card.dart
│ ├── pr_search_bar.dart
│ └── pr_shimmer_loading.dart
│
└── main.dart # App entry point
```


## 🔐 Authentication (Github Auth Token)

This project uses a dummy GitHub token instead of real OAuth for simplicity.

On login, a fake token (ghp_<timestamp>abc123) is generated.

The token is stored securely using flutter_secure_storage, while metadata (last username, login time) is cached in shared_preferences.

On app restart, the stored token is used to keep the user logged in.

This demonstrates secure storage practices without requiring real GitHub credentials.

Example (Token Handling)
final fakeToken = 'ghp_${DateTime.now().millisecondsSinceEpoch}abc123';

// Store securely
await _secureStorage.write(key: 'github_token', value: fakeToken);

// Cache metadata
final prefs = await SharedPreferences.getInstance();


## 🚀 Future Improvements

- 🧵 **Isolates for Performance**  
  Use Dart isolates to handle heavy tasks (e.g., parsing large PR lists) without blocking the UI.

- 🔑 **GitHub Token Integration**  
  Allow authenticated users to create Pull Requests directly from the app using a personal access token. 
  Assign reviewers, tag teammates, and manage PRs within the app.

- 📊 **Analytics for Team Performance**  
  Suggest PR reviewers or auto-generate PR titles/descriptions based on commit history.
  Integrate tools like PostHog, Appsflyer for PR creation trends, Merge frequency

- 🌐 **Offline-First Support**  
  Cache PR data locally with Drift/SQLite so the app works even without internet.


## 🎥 Demo Video

[![GitHub PR Viewer Demo](https://youtube.com/shorts/FFFCgEZD4qE?si=KiRypuWre2AYoikE.jpg)](https://youtube.com/shorts/FFFCgEZD4qE?si=KiRypuWre2AYoikE)
