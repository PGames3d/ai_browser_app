class AppConstants {
  // App Info
  static const String appName = 'AI Browser';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tabsBoxName = 'tabs_box';
  static const String filesBoxName = 'files_box';
  static const String summariesBoxName = 'summaries_box';
  static const String settingsBoxName = 'settings_box';
  static const String historyBoxName = 'history_box';

  // Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String defaultSearchEngine = 'search_engine';

  // Browser Settings
  static const int maxTabs = 10;
  static const String defaultHomePage = 'https://www.google.com';
  static const String defaultSearchEngineUrl = 'https://www.google.com/search?q=';

  // File Types
  static const List<String> supportedFileTypes = [
    'pdf',
    'docx',
    'pptx',
    'xlsx',
    'txt',
  ];

  // API Endpoints (Mock/Free APIs)
  static const String summaryApiUrl = 'https://api.smmry.com';
  static const String translationApiUrl = 'https://libretranslate.com/translate';

  // Supported Languages for Translation
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'Hindi',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'zh': 'Chinese',
  };

  // Cache Settings
  static const Duration cacheExpiry = Duration(days: 7);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB

  // Network
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
