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

### Monitoring & Performance
- 📈 **Real-time Performance Monitoring** (FPS, memory, API response times)
- 📊 **Comprehensive Logging** for debugging and analytics
- ⚡ **Performance Benchmarks** and quality gates
- 🔍 **User Interaction Tracking** for UX insights
- 📱 **Device-specific Optimizations**

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── monitoring/
│   │   └── performance_monitor.dart    # Real-time performance tracking
│   ├── router/
│   │   └── app_router.dart            # Navigation with monitoring
│   ├── theme/
│   │   └── app_theme.dart             # Rich Material Design 3 theme
│   └── utils/
│       └── app_logger.dart            # Comprehensive logging system

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


## 🎥 Demo Video

[![GitHub PR Viewer Demo](https://youtube.com/shorts/FFFCgEZD4qE?si=KiRypuWre2AYoikE.jpg)](https://youtube.com/shorts/FFFCgEZD4qE?si=KiRypuWre2AYoikE)
