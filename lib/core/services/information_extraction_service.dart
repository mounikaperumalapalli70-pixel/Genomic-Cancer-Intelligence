import '../../data/models/user_profile_model.dart';

class ExtractedBasicInfo {
  final String? name;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final String? bloodGroup;

  const ExtractedBasicInfo({
    this.name,
    this.age,
    this.heightCm,
    this.weightKg,
    this.bloodGroup,
  });

  bool get isEmpty =>
      name == null &&
      age == null &&
      heightCm == null &&
      weightKg == null &&
      bloodGroup == null;

  bool get isNotEmpty => !isEmpty;

  ExtractedBasicInfo mergeWith(ExtractedBasicInfo other) {
    return ExtractedBasicInfo(
      name: other.name ?? name,
      age: other.age ?? age,
      heightCm: other.heightCm ?? heightCm,
      weightKg: other.weightKg ?? weightKg,
      bloodGroup: other.bloodGroup ?? bloodGroup,
    );
  }
}

enum ConversationalIntent {
  startScreening,
  viewReports,
  foodGuidance,
  screeningHistory,
  continueNext,
  changeLanguage,
}

class InformationExtractionService {
  static final InformationExtractionService _instance =
      InformationExtractionService._internal();
  factory InformationExtractionService() => _instance;
  InformationExtractionService._internal();

  // =========================================================================
  // 1. MULTILINGUAL LANGUAGE EXTRACTION (All 5 Supported Languages)
  // =========================================================================

  String? extractLanguage(String spokenText) {
    final lower = spokenText.toLowerCase().trim();
    if (lower.isEmpty) return null;

    // Normalize: remove punctuation and common conversational framing
    final normalized = lower
        .replaceAll(RegExp(r'[\.,!?;:\-_"״]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 1. Telugu (te) - Telugu script, English transliterations, cross-script
    if (normalized.contains('telugu') ||
        normalized.contains('తెలుగు') ||
        normalized.contains('theelugu') ||
        normalized.contains('telgu') ||
        normalized.contains('thelgu') ||
        normalized.contains('telugulo') ||
        normalized.contains('తెలుగులో') ||
        normalized.contains('తెలుగు కావాలి') ||
        normalized.contains('తెలుగు భాష') ||
        normalized.contains('తెలుగు ఎంచుకోండి') ||
        normalized.contains('తెలుగు మాట్లాడండి') ||
        normalized.contains('తేలుగు') ||
        normalized.contains('ತೆಲುಗು') ||
        normalized.contains('தெலுங்கு') ||
        normalized.contains('तेलुगु') ||
        normalized.contains('तेलगु')) {
      return 'te';
    }

    // 2. Hindi (hi) - Devanagari script, English transliterations, cross-script
    if (normalized.contains('hindi') ||
        normalized.contains('हिंदी') ||
        normalized.contains('हिन्दी') ||
        normalized.contains('hindee') ||
        normalized.contains('hindi me') ||
        normalized.contains('hindi bhasha') ||
        normalized.contains('hindi chahiye') ||
        normalized.contains('हिंदी भाषा') ||
        normalized.contains('मुझे हिंदी') ||
        normalized.contains('हिंदी में') ||
        normalized.contains('हिंदी चुनो') ||
        normalized.contains('हिन्दी भाषा') ||
        normalized.contains('హిందీ') ||
        normalized.contains('இந்தி') ||
        normalized.contains('ಹಿಂದಿ')) {
      return 'hi';
    }

    // 3. Tamil (ta) - Tamil script, English transliterations, cross-script
    if (normalized.contains('tamil') ||
        normalized.contains('தமிழ்') ||
        normalized.contains('thamizh') ||
        normalized.contains('tamizh') ||
        normalized.contains('thamil') ||
        normalized.contains('tamilil') ||
        normalized.contains('tamil bhasha') ||
        normalized.contains('tamil venum') ||
        normalized.contains('தமிழ் மொழி') ||
        normalized.contains('எனக்கு தமிழ்') ||
        normalized.contains('தமிழில்') ||
        normalized.contains('தமிழை') ||
        normalized.contains('தமீழ்') ||
        normalized.contains('తమిళం') ||
        normalized.contains('ತಮಿಳು') ||
        normalized.contains('तमिल') ||
        normalized.contains('तमिळ')) {
      return 'ta';
    }

    // 4. Kannada (kn) - Kannada script, English transliterations, cross-script
    if (normalized.contains('kannada') ||
        normalized.contains('ಕನ್ನಡ') ||
        normalized.contains('kanada') ||
        normalized.contains('kannad') ||
        normalized.contains('kannadadalli') ||
        normalized.contains('kannada bhasha') ||
        normalized.contains('kannada beku') ||
        normalized.contains('ಕನ್ನಡ ಭಾಷೆ') ||
        normalized.contains('ನನಗೆ ಕನ್ನಡ') ||
        normalized.contains('ಕನ್ನಡದಲ್ಲಿ') ||
        normalized.contains('ಕನ್ನಡ ಆಯ್ಕೆ') ||
        normalized.contains('ಕನ್ನಡ ಮಾತಾಡಿ') ||
        normalized.contains('కన్నడ') ||
        normalized.contains('கன்னடம்') ||
        normalized.contains('कन्नड़') ||
        normalized.contains('कन्नड')) {
      return 'kn';
    }

    // 5. English (en) - English words, native Indic scripts for English
    if (normalized.contains('english') ||
        normalized.contains('inglish') ||
        normalized.contains('angrezi') ||
        normalized.contains('angla') ||
        normalized.contains('ఇంగ్లీష్') ||
        normalized.contains('ఆంగ్లం') ||
        normalized.contains('ஆங்கிலம்') ||
        normalized.contains('இங்கிலீஷ்') ||
        normalized.contains('ಇಂಗ್ಲಿಷ್') ||
        normalized.contains('ಆಂಗ್ಲ') ||
        normalized.contains('अंग्रेजी') ||
        normalized.contains('इंग्लिश') ||
        normalized.contains('अंग्रेज़ी')) {
      return 'en';
    }

    return null;
  }

  // =========================================================================
  // 1B. CONVERSATIONAL INTENT EXTRACTION (Multilingual Across All 5 Languages)
  // =========================================================================

  ConversationalIntent? extractConversationalIntent(String spokenText) {
    final lower = spokenText.toLowerCase().trim();
    if (lower.isEmpty) return null;

    final normalized = lower
        .replaceAll(RegExp(r'[\.,!?;:\-_"״]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 1. Screening History (Must be checked before generic startScreening)
    if (normalized.contains('screening history') ||
        normalized.contains('my history') ||
        normalized.contains('past records') ||
        normalized.contains('past screenings') ||
        normalized.contains('history') ||
        // Telugu
        normalized.contains('స్క్రీనింగ్ హిస్టరీ') ||
        normalized.contains('గత రికార్డులు') ||
        normalized.contains('గత పరీక్షలు') ||
        normalized.contains('చరిత్ర') ||
        normalized.contains('హిస్టరీ') ||
        // Hindi
        normalized.contains('स्क्रीनिंग इतिहास') ||
        normalized.contains('पिछला रिकॉर्ड') ||
        normalized.contains('पुराने टेस्ट') ||
        normalized.contains('इतिहास') ||
        normalized.contains('हिस्ट्री') ||
        // Tamil
        normalized.contains('பரிசோதனை வரலாறு') ||
        normalized.contains('முந்தைய பதிவுகள்') ||
        normalized.contains('வரலாறு') ||
        normalized.contains('ஹிஸ்டரி') ||
        // Kannada
        normalized.contains('ಸ್ಕ್ರೀನಿಂಗ್ ಇತಿಹಾಸ') ||
        normalized.contains('ಹಿಂದಿನ ದಾಖಲೆಗಳು') ||
        normalized.contains('ಇತಿಹಾಸ') ||
        normalized.contains('ಹಿಸ್ಟರಿ')) {
      return ConversationalIntent.screeningHistory;
    }

    // 2. View Reports
    if (normalized.contains('view report') ||
        normalized.contains('view reports') ||
        normalized.contains('show report') ||
        normalized.contains('show reports') ||
        normalized.contains('my reports') ||
        normalized.contains('my report') ||
        normalized.contains('download report') ||
        normalized.contains('open report') ||
        normalized.contains('open reports') ||
        normalized.contains('see results') ||
        normalized.contains('reports') ||
        // Telugu
        normalized.contains('రిపోర్ట్స్') ||
        normalized.contains('రిపోర్టులు') ||
        normalized.contains('నా రిపోర్ట్స్') ||
        normalized.contains('రిపోర్టులు చూపించు') ||
        normalized.contains('ఫలితాలు చూపించు') ||
        normalized.contains('ఫలితాలు') ||
        // Hindi
        normalized.contains('रिपोर्ट्स') ||
        normalized.contains('मेरी रिपोर्ट्स') ||
        normalized.contains('रिपोर्ट दिखाएं') ||
        normalized.contains('रिपोर्ट दिखाओ') ||
        normalized.contains('परिणाम दिखाएं') ||
        normalized.contains('रिजल्ट') ||
        // Tamil
        normalized.contains('அறிக்கைகள்') ||
        normalized.contains('என் அறிக்கைகள்') ||
        normalized.contains('அறிக்கையைக் காட்டு') ||
        normalized.contains('அறிக்கைகளைக் காட்டு') ||
        normalized.contains('முடிவுகள்') ||
        // Kannada
        normalized.contains('ವರದಿಗಳು') ||
        normalized.contains('ನನ್ನ ವರದಿಗಳು') ||
        normalized.contains('ವರದಿ ತೋರಿಸಿ') ||
        normalized.contains('ವರದಿಗಳನ್ನು ತೋರಿಸಿ') ||
        normalized.contains('ಫಲಿತಾಂಶಗಳು')) {
      return ConversationalIntent.viewReports;
    }

    // 3. Food & Nutrition Guidance
    if (normalized.contains('food guidance') ||
        normalized.contains('diet plan') ||
        normalized.contains('nutrition') ||
        normalized.contains('food guide') ||
        normalized.contains('diet recommendations') ||
        normalized.contains('medicine advice') ||
        normalized.contains('diet') ||
        // Telugu
        normalized.contains('ఆహార సలహాలు') ||
        normalized.contains('డైట్ ప్లాన్') ||
        normalized.contains('పోషకాహారం') ||
        normalized.contains('మందుల సలహాలు') ||
        normalized.contains('ఫుడ్ గైడెన్స్') ||
        normalized.contains('ఆహారం') ||
        normalized.contains('డైట్') ||
        // Hindi
        normalized.contains('आहार मार्गदर्शन') ||
        normalized.contains('डाइट प्लान') ||
        normalized.contains('भोजन सलाह') ||
        normalized.contains('पोषण सलाह') ||
        normalized.contains('दवा सलाह') ||
        normalized.contains('फूड गाइडेंस') ||
        normalized.contains('डाइट') ||
        // Tamil
        normalized.contains('உணவு வழிகாட்டல்') ||
        normalized.contains('டயட் திட்டம்') ||
        normalized.contains('ஊட்டச்சத்து') ||
        normalized.contains('உணவு ஆலோசனை') ||
        normalized.contains('டயட்') ||
        // Kannada
        normalized.contains('ಆಹಾರ ಮಾರ್ಗದರ್ಶನ') ||
        normalized.contains('ಡಯಟ್ ಪ್ಲಾನ್') ||
        normalized.contains('ಪೋಷಕಾಂಶ') ||
        normalized.contains('ಊಟದ ಸಲಹೆ') ||
        normalized.contains('ಡಯಟ್')) {
      return ConversationalIntent.foodGuidance;
    }

    // 4. Continue / Next
    if (normalized.contains('continue') ||
        normalized.contains('next') ||
        normalized.contains('proceed') ||
        normalized.contains('go ahead') ||
        normalized.contains('next step') ||
        // Telugu
        normalized.contains('ముందుకు వెళ్లు') ||
        normalized.contains('ముందుకు కొనసాగించండి') ||
        normalized.contains('తర్వాత') ||
        normalized.contains('కంటిన్యూ') ||
        // Hindi
        normalized.contains('आगे बढ़ें') ||
        normalized.contains('अगला') ||
        normalized.contains('जारी रखें') ||
        normalized.contains('कंटिन्यू') ||
        // Tamil
        normalized.contains('தொடரவும்') ||
        normalized.contains('அடுத்து') ||
        normalized.contains('முன்னேறு') ||
        normalized.contains('கண்டினியூ') ||
        // Kannada
        normalized.contains('ಮುಂದುವರಿಯಿರಿ') ||
        normalized.contains('ಮುಂದೆ') ||
        normalized.contains('ಮುಂದಿನ ಹಂತ') ||
        normalized.contains('ಕಂಟಿನ್ಯೂ')) {
      return ConversationalIntent.continueNext;
    }

    // 5. Change Language
    if (normalized.contains('change language') ||
        normalized.contains('switch language') ||
        normalized.contains('select language') ||
        normalized.contains('భాష మార్చు') ||
        normalized.contains('భాష ఎంచుకో') ||
        normalized.contains('भाषा बदलो') ||
        normalized.contains('भाषा चुनें') ||
        normalized.contains('மொழி மாற்று') ||
        normalized.contains('மொழியை தேர்வு செய்') ||
        normalized.contains('ಭಾಷೆ ಬದಲಾಯಿಸಿ') ||
        normalized.contains('ಭಾಷೆ ಆಯ್ಕೆ ಮಾಡಿ')) {
      return ConversationalIntent.changeLanguage;
    }

    // 6. Start Screening / Cancer Screening
    if (normalized.contains('start screening') ||
        normalized.contains('begin screening') ||
        normalized.contains('cancer screening') ||
        normalized.contains('start test') ||
        normalized.contains('take test') ||
        normalized.contains('run screening') ||
        normalized.contains('screening start') ||
        normalized.contains('start analysis') ||
        // Telugu
        normalized.contains('స్క్రీనింగ్ ప్రారంభించాలి') ||
        normalized.contains('స్క్రీనింగ్ ప్రారంభించు') ||
        normalized.contains('స్క్రీనింగ్ ప్రారంభించండి') ||
        normalized.contains('స్క్రీనింగ్ స్టార్ట్') ||
        normalized.contains('క్యాన్సర్ స్క్రీనింగ్') ||
        normalized.contains('టెస్ట్ ప్రారంభించు') ||
        normalized.contains('స్క్రీనింగ్ చేయి') ||
        normalized.contains('స్క్రీనింగ్') ||
        // Hindi
        normalized.contains('स्क्रीनिंग शुरू करें') ||
        normalized.contains('स्क्रीनिंग शुरू करो') ||
        normalized.contains('स्क्रीनिंग शुरू') ||
        normalized.contains('कैंसर स्क्रीनिंग') ||
        normalized.contains('जांच शुरू करें') ||
        normalized.contains('जांच शुरू') ||
        normalized.contains('टेस्ट शुरू करें') ||
        normalized.contains('स्क्रीनिंग चालू') ||
        normalized.contains('स्क्रीनिंग') ||
        // Tamil
        normalized.contains('ஸ்கிரீனிங் தொடங்கவும்') ||
        normalized.contains('பரிசோதனை தொடங்கு') ||
        normalized.contains('புற்றுநோய் பரிசோதனை') ||
        normalized.contains('பரிசோதனை தொடங்க') ||
        normalized.contains('ஸ்கிரீனிங் ஆரம்பி') ||
        normalized.contains('பரிசோதனை') ||
        normalized.contains('ஸ்கிரீனிங்') ||
        // Kannada
        normalized.contains('ಸ್ಕ್ರೀನಿಂಗ್ ಪ್ರಾರಂಭಿಸಿ') ||
        normalized.contains('ಕ್ಯಾನ್ಸರ್ ಸ್ಕ್ರೀನಿಂಗ್') ||
        normalized.contains('ಪರೀಕ್ಷೆ ಪ್ರಾರಂಭಿಸಿ') ||
        normalized.contains('ಸ್ಕ್ರೀನಿಂಗ್ ಶುರು') ||
        normalized.contains('ಪರೀಕ್ಷೆ ಶುರು') ||
        normalized.contains('ಸ್ಕ್ರೀನಿಂಗ್')) {
      return ConversationalIntent.startScreening;
    }

    return null;
  }

  // =========================================================================
  // 2. GENDER EXTRACTION
  // =========================================================================

  Gender? extractGender(String spokenText) {
    final lower = spokenText.toLowerCase().trim();
    if (lower.isEmpty) return null;

    // Male patterns across 5 languages
    final maleKeywords = [
      'male',
      'man',
      'boy',
      'gentleman',
      'male please',
      'i am a man',
      'i am male',
      'ಪುರುಷ',
      'ಗಂಡು',
      'పురుషుడు',
      'మగ',
      'మగాడు',
      'ஆண்',
      'புருஷன்',
      'ஆண்கள்',
      'पुरुष',
      'लड़का',
      'आदमी',
      'मर्दाना',
    ];

    // Female patterns across 5 languages
    final femaleKeywords = [
      'female',
      'woman',
      'girl',
      'lady',
      'female please',
      'i am a woman',
      'i am female',
      'ಮಹಿಳೆ',
      'ಹೆಣ್ಣು',
      'స్త్రీ',
      'ఆడ',
      'మహిళ',
      'பெண்',
      'பெண்கள்',
      'மாதர்',
      'महिला',
      'स्त्री',
      'लड़की',
      'औरत',
    ];

    // Other patterns
    final otherKeywords = [
      'other',
      'others',
      'non-binary',
      'transgender',
      'third gender',
      'ఇతర',
      'மற்றவை',
      'ಇತರೆ',
      'अन्य',
      'दूसरा',
    ];

    for (final kw in maleKeywords) {
      if (lower.contains(kw)) return Gender.male;
    }

    for (final kw in femaleKeywords) {
      if (lower.contains(kw)) return Gender.female;
    }

    for (final kw in otherKeywords) {
      if (lower.contains(kw)) return Gender.other;
    }

    return null;
  }

  // =========================================================================
  // 3. BASIC INFO EXTRACTION (Single & Multi-detail)
  // =========================================================================

  ExtractedBasicInfo extractBasicInfo(
    String spokenText, {
    String? currentTargetField,
  }) {
    final text = spokenText.trim();
    if (text.isEmpty) return const ExtractedBasicInfo();

    final normalizedText = _normalizeIndicDigitsAndWords(text);

    String? extractedName = _extractName(normalizedText, currentTargetField);
    int? extractedAge = _extractAge(normalizedText, currentTargetField);
    double? extractedHeight = _extractHeight(normalizedText, currentTargetField);
    double? extractedWeight = _extractWeight(normalizedText, currentTargetField);
    String? extractedBloodGroup =
        _extractBloodGroup(normalizedText, currentTargetField);

    // If targeted at a specific field, try fallback direct extraction
    if (currentTargetField != null) {
      if (currentTargetField == 'name' && extractedName == null) {
        extractedName = _cleanDirectNameInput(text);
      } else if (currentTargetField == 'age' && extractedAge == null) {
        extractedAge = _extractFirstNumber(normalizedText)?.toInt();
      } else if (currentTargetField == 'height' && extractedHeight == null) {
        extractedHeight = _extractFirstNumber(normalizedText);
      } else if (currentTargetField == 'weight' && extractedWeight == null) {
        extractedWeight = _extractFirstNumber(normalizedText);
      }
    }

    return ExtractedBasicInfo(
      name: extractedName,
      age: extractedAge,
      heightCm: extractedHeight,
      weightKg: extractedWeight,
      bloodGroup: extractedBloodGroup,
    );
  }

  // =========================================================================
  // HELPER EXTRACTION METHODS
  // =========================================================================

  String? _extractName(String text, String? targetField) {
    // English phrases
    final enPatterns = [
      RegExp(r"(?:my name is|i am|i'm|call me|this is|myself)\s+([A-Za-z\s]+?)(?:,|and|\.|$|i am|i'm|my age|age|height|weight)", caseSensitive: false),
    ];

    for (final p in enPatterns) {
      final match = p.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final raw = match.group(1)!.trim();
        final cleaned = _filterOutKeywords(raw);
        if (cleaned.isNotEmpty && cleaned.length > 1) {
          return _capitalizeWords(cleaned);
        }
      }
    }

    // Telugu phrases: "నా పేరు చరణ్", "నేను చరణ్"
    final tePatterns = [
      RegExp(r"(?:నా పేరు|నా పేరండి|నేను)\s+([\u0C00-\u0C7F\w\s]+?)(?:,|మరియు|\.|$|నా వయసు|వయసు|ఎత్తు|బరువు)", caseSensitive: false),
    ];
    for (final p in tePatterns) {
      final match = p.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final raw = match.group(1)!.trim();
        if (raw.isNotEmpty && raw.length > 1) return raw;
      }
    }

    // Tamil phrases: "என் பெயர் சரண்", "நான் சரண்"
    final taPatterns = [
      RegExp(r"(?:என் பெயர்|நான்)\s+([\u0B80-\u0BFF\w\s]+?)(?:,|மற்றும்|\.|$|என் வயது|வயது|உயரம்|எடை)", caseSensitive: false),
    ];
    for (final p in taPatterns) {
      final match = p.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final raw = match.group(1)!.trim();
        if (raw.isNotEmpty && raw.length > 1) return raw;
      }
    }

    // Kannada phrases: "ನನ್ನ ಹೆಸರು ಚರಣ್", "ನಾನು ಚರಣ್"
    final knPatterns = [
      RegExp(r"(?:ನನ್ನ ಹೆಸರು|ನಾನು)\s+([\u0C80-\u0CFF\w\s]+?)(?:,|ಮತ್ತು|\.|$|ನನ್ನ ವಯಸ್ಸು|ವಯಸ್ಸು|ಎತ್ತರ|ತೂಕ)", caseSensitive: false),
    ];
    for (final p in knPatterns) {
      final match = p.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final raw = match.group(1)!.trim();
        if (raw.isNotEmpty && raw.length > 1) return raw;
      }
    }

    // Hindi phrases: "मेरा नाम चरण है", "मैं चरण हूँ"
    final hiPatterns = [
      RegExp(r"(?:मेरा नाम|मैं)\s+([\u0900-\u097F\w\s]+?)(?:\s+हूँ|\s+है|,|और|\.|$|मेरी उम्र|उम्र|लंबाई|वजन)", caseSensitive: false),
    ];
    for (final p in hiPatterns) {
      final match = p.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final raw = match.group(1)!.trim();
        if (raw.isNotEmpty && raw.length > 1) return raw;
      }
    }

    if (targetField == 'name') {
      return _cleanDirectNameInput(text);
    }

    return null;
  }

  String? _cleanDirectNameInput(String text) {
    // If user simply said their name (e.g., "Charan", "చరణ్", "Charan Teja")
    var cleaned = text
        .replaceAll(RegExp(r'^(hi|hello|hey|yeah|yes|no|my name is|i am|i’m|నా పేరు|నేను|என் பெயர்|நான்|ನನ್ನ ಹೆಸರು|ನಾನು|मेरा नाम|मैं)\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'[\.,!?]'), '')
        .trim();

    cleaned = _filterOutKeywords(cleaned);
    if (cleaned.length >= 2 && !cleaned.contains(RegExp(r'\d'))) {
      return _capitalizeWords(cleaned);
    }
    return null;
  }

  String _filterOutKeywords(String text) {
    return text
        .replaceAll(RegExp(r'\b(years old|years|age|height|weight|kilos|kg|cm|centimeters|blood group|positive|negative)\b', caseSensitive: false), '')
        .trim();
  }

  String _capitalizeWords(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  int? _extractAge(String text, String? targetField) {
    // English & generic patterns
    final patterns = [
      RegExp(r'(?:age is|age|i am|i’m|i am)\s+(\d{1,3})\s*(?:years old|years|yrs)?', caseSensitive: false),
      RegExp(r'(\d{1,3})\s*(?:years old|years of age|yrs old|years|సంవత్సరాలు|సంవత్సరాల|வயது|ವರ್ಷ|साल)', caseSensitive: false),
      RegExp(r'(?:వయసు|వయస్సు|வயது|ವಯಸ್ಸು|उम्र)\s*(?:is|is equal to|:)?\s*(\d{1,3})', caseSensitive: false),
    ];

    for (final p in patterns) {
      final match = p.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final val = int.tryParse(match.group(1)!);
        if (val != null && val > 0 && val < 130) return val;
      }
    }

    if (targetField == 'age') {
      final num = _extractFirstNumber(text);
      if (num != null && num > 0 && num < 130) return num.toInt();
    }

    return null;
  }

  double? _extractHeight(String text, String? targetField) {
    final patterns = [
      RegExp(r'(?:height is|height|tall|tall is|ఎత్తు|உயரம்|ಎತ್ತರ|लंबाई|कद)\s*(?:is|:)?\s*(\d{2,3}(?:\.\d+)?)\s*(?:cm|centimeters|centimeter|సెం\.మీ|செ\.மீ|ಸೆಂ\.ಮೀ|सेमी|सेंटीमीटर)?', caseSensitive: false),
      RegExp(r'(\d{2,3}(?:\.\d+)?)\s*(?:cm|centimeters|centimeter|సెం\.మీ|సెంటీమీటర్లు|செ\.மீ|சென்டிமீட்டர்|ಸೆಂ\.ಮೀ|ಸೆಂಟಿಮೀಟರ್|सेमी|सेंटीमीटर)', caseSensitive: false),
    ];

    for (final p in patterns) {
      final match = p.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final val = double.tryParse(match.group(1)!);
        if (val != null && val > 40 && val < 260) return val;
      }
    }

    if (targetField == 'height') {
      final num = _extractFirstNumber(text);
      if (num != null && num > 40 && num < 260) return num;
    }

    return null;
  }

  double? _extractWeight(String text, String? targetField) {
    final patterns = [
      RegExp(r'(?:weight is|weight|weigh|i weigh|బరువు|ఎடை|ತೂಕ|वजन)\s*(?:is|:)?\s*(\d{2,3}(?:\.\d+)?)\s*(?:kg|kilos|kilo|kilograms|kilogram|కేజీలు|కిలోలు|கிலோ|ಕೆಜಿ|ಕಿಲೋ|किलो|किलोग्राम)?', caseSensitive: false),
      RegExp(r'(\d{2,3}(?:\.\d+)?)\s*(?:kg|kilos|kilo|kilograms|kilogram|కేజీలు|కిలోలు|கிலோ|ಕೆಜಿ|ಕಿಲೋ|किलो|किलोग्राम)', caseSensitive: false),
    ];

    for (final p in patterns) {
      final match = p.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final val = double.tryParse(match.group(1)!);
        if (val != null && val > 15 && val < 300) return val;
      }
    }

    if (targetField == 'weight') {
      final num = _extractFirstNumber(text);
      if (num != null && num > 15 && num < 300) return num;
    }

    return null;
  }

  String? _extractBloodGroup(String text, String? targetField) {
    var lower = text.toLowerCase().trim();
    // Normalize common speech-to-text substitutions
    lower = lower
        .replaceAll(RegExp(r'[\.,!?;]'), ' ')
        .replaceAll(RegExp(r'\boh\b', caseSensitive: false), 'o')
        .replaceAll(RegExp(r'\bbee\b', caseSensitive: false), 'b')
        .replaceAll(RegExp(r'\bbe\s+(?=positive|negative|pos|neg|\+|-)', caseSensitive: false), 'b ')
        .replaceAll(RegExp(r'\ba\s+b\b', caseSensitive: false), 'ab')
        .replaceAll(RegExp(r'\bplus\b', caseSensitive: false), '+')
        .replaceAll(RegExp(r'\bminus\b', caseSensitive: false), '-')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Check AB first (order matters: AB before A/B)
    if (RegExp(r'\b(ab\s*\+|ab\s*positive|ab\s*pos|positive\s*ab|ab\s*పాజిటివ్|పాజిటివ్\s*ab|ab\s*பாசிட்டிவ்|ab\s*ಪಾಸಿಟಿವ್|ab\s*पॉजिटिव|एबी\s*पॉजिटिव|ab\s*पॉज़िटिव)\b', caseSensitive: false).hasMatch(lower)) {
      return 'AB+';
    }
    if (RegExp(r'\b(ab\s*-|ab\s*negative|ab\s*neg|negative\s*ab|ab\s*నెగటివ్|నెగటివ్\s*ab|ab\s*நெகடிவ்|ab\s*ನೆಗಟಿವ್|ab\s*नेगेटिव|एबी\s*नेगेटिव)\b', caseSensitive: false).hasMatch(lower)) {
      return 'AB-';
    }

    // Check A
    if (RegExp(r'\b(a\s*\+|a\s*positive|a\s*pos|positive\s*a|a\s*పాజిటివ్|పాజిటివ్\s*a|a\s*పాసిటివ్|a\s*பாசிட்டிவ்|a\s*ಪಾಸಿಟಿವ್|a\s*पॉजिटिव|ए\s*पॉजिटिव|a\s*पॉज़िटिव)\b', caseSensitive: false).hasMatch(lower)) {
      return 'A+';
    }
    if (RegExp(r'\b(a\s*-|a\s*negative|a\s*neg|negative\s*a|a\s*నెగటివ్|నెగటివ్\s*a|a\s*நெகடிவ்|a\s*ನೆಗಟಿವ್|a\s*नेगेटिव|ए\s*नेगेटिव)\b', caseSensitive: false).hasMatch(lower)) {
      return 'A-';
    }

    // Check B
    if (RegExp(r'\b(b\s*\+|b\s*positive|b\s*pos|positive\s*b|b\s*పాజిటివ్|పాజిటివ్\s*b|b\s*పాసిటివ్|b\s*பாசிட்டிவ்|b\s*ಪಾಸಿಟಿವ್|b\s*पॉजिटिव|बी\s*पॉजिटिव|b\s*पॉज़िटिव)\b', caseSensitive: false).hasMatch(lower)) {
      return 'B+';
    }
    if (RegExp(r'\b(b\s*-|b\s*negative|b\s*neg|negative\s*b|b\s*నెగటివ్|నెగటివ్\s*b|b\s*நெகடிவ்|b\s*ನೆಗಟಿವ್|b\s*नेगेटिव|बी\s*नेगेटिव)\b', caseSensitive: false).hasMatch(lower)) {
      return 'B-';
    }

    // Check O
    if (RegExp(r'\b(o\s*\+|o\s*positive|o\s*pos|positive\s*o|o\s*పాజిటివ్|పాజిటివ్\s*o|o\s*పాసిటివ్|ఓ\s*పాజిటివ్|ఓ\s*పాసిటివ్|o\s*பாசிட்டிவ்|o\s*பாசிடிவ்|ஓ\s*பாசிட்டிவ்|o\s*ಪಾಸಿಟಿವ್|ಓ\s*ಪಾಸಿಟಿವ್|o\s*पॉजिटिव|ओ\s*पॉजिटिव|पॉजिटिव\s*o|o\s*पॉज़िटिव|ओ\s*पॉज़िटिव)\b', caseSensitive: false).hasMatch(lower)) {
      return 'O+';
    }
    if (RegExp(r'\b(o\s*-|o\s*negative|o\s*neg|negative\s*o|o\s*నెగటివ్|నెగటివ్\s*o|ఓ\s*నెగటివ్|o\s*நெகடிவ்|ஓ\s*நெகடிவ்|o\s*ನೆಗಟಿವ್|ಓ\s*ನೆಗಟಿವ್|o\s*नेगेटिव|ओ\s*नेगेटिव|नेगेटिव\s*o)\b', caseSensitive: false).hasMatch(lower)) {
      return 'O-';
    }

    if (targetField == 'bloodGroup') {
      final cleaned = lower
          .replaceAll(RegExp(r'\b(my|is|my blood group is|blood group is|blood group|group|it is|it’s|it)\b'), '')
          .trim();

      if (cleaned == 'o+' || cleaned == 'o +' || cleaned == 'o positive' || cleaned == 'positive o' || cleaned == 'o pos') return 'O+';
      if (cleaned == 'o-' || cleaned == 'o -' || cleaned == 'o negative' || cleaned == 'negative o' || cleaned == 'o neg') return 'O-';
      if (cleaned == 'a+' || cleaned == 'a +' || cleaned == 'a positive' || cleaned == 'positive a' || cleaned == 'a pos') return 'A+';
      if (cleaned == 'a-' || cleaned == 'a -' || cleaned == 'a negative' || cleaned == 'negative a' || cleaned == 'a neg') return 'A-';
      if (cleaned == 'b+' || cleaned == 'b +' || cleaned == 'b positive' || cleaned == 'positive b' || cleaned == 'b pos') return 'B+';
      if (cleaned == 'b-' || cleaned == 'b -' || cleaned == 'b negative' || cleaned == 'negative b' || cleaned == 'b neg') return 'B-';
      if (cleaned == 'ab+' || cleaned == 'ab +' || cleaned == 'ab positive' || cleaned == 'positive ab' || cleaned == 'ab pos') return 'AB+';
      if (cleaned == 'ab-' || cleaned == 'ab -' || cleaned == 'ab negative' || cleaned == 'negative ab' || cleaned == 'ab neg') return 'AB-';

      if (lower.contains('positive') || lower.contains('పాజిటివ్') || lower.contains('పాసిటివ్') || lower.contains('பாசிட்டிவ்') || lower.contains('ಪಾಸಿಟಿವ್') || lower.contains('पॉजिटिव')) {
        if (lower.contains('ab')) return 'AB+';
        if (lower.contains('a')) return 'A+';
        if (lower.contains('b')) return 'B+';
        if (lower.contains('o') || lower.contains('ఓ') || lower.contains('ओ')) return 'O+';
      }
      if (lower.contains('negative') || lower.contains('నెగటివ్') || lower.contains('நெகடிவ்') || lower.contains('ನೆಗಟಿವ್') || lower.contains('नेगेटिव')) {
        if (lower.contains('ab')) return 'AB-';
        if (lower.contains('a')) return 'A-';
        if (lower.contains('b')) return 'B-';
        if (lower.contains('o') || lower.contains('ఓ') || lower.contains('ओ')) return 'O-';
      }
    }

    return null;
  }

  double? _extractFirstNumber(String text) {
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(0)!);
    }
    return null;
  }

  String _normalizeIndicDigitsAndWords(String text) {
    var result = text;

    // Convert Indic numerical digits (Telugu, Devanagari, Tamil, Kannada) to Arabic digits
    const indicDigits = {
      // Devanagari / Hindi
      '०': '0', '१': '1', '२': '2', '३': '3', '४': '4', '५': '5', '६': '6', '७': '7', '८': '8', '९': '9',
      // Telugu
      '౦': '0', '౧': '1', '౨': '2', '౩': '3', '౪': '4', '౫': '5', '౬': '6', '౭': '7', '౮': '8', '౯': '9',
      // Kannada
      '೦': '0', '೧': '1', '೨': '2', '೩': '3', '೪': '4', '೫': '5', '೬': '6', '೭': '7', '೮': '8', '೯': '9',
      // Tamil
      '௦': '0', '௧': '1', '௨': '2', '௩': '3', '௪': '4', '௫': '5', '௬': '6', '௭': '7', '௮': '8', '௯': '9',
    };

    indicDigits.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    return result;
  }
}
