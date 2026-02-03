# AI-Powered In-App Browser & Document Summarizer

A comprehensive Flutter application featuring an AI-powered in-app browser with document summarization capabilities, smart tab management, file manager with offline support, and multi-language translation.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [API Flow](#api-flow)
- [Storage Logic](#storage-logic)
- [State Management Justification](#state-management-justification)
- [Known Limitations](#known-limitations)
- [Future Improvements](#future-improvements)

## 🎯 Overview

This application provides a feature-rich browsing experience with AI-powered summarization and translation capabilities. Built with Clean Architecture principles, it ensures maintainability, testability, and scalability.

### Key Capabilities

- **Custom In-App Browser**: WebKit/Chromium-based browser with multi-tab support
- **AI Summary Widget**: One-tap summarization of web pages and documents
- **Smart Tab Manager**: Visual grid view with caching and session restore
- **File Manager**: Download management with offline access
- **Translation**: Multi-language support for summaries

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │   Screens   │  │   Widgets   │  │   Riverpod Providers    │ │
│  │ - Browser   │  │ - TabBar    │  │ - browserTabsProvider   │ │
│  │ - Files     │  │ - AddressBar│  │ - fileManagerProvider   │ │
│  │ - Tabs      │  │ - WebView   │  │ - summaryProvider       │ │
│  │ - Settings  │  │ - SummaryPnl│  │ - themeModeProvider     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DOMAIN LAYER                              │
│  ┌─────────────────────┐  ┌─────────────────────────────────┐  │
│  │      Entities       │  │     Repository Interfaces       │  │
│  │ - BrowserTab        │  │ - BrowserRepository             │  │
│  │ - HistoryItem       │  │ - FileManagerRepository         │  │
│  │ - FileItem          │  │ - AiSummaryRepository           │  │
│  │ - Summary           │  │ - SettingsRepository            │  │
│  │ - Translation       │  │                                 │  │
│  └─────────────────────┘  └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DATA LAYER                               │
│  ┌─────────────────────┐  ┌─────────────────────────────────┐  │
│  │       Models        │  │         Data Sources            │  │
│  │ - BrowserTabModel   │  │ ┌─────────────┐ ┌─────────────┐ │  │
│  │ - HistoryItemModel  │  │ │   Local     │ │   Remote    │ │  │
│  │ - FileItemModel     │  │ │ (Hive DB)   │ │ (Dio HTTP)  │ │  │
│  │ - SummaryModel      │  │ └─────────────┘ └─────────────┘ │  │
│  └─────────────────────┘  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Repository Implementations                  │   │
│  │  - BrowserRepositoryImpl (Either<Failure, Success>)     │   │
│  │  - FileManagerRepositoryImpl                            │   │
│  │  - AiSummaryRepositoryImpl                              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        CORE LAYER                               │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────────┐   │
│  │ Constants │ │  Errors   │ │  Network  │ │    Theme      │   │
│  │           │ │ Failures  │ │  Info     │ │  Light/Dark   │   │
│  │           │ │ Exceptions│ │           │ │               │   │
│  └───────────┘ └───────────┘ └───────────┘ └───────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## 🛠️ Technology Stack

| Category | Technology | Version | Purpose |
|----------|------------|---------|---------|
| Framework | Flutter | 3.x Stable | Cross-platform UI |
| Version Manager | FVM | 3.2.1 | Flutter version management |
| State Management | Riverpod | 2.6.1 | Reactive state management |
| Local Storage | Hive | 2.2.3 | NoSQL local database |
| HTTP Client | Dio | 5.x | API requests |
| Browser Engine | flutter_inappwebview | 6.1.5 | WebView implementation |
| Error Handling | dartz | 0.10.1 | Functional programming (Either) |
| File Handling | file_picker | 8.x | Native file selection |
| Connectivity | connectivity_plus | 6.x | Network status monitoring |
| PDF Rendering | syncfusion_flutter_pdfviewer | 27.x | PDF display |

## ✨ Features

### 1. In-App Browser
- Multi-tab browsing with visual tab grid
- Address bar with URL validation
- Navigation controls (back, forward, refresh)
- Progress indicator
- Page title extraction
- Session persistence

### 2. AI Summarization
- One-tap page summarization
- Collapsible summary panel
- Copy to clipboard
- Download as text file
- Share functionality
- Cached summaries for offline access

### 3. Translation
- Multi-language support (EN, ES, FR, DE, ZH, JA, KO, AR, HI, PT)
- Summary translation
- Language preference persistence

### 4. File Manager
- Local file browsing
- PDF, DOC, TXT support
- File summarization
- Download management
- Offline access to downloaded files

### 5. Settings
- Theme toggle (Light/Dark/System)
- Browser settings (JavaScript, cookies, popups)
- Cache management
- AI feature configuration

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── providers/
│   │   └── core_providers.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── logger.dart
├── features/
│   ├── browser/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── browser_local_data_source.dart
│   │   │   │   └── browser_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   ├── browser_tab_model.dart
│   │   │   │   └── history_item_model.dart
│   │   │   └── repositories/
│   │   │       └── browser_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── browser_tab.dart
│   │   │   │   └── history_item.dart
│   │   │   └── repositories/
│   │   │       └── browser_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── browser_providers.dart
│   │       ├── screens/
│   │       │   ├── browser_screen.dart
│   │       │   └── tabs_screen.dart
│   │       └── widgets/
│   │           ├── browser_address_bar.dart
│   │           ├── browser_tab_bar.dart
│   │           ├── browser_webview.dart
│   │           └── summary_panel.dart
│   ├── file_manager/
│   │   ├── data/...
│   │   ├── domain/...
│   │   └── presentation/...
│   ├── ai_summary/
│   │   ├── data/...
│   │   ├── domain/...
│   │   └── presentation/...
│   └── settings/
│       └── presentation/...
├── main.dart
└── main_app.dart
```

## 🚀 Setup Instructions

### Prerequisites

1. Install FVM (Flutter Version Manager):
   ```bash
   dart pub global activate fvm
   ```

2. Clone the repository:
   ```bash
   git clone <repository-url>
   cd ai_browser_app
   ```

### Installation

1. Install Flutter version using FVM:
   ```bash
   fvm install stable
   fvm use stable
   ```

2. Get dependencies:
   ```bash
   fvm flutter pub get
   ```

3. Run the app:
   ```bash
   # Android
   fvm flutter run -d android
   
   # iOS
   fvm flutter run -d ios
   
   # Web
   fvm flutter run -d chrome
   ```

### Building

```bash
# Android APK
fvm flutter build apk --release

# Android App Bundle
fvm flutter build appbundle --release

# iOS
fvm flutter build ios --release

# Web
fvm flutter build web --release
```

## 🔄 API Flow

### Summarization Flow

```
┌─────────┐     ┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
│   UI    │────▶│  Provider   │────▶│   Repository     │────▶│ Remote DS   │
│ (Click) │     │ (summarize) │     │ (getSummary)     │     │ (API Call)  │
└─────────┘     └─────────────┘     └──────────────────┘     └─────────────┘
                      │                      │                      │
                      │                      │                      ▼
                      │                      │              ┌─────────────┐
                      │                      │              │  AI Model   │
                      │                      │              │   Server    │
                      │                      │              └─────────────┘
                      │                      │                      │
                      ▼                      ▼                      ▼
               ┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
               │   State     │◀────│    Cache to      │◀────│   Response  │
               │   Update    │     │     Local DS     │     │   (JSON)    │
               └─────────────┘     └──────────────────┘     └─────────────┘
```

### Offline-First Strategy

```
┌───────────────────────────────────────────────────────────────────┐
│                         REQUEST FLOW                              │
│                                                                   │
│   ┌─────────┐    ┌──────────────┐    ┌─────────────────────┐     │
│   │ Request │───▶│ Check Cache  │───▶│ Cache Hit?          │     │
│   └─────────┘    └──────────────┘    └─────────────────────┘     │
│                                              │                    │
│                         ┌────────────────────┼────────────────┐  │
│                         │ YES                │ NO             │  │
│                         ▼                    ▼                │  │
│              ┌─────────────────┐   ┌─────────────────┐       │  │
│              │ Return Cached   │   │ Check Network   │       │  │
│              │     Data        │   │   Connectivity  │       │  │
│              └─────────────────┘   └─────────────────┘       │  │
│                                          │                    │  │
│                      ┌───────────────────┼────────────────┐  │  │
│                      │ ONLINE            │ OFFLINE        │  │  │
│                      ▼                   ▼                │  │  │
│           ┌─────────────────┐   ┌─────────────────┐      │  │  │
│           │  Fetch Remote   │   │ Return Failure  │      │  │  │
│           │  Cache Result   │   │ (No Connection) │      │  │  │
│           └─────────────────┘   └─────────────────┘      │  │  │
└───────────────────────────────────────────────────────────────────┘
```

## 💾 Storage Logic

### Hive Boxes

| Box Name | TypeAdapter ID | Purpose |
|----------|----------------|---------|
| `browser_tabs` | 0 | Active browser tabs |
| `history` | 1 | Browsing history |
| `files` | 2 | Downloaded/managed files |
| `summaries` | 3 | Cached summaries |

### Data Persistence Strategy

1. **Session Data**: Browser tabs, active state → Hive
2. **History**: URL visits with timestamps → Hive (max 1000 entries)
3. **Summaries**: AI-generated summaries → Hive with URL as key
4. **Files**: Downloaded file metadata → Hive
5. **Settings**: User preferences → SharedPreferences

## 🧠 State Management Justification

### Why Riverpod over BLoC?

| Criteria | Riverpod | BLoC |
|----------|----------|------|
| **Compile-time Safety** | ✅ Full support | ❌ Runtime errors |
| **BuildContext** | ✅ Not required | ❌ Required |
| **Provider Override** | ✅ Easy testing | ⚠️ More boilerplate |
| **Code Generation** | ⚠️ Optional | ❌ Required (freezed) |
| **Learning Curve** | ✅ Moderate | ⚠️ Steeper |
| **Dependency Injection** | ✅ Built-in | ❌ Separate package |

### Provider Types Used

- **StateNotifierProvider**: Complex state with methods (tabs, files)
- **FutureProvider**: Async operations (summaries, translations)
- **Provider**: Simple dependencies (repositories, services)
- **StateProvider**: Simple state (selected items, loading flags)

## ⚠️ Known Limitations

1. **AI Integration**: Currently using mock responses; requires real AI API integration
2. **Web Platform**: InAppWebView not fully supported; fallback to url_launcher
3. **iOS Permissions**: Requires additional Info.plist configuration for file access
4. **Translation API**: Placeholder implementation; needs actual translation service
5. **PWA Features**: Service worker configuration needed for full offline support

## 🚀 Future Improvements

1. **Phase 1**: Integrate actual AI summarization API (OpenAI, Google AI)
2. **Phase 2**: Add speech-to-text for voice commands
3. **Phase 3**: Implement sync across devices
4. **Phase 4**: Add browser extensions support
5. **Phase 5**: Implement collaborative features (shared tabs, notes)

## 📄 License

This project is proprietary software. All rights reserved.

---

**Built with ❤️ using Flutter and Clean Architecture**
