import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();

  factory TtsService() => _instance;

  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  bool _initialized = false;
  bool _isSpeaking = false;

  VoidCallback? _activeOnStart;
  VoidCallback? _activeOnComplete;
  ValueChanged<String>? _activeOnError;

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    if (_initialized) return;

    try {
      if (!kIsWeb) {
        await _flutterTts.awaitSpeakCompletion(true);
      }

      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Slightly slower rate for clear medical speech pacing
      await _flutterTts.setSpeechRate(kIsWeb ? 0.48 : 0.45);

      // Single, central registration of dispatcher callbacks to prevent race conditions
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _activeOnStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _activeOnComplete?.call();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _activeOnComplete?.call();
      });

      _flutterTts.setPauseHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setContinueHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setErrorHandler((dynamic message) {
        _isSpeaking = false;
        debugPrint('TTS Error: $message');
        _activeOnError?.call(message?.toString() ?? 'TTS Error');
      });

      _initialized = true;
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  /// Inspects available TTS voices and configures the best match for the requested language.
  /// Returns true if a compatible voice is found or configured; false if genuinely unavailable.
  Future<bool> _configureVoiceForLanguage(String languageCode, String locale) async {
    try {
      final voices = await _flutterTts.getVoices;
      Map<String, String>? bestVoice;

      if (voices is List && voices.isNotEmpty) {
        final targetLocale = locale.toLowerCase().replaceAll('_', '-');
        final targetLang = languageCode.toLowerCase();

        for (final v in voices) {
          if (v is Map) {
            final vLocale = (v['locale'] ?? v['lang'] ?? '').toString().toLowerCase().replaceAll('_', '-');
            final vName = (v['name'] ?? '').toString().toLowerCase();

            // 1. Exact locale match (e.g. 'ta-in', 'te-in', 'hi-in', 'kn-in', 'en-us')
            if (vLocale == targetLocale) {
              bestVoice = {
                'name': (v['name'] ?? '').toString(),
                'locale': (v['locale'] ?? locale).toString(),
              };
              break;
            }

            // 2. Language prefix match (e.g. 'ta', 'te', 'hi', 'kn', 'en')
            if (vLocale.startsWith('$targetLang-') || vLocale.startsWith('${targetLang}_') || vLocale == targetLang) {
              bestVoice ??= {
                'name': (v['name'] ?? '').toString(),
                'locale': (v['locale'] ?? locale).toString(),
              };
            }

            // 3. Name-based match fallback
            if (targetLang == 'ta' && (vName.contains('tamil') || vName.contains('தமிழ்'))) {
              bestVoice ??= {'name': (v['name'] ?? '').toString(), 'locale': (v['locale'] ?? locale).toString()};
            } else if (targetLang == 'te' && (vName.contains('telugu') || vName.contains('తెలుగు'))) {
              bestVoice ??= {'name': (v['name'] ?? '').toString(), 'locale': (v['locale'] ?? locale).toString()};
            } else if (targetLang == 'kn' && (vName.contains('kannada') || vName.contains('ಕನ್ನಡ'))) {
              bestVoice ??= {'name': (v['name'] ?? '').toString(), 'locale': (v['locale'] ?? locale).toString()};
            } else if (targetLang == 'hi' && (vName.contains('hindi') || vName.contains('हिन्दी'))) {
              bestVoice ??= {'name': (v['name'] ?? '').toString(), 'locale': (v['locale'] ?? locale).toString()};
            }
          }
        }
      }

      if (bestVoice != null && bestVoice['name']!.isNotEmpty) {
        debugPrint('Configured TTS voice: ${bestVoice['name']} ($locale)');
        await _flutterTts.setVoice(bestVoice);
        await _flutterTts.setLanguage(bestVoice['locale'] ?? locale);
        return true;
      }

      // Check if engine directly supports the locale
      final isAvailable = await _flutterTts.isLanguageAvailable(locale);
      final isAvail = (isAvailable == 1 || isAvailable == true);

      if (isAvail) {
        await _flutterTts.setLanguage(locale);
        return true;
      }

      // If requested non-English language is genuinely not available:
      if (languageCode.toLowerCase() != 'en') {
        debugPrint('TTS language $locale is unavailable in this environment.');
        return false;
      }

      // English fallback
      await _flutterTts.setLanguage('en-US');
      return true;
    } catch (e) {
      debugPrint('Voice configuration error: $e');
      try {
        await _flutterTts.setLanguage(locale);
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> speak({
    required String text,
    required String languageCode,
    VoidCallback? onStart,
    VoidCallback? onComplete,
    ValueChanged<String>? onError,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      onError?.call('Nothing to speak.');
      return false;
    }

    await init();

    try {
      await stop();

      final locale = _mapToTtsLocale(languageCode);
      final isVoiceConfigured = await _configureVoiceForLanguage(languageCode, locale);

      if (!isVoiceConfigured) {
        final langName = _mapCodeToLanguageName(languageCode);
        final err = '$langName voice is unavailable in this browser/device.';
        debugPrint(err);
        onError?.call(err);
        return false;
      }

      _activeOnStart = onStart;
      _activeOnComplete = onComplete;
      _activeOnError = onError;

      debugPrint('TTS speaking in $locale: $cleanText');
      final result = await _flutterTts.speak(cleanText);

      return result == 1 || result == true;
    } catch (e) {
      _isSpeaking = false;
      debugPrint('TTS speak exception: $e');
      onError?.call(e.toString());
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }

    _isSpeaking = false;
    _activeOnStart = null;
    _activeOnComplete = null;
    _activeOnError = null;
  }

  String _mapToTtsLocale(String code) {
    switch (code.toLowerCase()) {
      case 'te':
        return 'te-IN';
      case 'ta':
        return 'ta-IN';
      case 'kn':
        return 'kn-IN';
      case 'hi':
        return 'hi-IN';
      case 'en':
      default:
        return 'en-US';
    }
  }

  String _mapCodeToLanguageName(String code) {
    switch (code.toLowerCase()) {
      case 'te':
        return 'Telugu';
      case 'ta':
        return 'Tamil';
      case 'kn':
        return 'Kannada';
      case 'hi':
        return 'Hindi';
      case 'en':
      default:
        return 'English';
    }
  }
}