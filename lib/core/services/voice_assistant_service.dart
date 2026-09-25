import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/user_profile_model.dart';
import 'information_extraction_service.dart';
import 'stt_service.dart';
import 'tts_service.dart';

enum AssistantMode {
  languageSelection,
  genderSelection,
  basicInfo,
  dashboard,
}

enum BasicInfoField {
  name,
  age,
  height,
  weight,
  bloodGroup,
  completed,
}

class VoiceAssistantService {
  static final VoiceAssistantService _instance =
      VoiceAssistantService._internal();
  factory VoiceAssistantService() => _instance;
  VoiceAssistantService._internal();

  final TtsService _tts = TtsService();
  final SttService _stt = SttService();
  final InformationExtractionService _nlp = InformationExtractionService();

  bool _isActive = false;
  bool get isActive => _isActive;
  bool _isHandlingAction = false;

  // Callbacks
  void Function(String message, String? phonetic)? onAiMessageUpdate;
  void Function(String status)? onStatusUpdate;
  void Function(String languageCode)? onLanguageSelected;
  void Function(Gender gender)? onGenderSelected;
  void Function(ExtractedBasicInfo info)? onBasicInfoUpdated;
  void Function(ConversationalIntent intent)? onIntentDetected;
  VoidCallback? onFlowCompleted;

  BasicInfoField _currentBasicInfoField = BasicInfoField.name;
  ExtractedBasicInfo _accumulatedInfo = const ExtractedBasicInfo();
  String _currentLanguageCode = 'en';

  /// Starts the conversation for a specific screen mode (ONLY after user tap)
  Future<void> startSession({
    required AssistantMode mode,
    required String languageCode,
    ExtractedBasicInfo? existingInfo,
    void Function(String message, String? phonetic)? onAiMessage,
    void Function(String status)? onStatus,
    void Function(String languageCode)? onLanguage,
    void Function(Gender gender)? onGender,
    void Function(ExtractedBasicInfo info)? onBasicInfo,
    void Function(ConversationalIntent intent)? onIntent,
    VoidCallback? onComplete,
  }) async {
    _isActive = true;
    _isHandlingAction = false;
    _currentLanguageCode = languageCode;
    onAiMessageUpdate = onAiMessage;
    onStatusUpdate = onStatus;
    onLanguageSelected = onLanguage;
    onGenderSelected = onGender;
    onBasicInfoUpdated = onBasicInfo;
    onIntentDetected = onIntent;
    onFlowCompleted = onComplete;

    if (existingInfo != null) {
      _accumulatedInfo = existingInfo;
    } else {
      _accumulatedInfo = const ExtractedBasicInfo();
    }

    if (mode == AssistantMode.languageSelection) {
      await _startLanguageSelectionFlow();
    } else if (mode == AssistantMode.genderSelection) {
      await _startGenderSelectionFlow();
    } else if (mode == AssistantMode.basicInfo) {
      await _startBasicInfoFlow();
    } else if (mode == AssistantMode.dashboard) {
      await _startDashboardConversationalFlow();
    }
  }

  /// Handles speech input piped from manual mic taps or external triggers
  Future<void> handleExternalSpeechInput(
    String recognized,
    bool isFinal, {
    required AssistantMode mode,
  }) async {
    if (!_isActive || _isHandlingAction || recognized.trim().isEmpty) return;

    if (mode == AssistantMode.languageSelection) {
      final lang = _nlp.extractLanguage(recognized);
      if (lang != null) {
        _isHandlingAction = true;
        _currentLanguageCode = lang;
        await _stt.stopListening();
        onLanguageSelected?.call(lang);
        final confirm = _getLanguageConfirm(lang);
        _displayAiMessage(confirm['text']!, confirm['phonetic']);
        await _tts.speak(
          text: confirm['text']!,
          languageCode: lang,
          onComplete: () => onFlowCompleted?.call(),
          onError: (err) => onFlowCompleted?.call(),
        );
      }
    } else if (mode == AssistantMode.genderSelection) {
      final gender = _nlp.extractGender(recognized);
      if (gender != null) {
        _isHandlingAction = true;
        await _stt.stopListening();
        onGenderSelected?.call(gender);
        final confirm = _getGenderConfirm(_currentLanguageCode, gender);
        _displayAiMessage(confirm['text']!, confirm['phonetic']);
        await _tts.speak(
          text: confirm['text']!,
          languageCode: _currentLanguageCode,
          onComplete: () => onFlowCompleted?.call(),
          onError: (err) => onFlowCompleted?.call(),
        );
      }
    } else if (mode == AssistantMode.dashboard) {
      final lang = _nlp.extractLanguage(recognized);
      if (lang != null && lang != _currentLanguageCode) {
        _isHandlingAction = true;
        _currentLanguageCode = lang;
        await _stt.stopListening();
        onLanguageSelected?.call(lang);
        final confirm = _getLanguageConfirm(lang);
        _displayAiMessage(confirm['text']!, confirm['phonetic']);
        await _tts.speak(
          text: confirm['text']!,
          languageCode: lang,
          onComplete: () => onFlowCompleted?.call(),
          onError: (err) => onFlowCompleted?.call(),
        );
        return;
      }

      final intent = _nlp.extractConversationalIntent(recognized);
      if (intent != null) {
        _isHandlingAction = true;
        await _stt.stopListening();
        onIntentDetected?.call(intent);
        final confirm = _getIntentConfirmation(_currentLanguageCode, intent);
        _displayAiMessage(confirm['text']!, confirm['phonetic']);
        await _tts.speak(
          text: confirm['text']!,
          languageCode: _currentLanguageCode,
          onComplete: () => onFlowCompleted?.call(),
          onError: (err) => onFlowCompleted?.call(),
        );
      }
    }
  }

  /// Stop current active session
  Future<void> stopSession() async {
    _isActive = false;
    _isHandlingAction = false;
    await _tts.stop();
    await _stt.stopListening();
  }

  // =========================================================================
  // LANGUAGE SELECTION FLOW
  // =========================================================================

  Future<void> _startLanguageSelectionFlow() async {
    _isHandlingAction = false;
    final prompt = _getLanguagePrompt(_currentLanguageCode);
    _displayAiMessage(prompt['text']!, prompt['phonetic']);

    await _speakAndListen(
      text: prompt['text']!,
      languageCode: _currentLanguageCode,
      onSpeechResult: (recognized, isFinal) async {
        if (!_isActive || _isHandlingAction || recognized.trim().isEmpty) return;

        final detectedLang = _nlp.extractLanguage(recognized);
        if (detectedLang != null) {
          _isHandlingAction = true;
          _currentLanguageCode = detectedLang;
          await _stt.stopListening();

          final langNames = {
            'en': 'English',
            'te': 'Telugu (తెలుగు)',
            'hi': 'Hindi (हिंदी)',
            'ta': 'Tamil (தமிழ்)',
            'kn': 'Kannada (ಕನ್ನಡ)',
          };
          final langDisplay = langNames[detectedLang] ?? detectedLang;
          onStatusUpdate?.call('Selecting $langDisplay...');
          onLanguageSelected?.call(detectedLang);

          final confirm = _getLanguageConfirm(detectedLang);
          _displayAiMessage(confirm['text']!, confirm['phonetic']);
          
          await _tts.speak(
            text: confirm['text']!,
            languageCode: detectedLang,
            onComplete: () {
              onStatusUpdate?.call('Language selected. Continuing...');
              onFlowCompleted?.call();
            },
            onError: (err) {
              onStatusUpdate?.call('Language selected. Continuing...');
              onFlowCompleted?.call();
            },
          );
        } else if (isFinal) {
          final retry = _getLanguageRetry(_currentLanguageCode);
          _displayAiMessage(retry['text']!, retry['phonetic']);
          await _speakAndListen(
            text: retry['text']!,
            languageCode: _currentLanguageCode,
            onSpeechResult: (r, fin) async {
              if (!_isActive || _isHandlingAction || r.trim().isEmpty) return;
              final lang = _nlp.extractLanguage(r);
              if (lang != null) {
                _isHandlingAction = true;
                _currentLanguageCode = lang;
                await _stt.stopListening();
                onLanguageSelected?.call(lang);
                final confirm = _getLanguageConfirm(lang);
                _displayAiMessage(confirm['text']!, confirm['phonetic']);
                await _tts.speak(
                  text: confirm['text']!,
                  languageCode: lang,
                  onComplete: () {
                    onStatusUpdate?.call('Language selected. Continuing...');
                    onFlowCompleted?.call();
                  },
                  onError: (err) {
                    onStatusUpdate?.call('Language selected. Continuing...');
                    onFlowCompleted?.call();
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  // =========================================================================
  // DASHBOARD CONVERSATIONAL ACTION FLOW
  // =========================================================================

  Future<void> _startDashboardConversationalFlow() async {
    _isHandlingAction = false;
    final prompt = _getDashboardPrompt(_currentLanguageCode, _accumulatedInfo.name);
    _displayAiMessage(prompt['text']!, prompt['phonetic']);

    await _speakAndListen(
      text: prompt['text']!,
      languageCode: _currentLanguageCode,
      onSpeechResult: (recognized, isFinal) async {
        if (!_isActive || _isHandlingAction || recognized.trim().isEmpty) return;

        // 1. Check if user asked to change language
        final detectedLang = _nlp.extractLanguage(recognized);
        if (detectedLang != null && detectedLang != _currentLanguageCode) {
          _isHandlingAction = true;
          _currentLanguageCode = detectedLang;
          await _stt.stopListening();
          onLanguageSelected?.call(detectedLang);
          final confirm = _getLanguageConfirm(detectedLang);
          _displayAiMessage(confirm['text']!, confirm['phonetic']);
          await _tts.speak(
            text: confirm['text']!,
            languageCode: detectedLang,
            onComplete: () => onFlowCompleted?.call(),
            onError: (err) => onFlowCompleted?.call(),
          );
          return;
        }

        // 2. Check conversational intent
        final intent = _nlp.extractConversationalIntent(recognized);
        if (intent != null) {
          _isHandlingAction = true;
          await _stt.stopListening();

          final confirm = _getIntentConfirmation(_currentLanguageCode, intent);
          _displayAiMessage(confirm['text']!, confirm['phonetic']);
          onStatusUpdate?.call('Executing action...');

          onIntentDetected?.call(intent);

          await _tts.speak(
            text: confirm['text']!,
            languageCode: _currentLanguageCode,
            onComplete: () {
              onFlowCompleted?.call();
            },
            onError: (err) {
              onFlowCompleted?.call();
            },
          );
        } else if (isFinal) {
          final retry = _getDashboardRetry(_currentLanguageCode);
          _displayAiMessage(retry['text']!, retry['phonetic']);
          await _speakAndListen(
            text: retry['text']!,
            languageCode: _currentLanguageCode,
            onSpeechResult: (r, fin) async {
              if (!_isActive || _isHandlingAction || r.trim().isEmpty) return;
              final retryIntent = _nlp.extractConversationalIntent(r);
              if (retryIntent != null) {
                _isHandlingAction = true;
                await _stt.stopListening();
                onIntentDetected?.call(retryIntent);
                final confirm = _getIntentConfirmation(_currentLanguageCode, retryIntent);
                _displayAiMessage(confirm['text']!, confirm['phonetic']);
                await _tts.speak(
                  text: confirm['text']!,
                  languageCode: _currentLanguageCode,
                  onComplete: () => onFlowCompleted?.call(),
                  onError: (e) => onFlowCompleted?.call(),
                );
              }
            },
          );
        }
      },
    );
  }

  // =========================================================================
  // GENDER SELECTION FLOW
  // =========================================================================

  Future<void> _startGenderSelectionFlow() async {
    final prompt = _getGenderPrompt(_currentLanguageCode);
    _displayAiMessage(prompt['text']!, prompt['phonetic']);

    await _speakAndListen(
      text: prompt['text']!,
      languageCode: _currentLanguageCode,
      onSpeechResult: (recognized, isFinal) async {
        if (recognized.trim().isEmpty) return;

        final detectedGender = _nlp.extractGender(recognized);
        if (detectedGender != null) {
          onGenderSelected?.call(detectedGender);

          final confirm = _getGenderConfirm(_currentLanguageCode, detectedGender);
          _displayAiMessage(confirm['text']!, confirm['phonetic']);
          await _tts.speak(
            text: confirm['text']!,
            languageCode: _currentLanguageCode,
            onComplete: () {
              onFlowCompleted?.call();
            },
          );
        } else if (isFinal) {
          final retry = _getGenderRetry(_currentLanguageCode);
          _displayAiMessage(retry['text']!, retry['phonetic']);
          await _speakAndListen(
            text: retry['text']!,
            languageCode: _currentLanguageCode,
            onSpeechResult: (r, fin) {
              final g = _nlp.extractGender(r);
              if (g != null) {
                onGenderSelected?.call(g);
                onFlowCompleted?.call();
              }
            },
          );
        }
      },
    );
  }

  // =========================================================================
  // BASIC INFORMATION FLOW
  // =========================================================================

  Future<void> _startBasicInfoFlow() async {
    _currentBasicInfoField = _getNextMissingField(_accumulatedInfo);
    await _askCurrentField();
  }

  BasicInfoField _getNextMissingField(ExtractedBasicInfo info) {
    if (info.name == null || info.name!.trim().isEmpty) return BasicInfoField.name;
    if (info.age == null) return BasicInfoField.age;
    if (info.heightCm == null) return BasicInfoField.height;
    if (info.weightKg == null) return BasicInfoField.weight;
    if (info.bloodGroup == null || info.bloodGroup!.trim().isEmpty) return BasicInfoField.bloodGroup;
    return BasicInfoField.completed;
  }

  Future<void> _askCurrentField() async {
    if (!_isActive) return;

    // 1. ALWAYS re-evaluate the next missing field from the freshest accumulated info
    _currentBasicInfoField = _getNextMissingField(_accumulatedInfo);

    if (_currentBasicInfoField == BasicInfoField.completed) {
      final donePrompt = _getBasicInfoCompletedPrompt(
        _currentLanguageCode,
        _accumulatedInfo.name ?? 'User',
      );
      _displayAiMessage(donePrompt['text']!, donePrompt['phonetic']);
      await _tts.speak(
        text: donePrompt['text']!,
        languageCode: _currentLanguageCode,
        onComplete: () {
          onFlowCompleted?.call();
        },
      );
      return;
    }

    final targetFieldName = _currentBasicInfoField.name;
    final prompt = _getBasicInfoFieldPrompt(
      _currentLanguageCode,
      _currentBasicInfoField,
      _accumulatedInfo.name,
    );

    _displayAiMessage(prompt['text']!, prompt['phonetic']);

    await _speakAndListen(
      text: prompt['text']!,
      languageCode: _currentLanguageCode,
      onSpeechResult: (recognized, isFinal) async {
        if (recognized.trim().isEmpty) return;

        // Multi-field extraction: extract everything present in the utterance
        final extracted = _nlp.extractBasicInfo(
          recognized,
          currentTargetField: targetFieldName,
        );

        if (extracted.isNotEmpty) {
          _accumulatedInfo = _accumulatedInfo.mergeWith(extracted);
          onBasicInfoUpdated?.call(_accumulatedInfo);

          final nextField = _getNextMissingField(_accumulatedInfo);
          // If the field was extracted or recognized as final:
          if (nextField != _currentBasicInfoField || isFinal) {
            _currentBasicInfoField = nextField;
            await _stt.stopListening();
            await _askCurrentField();
          }
        } else if (isFinal) {
          // If not recognized on final result, ask again politely
          await _askCurrentField();
        }
      },
    );
  }

  // =========================================================================
  // UTILITY SPEECH TURN-TAKING
  // =========================================================================

  Future<void> _speakAndListen({
    required String text,
    required String languageCode,
    required void Function(String recognizedWords, bool isFinal) onSpeechResult,
  }) async {
    if (!_isActive) return;

    onStatusUpdate?.call('AI is speaking...');
    await _stt.stopListening();

    await _tts.speak(
      text: text,
      languageCode: languageCode,
      onStart: () {
        onStatusUpdate?.call('AI is speaking...');
      },
      onComplete: () async {
        if (!_isActive) return;
        onStatusUpdate?.call('Listening to you...');
        await _stt.startListening(
          languageCode: languageCode,
          onResult: (words, isFinal) {
            if (!_isActive) return;
            if (words.isNotEmpty) {
              onStatusUpdate?.call('Heard: "$words"');
            }
            onSpeechResult(words, isFinal);
          },
          onError: (err) {
            onStatusUpdate?.call('Tap microphone to speak');
          },
        );
      },
      onError: (err) async {
        // Fallback: start listening even if TTS engine has issues
        if (!_isActive) return;
        onStatusUpdate?.call('Listening to you...');
        await _stt.startListening(
          languageCode: languageCode,
          onResult: onSpeechResult,
        );
      },
    );
  }

  void _displayAiMessage(String text, String? phonetic) {
    onAiMessageUpdate?.call(text, phonetic);
  }

  // =========================================================================
  // MULTILINGUAL PROMPT STRINGS
  // =========================================================================

  Map<String, String> _getLanguagePrompt(String lang) {
    switch (lang) {
      case 'te':
        return {
          'text': 'హలో! మీ ప్రాధాన్యత గల భాషను ఎంచుకోవడంలో నేను మీకు సహాయం చేస్తాను. మీరు ఏ భాషతో కొనసాగాలనుకుంటున్నారు?',
          'phonetic': 'Hello! Which language would you like to continue with?',
        };
      case 'ta':
        return {
          'text': 'வணக்கம்! உங்கள் விருப்பமான மொழியைத் தேர்ந்தெடுக்க நான் உங்களுக்கு உதவுவேன். நீங்கள் எந்த மொழியில் தொடர விரும்புகிறீர்கள்?',
          'phonetic': 'Vanakkam! Which language would you like to continue with?',
        };
      case 'kn':
        return {
          'text': 'ನಮಸ್ಕಾರ! ನಿಮ್ಮ ಆದ್ಯತೆಯ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಲು ನಾನು ನಿಮಗೆ ಸಹಾಯ ಮಾಡುತ್ತೇನೆ. ನೀವು ಯಾವ ಭಾಷೆಯೊಂದಿಗೆ ಮುಂದುವರಿಯಲು ಬಯಸುತ್ತೀರಿ?',
          'phonetic': 'Namaskara! Which language would you like to continue with?',
        };
      case 'hi':
        return {
          'text': 'नमस्ते! मैं आपकी पसंदीदा भाषा चुनने में आपकी मदद करूँगा। आप किस भाषा के साथ आगे बढ़ना चाहते हैं?',
          'phonetic': 'Namaste! Which language would you like to continue with?',
        };
      case 'en':
      default:
        return {
          'text': 'Hello! I will help you choose your preferred language. Which language would you like to continue with?',
          'phonetic': 'Hello! Which language would you like to choose?',
        };
    }
  }

  Map<String, String> _getLanguageConfirm(String lang) {
    switch (lang) {
      case 'te':
        return {'text': 'సరే, తెలుగు భాష ఎంపిక చేయబడింది.', 'phonetic': 'Telugu selected.'};
      case 'ta':
        return {'text': 'சரி, தமிழ் மொழி தேர்ந்தெடுக்கப்பட்டது.', 'phonetic': 'Tamil selected.'};
      case 'kn':
        return {'text': 'ಸರಿ, ಕನ್ನಡ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ.', 'phonetic': 'Kannada selected.'};
      case 'hi':
        return {'text': 'ठीक है, हिंदी भाषा चुन ली गई है।', 'phonetic': 'Hindi selected.'};
      case 'en':
      default:
        return {'text': 'English has been selected.', 'phonetic': 'English selected.'};
    }
  }

  Map<String, String> _getLanguageRetry(String lang) {
    switch (lang) {
      case 'te':
        return {'text': 'దయచేసి ఇంగ్లీష్, తెలుగు, తమిళం, కన్నడ లేదా హిందీ అని చెప్పండి.', 'phonetic': 'Please say English, Telugu, Tamil, Kannada, or Hindi.'};
      case 'ta':
        return {'text': 'தயவுசெய்து ஆங்கிலம், தமிழ், தெலுங்கு, கன்னடம் அல்லது இந்தி என்று சொல்லுங்கள்.', 'phonetic': 'Please say English, Tamil, Telugu, Kannada, or Hindi.'};
      case 'kn':
        return {'text': 'ದಯವಿಟ್ಟು ಇಂಗ್ಲಿಷ್, ಕನ್ನಡ, ತೆಲುಗು, ತಮಿಳು ಅಥವಾ ಹಿಂದಿ ಎಂದು ಹೇಳಿ.', 'phonetic': 'Please say English, Kannada, Telugu, Tamil, or Hindi.'};
      case 'hi':
        return {'text': 'कृपया अंग्रेजी, हिंदी, तेलुगु, तमिल या कन्नड़ बोलें।', 'phonetic': 'Please say English, Hindi, Telugu, Tamil, or Kannada.'};
      case 'en':
      default:
        return {'text': 'Please say English, Telugu, Tamil, Kannada, or Hindi.', 'phonetic': 'Please speak your language name.'};
    }
  }

  Map<String, String> _getGenderPrompt(String lang) {
    switch (lang) {
      case 'te':
        return {
          'text': 'హాయ్! మీ లింగాన్ని ఎంచుకోవడంలో నేను మీకు సహాయం చేస్తాను. మీరు పురుషుడు, స్త్రీ లేదా ఇతర అని చెప్పవచ్చు.',
          'phonetic': 'Hi! You can say Male, Female, or Other.',
        };
      case 'ta':
        return {
          'text': 'வணக்கம்! உங்கள் பாலினத்தைத் தேர்ந்தெடுக்க நான் உங்களுக்கு உதவுவேன். நீங்கள் ஆண், பெண் அல்லது பிற என்று சொல்லலாம்.',
          'phonetic': 'Hi! You can say Male, Female, or Other.',
        };
      case 'kn':
        return {
          'text': 'ಹಾಯ್! ನಿಮ್ಮ ಲಿಂಗವನ್ನು ಆಯ್ಕೆ ಮಾಡಲು ನಾನು ನಿಮಗೆ ಸಹಾಯ ಮಾಡುತ್ತೇನೆ. ನೀವು ಪುರುಷ, ಮಹಿಳೆ ಅಥವಾ ಇತರೆ ಎಂದು ಹೇಳಬಹುದು.',
          'phonetic': 'Hi! You can say Male, Female, or Other.',
        };
      case 'hi':
        return {
          'text': 'नमस्ते! मैं आपका लिंग चुनने में आपकी मदद करूँगा। आप पुरुष, महिला या अन्य कह सकते हैं।',
          'phonetic': 'Hi! You can say Male, Female, or Other.',
        };
      case 'en':
      default:
        return {
          'text': "Hi! I'll help you choose your gender. You can say Male, Female or Other.",
          'phonetic': 'You can say Male, Female, or Other.',
        };
    }
  }

  Map<String, String> _getGenderConfirm(String lang, Gender gender) {
    final genderStr = gender == Gender.male ? 'Male' : (gender == Gender.female ? 'Female' : 'Other');
    switch (lang) {
      case 'te':
        final t = gender == Gender.male ? 'పురుషుడు' : (gender == Gender.female ? 'స్త్రీ' : 'ఇతర');
        return {'text': 'సరే, $t ఎంపిక చేయబడింది.', 'phonetic': '$genderStr selected.'};
      case 'ta':
        final t = gender == Gender.male ? 'ஆண்' : (gender == Gender.female ? 'பெண்' : 'பிற');
        return {'text': 'சரி, $t தேர்ந்தெடுக்கப்பட்டது.', 'phonetic': '$genderStr selected.'};
      case 'kn':
        final t = gender == Gender.male ? 'ಪುರುಷ' : (gender == Gender.female ? 'ಮಹಿಳೆ' : 'ಇತರೆ');
        return {'text': 'ಸರಿ, $t ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ.', 'phonetic': '$genderStr selected.'};
      case 'hi':
        final t = gender == Gender.male ? 'पुरुष' : (gender == Gender.female ? 'महिला' : 'अन्य');
        return {'text': 'ठीक है, $t चुन लिया गया है।', 'phonetic': '$genderStr selected.'};
      case 'en':
      default:
        return {'text': 'Selected $genderStr.', 'phonetic': 'Selected $genderStr.'};
    }
  }

  Map<String, String> _getGenderRetry(String lang) {
    switch (lang) {
      case 'te':
        return {'text': 'దయచేసి పురుషుడు, స్త్రీ లేదా ఇతర అని స్పష్టంగా చెప్పండి.', 'phonetic': 'Please clearly say Male, Female, or Other.'};
      case 'ta':
        return {'text': 'தயவுசெய்து ஆண், பெண் அல்லது பிற என்று தெளிவாகச் சொல்லுங்கள்.', 'phonetic': 'Please clearly say Male, Female, or Other.'};
      case 'kn':
        return {'text': 'ದಯವಿಟ್ಟು ಪುರುಷ, ಮಹಿಳೆ ಅಥವಾ ಇತರೆ ಎಂದು ಸ್ಪಷ್ಟವಾಗಿ ಹೇಳಿ.', 'phonetic': 'Please clearly say Male, Female, or Other.'};
      case 'hi':
        return {'text': 'कृपया स्पष्ट रूप से पुरुष, महिला या अन्य कहें।', 'phonetic': 'Please clearly say Male, Female, or Other.'};
      case 'en':
      default:
        return {'text': 'Please clearly say Male, Female, or Other.', 'phonetic': 'Please say Male, Female, or Other.'};
    }
  }

  Map<String, String> _getBasicInfoFieldPrompt(
    String lang,
    BasicInfoField field,
    String? userName,
  ) {
    final name = (userName != null && userName.trim().isNotEmpty)
        ? userName.trim().split(RegExp(r'\s+')).first
        : '';

    switch (field) {
      case BasicInfoField.name:
        switch (lang) {
          case 'te':
            return {
              'text': 'హాయ్! మీ వివరాలను నమోదు చేయడంలో నేను మీకు సహాయం చేస్తాను. మీ పేరు ఏమిటి?',
              'phonetic': "Hi! What is your name?",
            };
          case 'ta':
            return {
              'text': 'வணக்கம்! உங்கள் விவரங்களை நிரப்ப நான் உதவுகிறேன். உங்கள் பெயர் என்ன?',
              'phonetic': "Hi! What is your name?",
            };
          case 'kn':
            return {
              'text': 'ನಮಸ್ಕಾರ! ನಿಮ್ಮ ವಿವರಗಳನ್ನು ಭರ್ತಿ ಮಾಡಲು ನಾನು ನಿಮಗೆ ಸಹಾಯ ಮಾಡುತ್ತೇನೆ. ನಿಮ್ಮ ಹೆಸರು ಏನು?',
              'phonetic': "Hi! What is your name?",
            };
          case 'hi':
            return {
              'text': 'नमस्ते! मैं आपके विवरण भरने में आपकी मदद करूँगा। आपका नाम क्या है?',
              'phonetic': "Hi! What is your name?",
            };
          case 'en':
          default:
            return {
              'text': "Hi! I'll help you fill in your details. What is your name?",
              'phonetic': "What is your name?",
            };
        }

      case BasicInfoField.age:
        switch (lang) {
          case 'te':
            return {
              'text': name.isNotEmpty ? 'సరే $name. మీ వయసు ఎంత?' : 'మీ వయసు ఎంత?',
              'phonetic': 'How old are you?',
            };
          case 'ta':
            return {
              'text': name.isNotEmpty ? 'நன்றி $name. உங்கள் வயது என்ன?' : 'உங்கள் வயது என்ன?',
              'phonetic': 'How old are you?',
            };
          case 'kn':
            return {
              'text': name.isNotEmpty ? 'ಧನ್ಯವಾದಗಳು $name. ನಿಮ್ಮ ವಯಸ್ಸು ಎಷ್ಟು?' : 'ನಿಮ್ಮ ವಯಸ್ಸು ಎಷ್ಟು?',
              'phonetic': 'How old are you?',
            };
          case 'hi':
            return {
              'text': name.isNotEmpty ? 'बहुत बढ़िया $name। आपकी उम्र कितनी है?' : 'आपकी उम्र कितनी है?',
              'phonetic': 'How old are you?',
            };
          case 'en':
          default:
            return {
              'text': name.isNotEmpty ? 'Nice to meet you, $name. How old are you?' : 'How old are you?',
              'phonetic': 'How old are you?',
            };
        }

      case BasicInfoField.height:
        switch (lang) {
          case 'te':
            return {'text': 'మీ ఎత్తు ఎన్ని సెంటీమీటర్లు?', 'phonetic': 'What is your height in cm?'};
          case 'ta':
            return {'text': 'உங்கள் உயரம் எத்தனை சென்டிமீட்டர்?', 'phonetic': 'What is your height in cm?'};
          case 'kn':
            return {'text': 'ನಿಮ್ಮ ಎತ್ತರ ಎಷ್ಟು ಸೆಂಟಿಮೀಟರ್?', 'phonetic': 'What is your height in cm?'};
          case 'hi':
            return {'text': 'आपकी लंबाई सेंटीमीटर में कितनी है?', 'phonetic': 'What is your height in cm?'};
          case 'en':
          default:
            return {'text': 'What is your height in centimeters?', 'phonetic': 'What is your height?'};
        }

      case BasicInfoField.weight:
        switch (lang) {
          case 'te':
            return {'text': 'మీ బరువు ఎన్ని కిలోలు?', 'phonetic': 'What is your weight in kg?'};
          case 'ta':
            return {'text': 'உங்கள் எடை எத்தனை கிலோ?', 'phonetic': 'What is your weight in kg?'};
          case 'kn':
            return {'text': 'ನಿಮ್ಮ ತೂಕ ಎಷ್ಟು ಕಿಲೋ?', 'phonetic': 'What is your weight in kg?'};
          case 'hi':
            return {'text': 'आपका वजन कितने किलोग्राम है?', 'phonetic': 'What is your weight in kg?'};
          case 'en':
          default:
            return {'text': 'What is your weight in kilograms?', 'phonetic': 'What is your weight?'};
        }

      case BasicInfoField.bloodGroup:
        switch (lang) {
          case 'te':
            return {'text': 'మీ బ్లడ్ గ్రూప్ ఏమిటి? ఉదాహరణకు O పాజిటివ్.', 'phonetic': 'What is your blood group?'};
          case 'ta':
            return {'text': 'உங்கள் ரத்த வகை என்ன? உதாரணமாக O பாசிட்டிவ்.', 'phonetic': 'What is your blood group?'};
          case 'kn':
            return {'text': 'ನಿಮ್ಮ ರಕ್ತದ ಗುಂಪು ಯಾವುದು? ಉದಾಹರಣೆಗೆ O ಪಾಸಿಟಿವ್.', 'phonetic': 'What is your blood group?'};
          case 'hi':
            return {'text': 'आपका ब्लड ग्रुप क्या है? जैसे कि O पॉजिटिव।', 'phonetic': 'What is your blood group?'};
          case 'en':
          default:
            return {'text': 'What is your blood group? For example, O positive.', 'phonetic': 'What is your blood group?'};
        }

      case BasicInfoField.completed:
        return _getBasicInfoCompletedPrompt(lang, name);
    }
  }

  Map<String, String> _getBasicInfoCompletedPrompt(String lang, String name) {
    switch (lang) {
      case 'te':
        return {
          'text': 'ధన్యవాదాలు $name! మీ ప్రాథమిక వివరాలన్నీ విజయవంతంగా నమోదు చేయబడ్డాయి.',
          'phonetic': 'Thank you! All details saved.',
        };
      case 'ta':
        return {
          'text': 'நன்றி $name! உங்கள் விவரங்கள் அனைத்தும் வெற்றிகரமாக சேமிக்கப்பட்டன.',
          'phonetic': 'Thank you! All details saved.',
        };
      case 'kn':
        return {
          'text': 'ಧನ್ಯವಾದಗಳು $name! ನಿಮ್ಮ ಎಲ್ಲಾ ವಿವರಗಳನ್ನು ಯಶಸ್ವಿಯಾಗಿ ದಾಖಲಿಸಲಾಗಿದೆ.',
          'phonetic': 'Thank you! All details saved.',
        };
      case 'hi':
        return {
          'text': 'धन्यवाद $name! आपके सभी बुनियादी विवरण सफलतापूर्वक दर्ज हो गए हैं।',
          'phonetic': 'Thank you! All details saved.',
        };
      case 'en':
      default:
        return {
          'text': 'Thank you $name! All your basic details have been recorded.',
          'phonetic': 'Thank you! Details recorded.',
        };
    }
  }

  // =========================================================================
  // DASHBOARD PROMPTS & INTENT CONFIRMATIONS (All 5 Supported Languages)
  // =========================================================================

  Map<String, String> _getDashboardPrompt(String lang, String? userName) {
    final name = (userName != null && userName.trim().isNotEmpty)
        ? userName.trim().split(RegExp(r'\s+')).first
        : '';

    switch (lang) {
      case 'te':
        return {
          'text': name.isNotEmpty
              ? 'నమస్కారం $name! మీకు ఏ సహాయం కావాలి? మీరు స్క్రీనింగ్ ప్రారంభించండి, రిపోర్టులు లేదా ఆహార సలహాలు అని చెప్పవచ్చు.'
              : 'నమస్కారం! మీకు ఏ సహాయం కావాలి? మీరు స్క్రీనింగ్ ప్రారంభించండి, రిపోర్టులు లేదా ఆహార సలహాలు అని చెప్పవచ్చు.',
          'phonetic': 'Hello! How can I help you? You can say Start screening, Reports, or Food guidance.',
        };
      case 'ta':
        return {
          'text': name.isNotEmpty
              ? 'வணக்கம் $name! நான் உங்களுக்கு எப்படி உதவ முடியும்? நீங்கள் புற்றுநோய் பரிசோதனை, அறிக்கைகள் அல்லது உணவு வழிகாட்டல் என்று சொல்லலாம்.'
              : 'வணக்கம்! நான் உங்களுக்கு எப்படி உதவ முடியும்? நீங்கள் புற்றுநோய் பரிசோதனை, அறிக்கைகள் அல்லது உணவு வழிகாட்டல் என்று சொல்லலாம்.',
          'phonetic': 'Hello! How can I help you? You can say Start screening, Reports, or Food guidance.',
        };
      case 'kn':
        return {
          'text': name.isNotEmpty
              ? 'ನಮಸ್ಕಾರ $name! ನಾನು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಹುದು? ನೀವು ಕ್ಯಾನ್ಸರ್ ಸ್ಕ್ರೀನಿಂಗ್, ವರದಿಗಳು ಅಥವಾ ಆಹಾರ ಮಾರ್ಗದರ್ಶನ ಎಂದು ಹೇಳಬಹುದು.'
              : 'ನಮಸ್ಕಾರ! ನಾನು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಹುದು? ನೀವು ಕ್ಯಾನ್ಸರ್ ಸ್ಕ್ರೀನಿಂಗ್, ವರದಿಗಳು ಅಥವಾ ಆಹಾರ ಮಾರ್ಗದರ್ಶನ ಎಂದು ಹೇಳಬಹುದು.',
          'phonetic': 'Hello! How can I help you? You can say Start screening, Reports, or Food guidance.',
        };
      case 'hi':
        return {
          'text': name.isNotEmpty
              ? 'नमस्ते $name! मैं आपकी क्या सहायता कर सकता हूँ? आप कैंसर स्क्रीनिंग शुरू करें, रिपोर्ट्स या आहार मार्गदर्शन कह सकते हैं।'
              : 'नमस्ते! मैं आपकी क्या सहायता कर सकता हूँ? आप कैंसर स्क्रीनिंग शुरू करें, रिपोर्ट्स या आहार मार्गदर्शन कह सकते हैं।',
          'phonetic': 'Hello! How can I help you? You can say Start screening, Reports, or Food guidance.',
        };
      case 'en':
      default:
        return {
          'text': name.isNotEmpty
              ? 'Hello $name! How can I help you today? You can say Start Cancer Screening, View Reports, or Food Guidance.'
              : 'Hello! How can I help you today? You can say Start Cancer Screening, View Reports, or Food Guidance.',
          'phonetic': 'How can I help you today?',
        };
    }
  }

  Map<String, String> _getIntentConfirmation(String lang, ConversationalIntent intent) {
    switch (intent) {
      case ConversationalIntent.startScreening:
        switch (lang) {
          case 'te':
            return {'text': 'సరే, క్యాన్సర్ స్క్రీనింగ్ ప్రారంభిస్తున్నాను.', 'phonetic': 'Starting cancer screening.'};
          case 'ta':
            return {'text': 'சரி, புற்றுநோய் பரிசோதனை தொடங்கப்படுகிறது.', 'phonetic': 'Starting cancer screening.'};
          case 'kn':
            return {'text': 'ಸರಿ, ಕ್ಯಾನ್ಸರ್ ಸ್ಕ್ರೀನಿಂಗ್ ಪ್ರಾರಂಭಿಸಲಾಗುತ್ತಿದೆ.', 'phonetic': 'Starting cancer screening.'};
          case 'hi':
            return {'text': 'ठीक है, कैंसर स्क्रीनिंग शुरू की जा रही है।', 'phonetic': 'Starting cancer screening.'};
          case 'en':
          default:
            return {'text': 'Starting AI cancer screening now.', 'phonetic': 'Starting cancer screening.'};
        }

      case ConversationalIntent.viewReports:
        switch (lang) {
          case 'te':
            return {'text': 'సరే, మీ రిపోర్టులను తెరుస్తున్నాను.', 'phonetic': 'Opening reports.'};
          case 'ta':
            return {'text': 'சரி, உங்கள் அறிக்கைகள் திறக்கப்படுகின்றன.', 'phonetic': 'Opening reports.'};
          case 'kn':
            return {'text': 'ಸರಿ, ನಿಮ್ಮ ವರದಿಗಳನ್ನು ತೆರೆಯಲಾಗುತ್ತಿದೆ.', 'phonetic': 'Opening reports.'};
          case 'hi':
            return {'text': 'ठीक है, आपकी रिपोर्ट्स खोली जा रही हैं।', 'phonetic': 'Opening reports.'};
          case 'en':
          default:
            return {'text': 'Opening your screening reports.', 'phonetic': 'Opening reports.'};
        }

      case ConversationalIntent.foodGuidance:
        switch (lang) {
          case 'te':
            return {'text': 'సరే, ఆహార మరియు పోషకాహార మార్గదర్శకాలను చూపిస్తున్నాను.', 'phonetic': 'Opening food guidance.'};
          case 'ta':
            return {'text': 'சரி, உணவு மற்றும் ஊட்டச்சத்து வழிகாட்டல் காட்டப்படுகிறது.', 'phonetic': 'Opening food guidance.'};
          case 'kn':
            return {'text': 'ಸರಿ, ಆಹಾರ ಮತ್ತು ಪೋಷಕಾಂಶ ಮಾರ್ಗದರ್ಶನವನ್ನು ತೋರಿಸಲಾಗುತ್ತಿದೆ.', 'phonetic': 'Opening food guidance.'};
          case 'hi':
            return {'text': 'ठीक है, आहार और पोषण मार्गदर्शन दिखाया जा रहा है।', 'phonetic': 'Opening food guidance.'};
          case 'en':
          default:
            return {'text': 'Opening food and nutrition guidance.', 'phonetic': 'Opening food guidance.'};
        }

      case ConversationalIntent.screeningHistory:
        switch (lang) {
          case 'te':
            return {'text': 'సరే, మీ గత స్క్రీనింగ్ రికార్డులను చూపిస్తున్నాను.', 'phonetic': 'Opening history.'};
          case 'ta':
            return {'text': 'சரி, உங்கள் பரிசோதனை வரலாறு காட்டப்படுகிறது.', 'phonetic': 'Opening history.'};
          case 'kn':
            return {'text': 'ಸರಿ, ನಿಮ್ಮ ಸ್ಕ್ರೀನಿಂಗ್ ಇತಿಹಾಸವನ್ನು ತೋರಿಸಲಾಗುತ್ತಿದೆ.', 'phonetic': 'Opening history.'};
          case 'hi':
            return {'text': 'ठीक है, आपका स्क्रीनिंग इतिहास दिखाया जा रहा है।', 'phonetic': 'Opening history.'};
          case 'en':
          default:
            return {'text': 'Opening your screening history.', 'phonetic': 'Opening history.'};
        }

      case ConversationalIntent.continueNext:
        switch (lang) {
          case 'te':
            return {'text': 'సరే, ముందుకు కొనసాగుతున్నాము.', 'phonetic': 'Continuing.'};
          case 'ta':
            return {'text': 'சரி, தொடர்ந்து செல்கிறோம்.', 'phonetic': 'Continuing.'};
          case 'kn':
            return {'text': 'ಸರಿ, ಮುಂದುವರಿಯುತ್ತಿದ್ದೇವೆ.', 'phonetic': 'Continuing.'};
          case 'hi':
            return {'text': 'ठीक है, आगे बढ़ रहे हैं।', 'phonetic': 'Continuing.'};
          case 'en':
          default:
            return {'text': 'Continuing to the next step.', 'phonetic': 'Continuing.'};
        }

      case ConversationalIntent.changeLanguage:
        switch (lang) {
          case 'te':
            return {'text': 'సరే, భాష ఎంపిక తెరవబడుతోంది.', 'phonetic': 'Opening language selection.'};
          case 'ta':
            return {'text': 'சரி, மொழி தேர்வு திறக்கப்படுகிறது.', 'phonetic': 'Opening language selection.'};
          case 'kn':
            return {'text': 'ಸರಿ, ಭಾಷೆ ಆಯ್ಕೆ ತೆರೆಯಲಾಗುತ್ತಿದೆ.', 'phonetic': 'Opening language selection.'};
          case 'hi':
            return {'text': 'ठीक है, भाषा चयन खोला जा रहा है।', 'phonetic': 'Opening language selection.'};
          case 'en':
          default:
            return {'text': 'Opening language selection.', 'phonetic': 'Opening language selection.'};
        }
    }
  }

  Map<String, String> _getDashboardRetry(String lang) {
    switch (lang) {
      case 'te':
        return {
          'text': 'దయచేసి స్క్రీనింగ్ ప్రారంభించండి, రిపోర్టులు లేదా ఆహార సలహాలు అని చెప్పండి.',
          'phonetic': 'Please say Start screening, Reports, or Food guidance.',
        };
      case 'ta':
        return {
          'text': 'தயவுசெய்து பரிசோதனை தொடங்கு, அறிக்கைகள் அல்லது உணவு வழிகாட்டல் என்று சொல்லுங்கள்.',
          'phonetic': 'Please say Start screening, Reports, or Food guidance.',
        };
      case 'kn':
        return {
          'text': 'ದಯವಿಟ್ಟು ಸ್ಕ್ರೀನಿಂಗ್ ಪ್ರಾರಂಭಿಸಿ, ವರದಿಗಳು ಅಥವಾ ಆಹಾರ ಮಾರ್ಗದರ್ಶನ ಎಂದು ಹೇಳಿ.',
          'phonetic': 'Please say Start screening, Reports, or Food guidance.',
        };
      case 'hi':
        return {
          'text': 'कृपया स्क्रीनिंग शुरू करें, रिपोर्ट्स या आहार मार्गदर्शन बोलें।',
          'phonetic': 'Please say Start screening, Reports, or Food guidance.',
        };
      case 'en':
      default:
        return {
          'text': 'Please say Start Screening, View Reports, or Food Guidance.',
          'phonetic': 'Please speak an action command.',
        };
    }
  }
}
