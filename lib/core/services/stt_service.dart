import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Real device Speech-to-Text service supporting English, Telugu, Tamil, Kannada, and Hindi.
class SttService {
  static final SttService _instance = SttService._internal();
  factory SttService() => _instance;
  SttService._internal();

  final SpeechToText _speechToText = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  double _soundLevel = 0.0;

  final ValueNotifier<bool> isListeningNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> soundLevelNotifier = ValueNotifier<double>(0.0);

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  double get soundLevel => _soundLevel;

  /// Initializes speech recognition engine and requests microphone permission if needed
  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onError: (val) {
          debugPrint('STT Error: ${val.errorMsg} - permanent: ${val.permanent}');
          _isListening = false;
          isListeningNotifier.value = false;
        },
        onStatus: (val) {
          debugPrint('STT Status: $val');
          if (val == 'listening') {
            _isListening = true;
            isListeningNotifier.value = true;
          } else if (val == 'notListening' || val == 'done') {
            _isListening = false;
            isListeningNotifier.value = false;
          }
        },
        debugLogging: kDebugMode,
      );

      debugPrint('STT Service initialized: $_isInitialized');
      return _isInitialized;
    } catch (e) {
      debugPrint('STT initialization error: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Maps standard language codes to speech recognition device locales
  String mapToSttLocale(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'te':
        return 'te_IN';
      case 'ta':
        return 'ta_IN';
      case 'kn':
        return 'kn_IN';
      case 'hi':
        return 'hi_IN';
      case 'en':
      default:
        return 'en_US';
    }
  }

  /// Starts listening for user speech with the selected language locale
  Future<bool> startListening({
    required String languageCode,
    required void Function(String recognizedWords, bool isFinal) onResult,
    void Function(double level)? onSoundLevelChange,
    void Function(String error)? onError,
    Duration pauseFor = const Duration(seconds: 3),
    Duration listenFor = const Duration(seconds: 25),
  }) async {
    final hasInit = await init();
    if (!hasInit) {
      onError?.call('Microphone or Speech Recognition permission unavailable.');
      return false;
    }

    try {
      if (_isListening) {
        await stopListening();
      }

      final targetLocaleId = mapToSttLocale(languageCode);
      debugPrint('STT listening started with locale: $targetLocaleId');

      // Check available locales on device to find best match
      final locales = await _speechToText.locales();
      String selectedLocaleId = targetLocaleId;

      if (locales.isNotEmpty) {
        final exact = locales.where((l) => l.localeId.toLowerCase().replaceAll('-', '_') == targetLocaleId.toLowerCase());
        if (exact.isNotEmpty) {
          selectedLocaleId = exact.first.localeId;
        } else {
          final prefixMatch = locales.where((l) => l.localeId.toLowerCase().startsWith(languageCode.toLowerCase()));
          if (prefixMatch.isNotEmpty) {
            selectedLocaleId = prefixMatch.first.localeId;
          }
        }
      }

      debugPrint('Selected device STT locale: $selectedLocaleId');

      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        onSoundLevelChange: (level) {
          _soundLevel = level;
          soundLevelNotifier.value = level;
          onSoundLevelChange?.call(level);
        },
        listenOptions: SpeechListenOptions(
          listenFor: listenFor,
          pauseFor: pauseFor,
          localeId: selectedLocaleId,
          cancelOnError: false,
          partialResults: true,
          listenMode: ListenMode.confirmation,
        ),
      );

      _isListening = true;
      isListeningNotifier.value = true;
      return true;
    } catch (e) {
      debugPrint('STT start listening error: $e');
      _isListening = false;
      isListeningNotifier.value = false;
      onError?.call(e.toString());
      return false;
    }
  }

  /// Stops listening and processes final speech
  Future<void> stopListening() async {
    try {
      if (_isListening) {
        await _speechToText.stop();
      }
    } catch (e) {
      debugPrint('STT stop error: $e');
    } finally {
      _isListening = false;
      isListeningNotifier.value = false;
      _soundLevel = 0.0;
      soundLevelNotifier.value = 0.0;
    }
  }

  /// Cancels listening session immediately
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
    } catch (e) {
      debugPrint('STT cancel error: $e');
    } finally {
      _isListening = false;
      isListeningNotifier.value = false;
      _soundLevel = 0.0;
      soundLevelNotifier.value = 0.0;
    }
  }
}
