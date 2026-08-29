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

  // Callbacks
  void Function(String message, String? phonetic)? onAiMessageUpdate;
  void Function(String status)? onStatusUpdate;
  void Function(String languageCode)? onLanguageSelected;
  void Function(Gender gender)? onGenderSelected;
  void Function(ExtractedBasicInfo info)? onBasicInfoUpdated;
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
    VoidCallback? onComplete,
  }) async {
    _isActive = true;
    _currentLanguageCode = languageCode;
    onAiMessageUpdate = onAiMessage;
    onStatusUpdate = onStatus;
    onLanguageSelected = onLanguage;
    onGenderSelected = onGender;
    onBasicInfoUpdated = onBasicInfo;
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
    }
  }

  /// Stop current active session
  Future<void> stopSession() async {
    _isActive = false;
    await _tts.stop();
    await _stt.stopListening();
  }

  // =========================================================================
  // LANGUAGE SELECTION FLOW
  // =========================================================================

  Future<void> _startLanguageSelectionFlow() async {
    final prompt = _getLanguagePrompt(_currentLanguageCode);
    _displayAiMessage(prompt['text']!, prompt['phonetic']);

    await _speakAndListen(
      text: prompt['text']!,
      languageCode: _currentLanguageCode,
      onSpeechResult: (recognized, isFinal) async {
        if (recognized.trim().isEmpty) return;

        final detectedLang = _nlp.extractLanguage(recognized);
        if (detectedLang != null) {
          _currentLanguageCode = detectedLang;
          onLanguageSelected?.call(detectedLang);

          final confirm = _getLanguageConfirm(detectedLang);
          _displayAiMessage(confirm['text']!, confirm['phonetic']);
          await _tts.speak(
            text: confirm['text']!,
            languageCode: detectedLang,
            onComplete: () {
              onFlowCompleted?.call();
            },
          );
        } else if (isFinal) {
          final retry = _getLanguageRetry(_currentLanguageCode);
          _displayAiMessage(retry['text']!, retry['phonetic']);
          await _speakAndListen(
            text: retry['text']!,
            languageCode: _currentLanguageCode,
            onSpeechResult: (r, fin) {
              final lang = _nlp.extractLanguage(r);
              if (lang != null) {
                _currentLanguageCode = lang;
                onLanguageSelected?.call(lang);
                onFlowCompleted?.call();
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
}
