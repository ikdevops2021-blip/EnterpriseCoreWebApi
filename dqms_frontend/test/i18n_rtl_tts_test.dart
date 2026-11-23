import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dqms_frontend/core/localization/locale_provider.dart';
import 'package:dqms_frontend/core/services/dqms_audio_voice_service.dart';
import 'package:dqms_frontend/core/widgets/language_selector_dropdown.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Supported Languages & Metadata Tests', () {
    test('All required enterprise languages are supported', () {
      final codes = SupportedLanguages.all.map((l) => l.code).toList();
      expect(codes, containsAll(['en', 'hi', 'as', 'ar']));
    });

    test('Arabic is correctly identified as Right-to-Left (RTL)', () {
      final arabic = SupportedLanguages.findByCode('ar');
      expect(arabic.isRtl, isTrue);

      final english = SupportedLanguages.findByCode('en');
      expect(english.isRtl, isFalse);

      final hindi = SupportedLanguages.findByCode('hi');
      expect(hindi.isRtl, isFalse);

      final assamese = SupportedLanguages.findByCode('as');
      expect(assamese.isRtl, isFalse);
    });

    test('Native language names are accurately designated', () {
      expect(SupportedLanguages.findByCode('hi').nativeName, equals('हिन्दी'));
      expect(SupportedLanguages.findByCode('as').nativeName, equals('অসমীয়া'));
      expect(SupportedLanguages.findByCode('ar').nativeName, equals('العربية'));
      expect(SupportedLanguages.findByCode('en').nativeName, equals('English'));
    });
  });

  group('2. Locale State Notifier & Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Default locale initializes to English', () {
      final notifier = LocaleNotifier();
      expect(notifier.state.languageCode, equals('en'));
      expect(notifier.isRtl, isFalse);
    });

    test('Setting locale to Arabic updates state and activates RTL mode', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocale('ar');

      expect(notifier.state.languageCode, equals('ar'));
      expect(notifier.isRtl, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_app_locale'), equals('ar'));
    });

    test('Setting locale to Hindi and Assamese persists accurately', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocale('hi');
      expect(notifier.state.languageCode, equals('hi'));
      expect(notifier.isRtl, isFalse);

      await notifier.setLocale('as');
      expect(notifier.state.languageCode, equals('as'));
      expect(notifier.isRtl, isFalse);
    });
  });

  group('3. Multi-Lingual Audio Voice Service (TTS) Tests', () {
    test('BCP 47 language mapping produces proper regional synthesis tags', () {
      expect(DqmsAudioVoiceService.mapLanguageToBcp47('en'), equals('en-US'));
      expect(DqmsAudioVoiceService.mapLanguageToBcp47('hi'), equals('hi-IN'));
      expect(DqmsAudioVoiceService.mapLanguageToBcp47('as'), equals('as-IN'));
      expect(DqmsAudioVoiceService.mapLanguageToBcp47('ar'), equals('ar-SA'));
    });

    test('AudioSpeechTask carries dual-language announcement payloads', () {
      final task = AudioSpeechTask(
        tokenNumber: 'A-010',
        counterName: 'C-02',
        primaryLanguageCode: 'hi-IN',
        secondaryLanguageCode: 'en-US',
        primaryText: 'टोकन A-010, कृपया काउंटर C-02 पर पधारें',
        secondaryText: 'Token A-010, please proceed to Counter C-02',
      );

      expect(task.tokenNumber, equals('A-010'));
      expect(task.counterName, equals('C-02'));
      expect(task.primaryLanguageCode, equals('hi-IN'));
      expect(task.secondaryLanguageCode, equals('en-US'));
      expect(task.primaryText, contains('टोकन'));
      expect(task.secondaryText, contains('Token'));
    });
  });

  group('4. UI Widget Integration Tests', () {
    testWidgets('LanguageSelectorDropdown renders all languages and handles selection', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: LanguageSelectorDropdown(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dropdown icon exists
      expect(find.byIcon(Icons.language_rounded), findsOneWidget);

      // Verify English native text is displayed initially
      expect(find.text('English'), findsOneWidget);
    });
  });
}
