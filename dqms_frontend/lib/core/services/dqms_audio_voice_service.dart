import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Represents a voice announcement task for calling a customer token
class AudioSpeechTask {
  final String tokenNumber;
  final String counterName;
  final String primaryLanguageCode; // e.g. 'hi-IN', 'as-IN', 'ar-SA', 'en-US'
  final String? secondaryLanguageCode; // Optional dual announcement in English 'en-US'
  final String primaryText;
  final String? secondaryText;

  AudioSpeechTask({
    required this.tokenNumber,
    required this.counterName,
    required this.primaryLanguageCode,
    this.secondaryLanguageCode,
    required this.primaryText,
    this.secondaryText,
  });
}

/// Centralized Enterprise TTS Audio Announcement Engine
class DqmsAudioVoiceService {
  static final DqmsAudioVoiceService _instance = DqmsAudioVoiceService._internal();
  factory DqmsAudioVoiceService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  final Queue<AudioSpeechTask> _speechQueue = Queue<AudioSpeechTask>();
  bool _isPlaying = false;
  bool _isInitialized = false;

  DqmsAudioVoiceService._internal();

  /// Initializes default pitch, speech rate, and completion handlers
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setSpeechRate(0.5); // Calm, legible announcement pace
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        _processNext();
      });

      _flutterTts.setErrorHandler((dynamic msg) {
        debugPrint('TTS Error encountered: $msg');
        _isPlaying = false;
        _processNext();
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS Initialization Notice: $e');
    }
  }

  /// Maps app language code ('en', 'hi', 'as', 'ar') to BCP 47 TTS locale code
  static String mapLanguageToBcp47(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'hi':
        return 'hi-IN';
      case 'as':
        // If native Assamese engine is unavailable on the OS, fallback to Bengali/Hindi tone
        return 'as-IN';
      case 'ar':
        return 'ar-SA';
      case 'es':
        return 'es-ES';
      case 'en':
      default:
        return 'en-US';
    }
  }

  /// Queues and broadcasts a calling event with dual language support
  Future<void> announceToken({
    required String tokenNumber,
    required String counterName,
    required String primaryLanguageCode,
    String? secondaryLanguageCode,
    String? primaryCustomAnnouncement,
    String? secondaryCustomAnnouncement,
  }) async {
    await initialize();

    final primaryBcp = mapLanguageToBcp47(primaryLanguageCode);
    final secondaryBcp = secondaryLanguageCode != null ? mapLanguageToBcp47(secondaryLanguageCode) : null;

    final primaryText = primaryCustomAnnouncement ?? _getDefaultAnnouncementText(primaryLanguageCode, tokenNumber, counterName);
    final secondaryText = (secondaryBcp != null && secondaryBcp != primaryBcp)
        ? (secondaryCustomAnnouncement ?? _getDefaultAnnouncementText('en', tokenNumber, counterName))
        : null;

    final task = AudioSpeechTask(
      tokenNumber: tokenNumber,
      counterName: counterName,
      primaryLanguageCode: primaryBcp,
      secondaryLanguageCode: secondaryBcp,
      primaryText: primaryText,
      secondaryText: secondaryText,
    );

    _speechQueue.add(task);

    if (!_isPlaying) {
      _processNext();
    }
  }

  String _getDefaultAnnouncementText(String langCode, String tokenNumber, String counterName) {
    switch (langCode.toLowerCase()) {
      case 'hi':
        return 'टोकन $tokenNumber, कृपया काउंटर $counterName पर पधारें';
      case 'as':
        return 'টোকেন $tokenNumber, অনুগ্ৰহ কৰি কাউন্টাৰ $counterName লৈ যাওক';
      case 'ar':
        return 'تذكرة رقم $tokenNumber، يرجى التوجه إلى شباك $counterName';
      case 'en':
      default:
        return 'Token $tokenNumber, please proceed to Counter $counterName';
    }
  }

  Future<void> _processNext() async {
    if (_speechQueue.isEmpty) {
      _isPlaying = false;
      return;
    }

    _isPlaying = true;
    final task = _speechQueue.removeFirst();

    try {
      // 1. Speak Primary Announcement
      await _flutterTts.setLanguage(task.primaryLanguageCode);
      await _flutterTts.speak(task.primaryText);

      // 2. Speak Secondary Announcement if configured
      if (task.secondaryText != null && task.secondaryLanguageCode != null) {
        await Future.delayed(const Duration(milliseconds: 600));
        await _flutterTts.setLanguage(task.secondaryLanguageCode!);
        await _flutterTts.speak(task.secondaryText!);
      }
    } catch (e) {
      debugPrint('Failed to speak voice task: $e');
      _isPlaying = false;
      _processNext();
    }
  }

  /// Cancels active speech and clears remaining queue
  Future<void> stop() async {
    _speechQueue.clear();
    _isPlaying = false;
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
