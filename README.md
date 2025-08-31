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