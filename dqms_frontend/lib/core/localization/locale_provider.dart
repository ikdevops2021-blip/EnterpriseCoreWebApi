import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported application languages metadata
class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isRtl = false,
  });
}

class SupportedLanguages {
  static const english = AppLanguage(code: 'en', name: 'English', nativeName: 'English');
  static const hindi = AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी');
  static const assamese = AppLanguage(code: 'as', name: 'Assamese', nativeName: 'অসমীয়া');
  static const arabic = AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', isRtl: true);

  static const List<AppLanguage> all = [english, hindi, assamese, arabic];

  static AppLanguage findByCode(String code) {
    return all.firstWhere((lang) => lang.code == code, orElse: () => english);
  }
}

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _prefKey = 'selected_app_locale';

  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null && savedCode.isNotEmpty) {
        state = Locale(savedCode);
      }
    } catch (_) {
      // Graceful fallback to default English if preferences are unavailable
    }
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, languageCode);
    } catch (_) {}
  }

  bool get isRtl => state.languageCode == 'ar';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
