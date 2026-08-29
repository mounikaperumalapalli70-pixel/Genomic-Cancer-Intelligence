enum NotificationType {
  medicine,
  foodGuidance,
  healthyMeal,
  water,
  screeningCompleted,
  screeningReminder,
  healthReminder,
}

class NotificationItemModel {
  final String id;
  final String title; // ALWAYS in English
  final String message; // ALWAYS in English
  final String time;
  final NotificationType type;
  final bool isUpcoming;
  final bool isRead;
  final DateTime? scheduledDateTime;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isUpcoming = true,
    this.isRead = false,
    this.scheduledDateTime,
  });

  NotificationItemModel copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    NotificationType? type,
    bool? isUpcoming,
    bool? isRead,
    DateTime? scheduledDateTime,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      type: type ?? this.type,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      isRead: isRead ?? this.isRead,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
    );
  }

  /// Returns a localized time greeting (Morning, Afternoon, Evening, Night) personalized with user's first name.
  static Map<String, String> getPersonalizedTimeGreeting({
    required String languageCode,
    String? userName,
    int? hour,
  }) {
    final h = hour ?? DateTime.now().hour;
    final trimmed = userName?.trim();
    final firstName = (trimmed != null && trimmed.isNotEmpty)
        ? trimmed.split(RegExp(r'\s+')).first
        : '';
    final hasName = firstName.isNotEmpty;

    // Time buckets:
    // 05:00 - 11:59: Morning
    // 12:00 - 16:59: Afternoon
    // 17:00 - 20:59: Evening
    // 21:00 - 04:59: Night
    final isMorning = h >= 5 && h < 12;
    final isAfternoon = h >= 12 && h < 17;
    final isEvening = h >= 17 && h < 21;

    switch (languageCode.toLowerCase()) {
      case 'te':
        if (isMorning) {
          return {
            'text': hasName ? 'శుభోదయం, $firstName.' : 'శుభోదయం.',
            'phonetic': hasName ? 'Shubhodhayam, $firstName.' : 'Shubhodhayam.',
          };
        } else if (isAfternoon) {
          return {
            'text': hasName ? 'శుభ మధ్యాహ్నం, $firstName.' : 'శుభ మధ్యాహ్నం.',
            'phonetic': hasName ? 'Shubha madhyahnam, $firstName.' : 'Shubha madhyahnam.',
          };
        } else if (isEvening) {
          return {
            'text': hasName ? 'శుభ సాయంత్రం, $firstName.' : 'శుభ సాయంత్రం.',
            'phonetic': hasName ? 'Shubha sayantram, $firstName.' : 'Shubha sayantram.',
          };
        } else {
          return {
            'text': hasName ? 'శుభరాత్రి, $firstName.' : 'శుభరాత్రి.',
            'phonetic': hasName ? 'Shubharathri, $firstName.' : 'Shubharathri.',
          };
        }

      case 'ta':
        if (isMorning) {
          return {
            'text': hasName ? 'காலை வணக்கம், $firstName.' : 'காலை வணக்கம்.',
            'phonetic': hasName ? 'Kaalai vanakkam, $firstName.' : 'Kaalai vanakkam.',
          };
        } else if (isAfternoon) {
          return {
            'text': hasName ? 'மதிய வணக்கம், $firstName.' : 'மதிய வணக்கம்.',
            'phonetic': hasName ? 'Madhiya vanakkam, $firstName.' : 'Madhiya vanakkam.',
          };
        } else if (isEvening) {
          return {
            'text': hasName ? 'மாலை வணக்கம், $firstName.' : 'மாலை வணக்கம்.',
            'phonetic': hasName ? 'Maalai vanakkam, $firstName.' : 'Maalai vanakkam.',
          };
        } else {
          return {
            'text': hasName ? 'இனிய இரவு, $firstName.' : 'இனிய இரவு.',
            'phonetic': hasName ? 'Iniya iravu, $firstName.' : 'Iniya iravu.',
          };
        }

      case 'kn':
        if (isMorning) {
          return {
            'text': hasName ? 'ಶುಭೋದಯ, $firstName.' : 'ಶುಭೋದಯ.',
            'phonetic': hasName ? 'Shubhodaya, $firstName.' : 'Shubhodaya.',
          };
        } else if (isAfternoon) {
          return {
            'text': hasName ? 'ಶುಭ ಮಧ್ಯಾಹ್ನ, $firstName.' : 'ಶುಭ ಮಧ್ಯಾಹ್ನ.',
            'phonetic': hasName ? 'Shubha madhyahna, $firstName.' : 'Shubha madhyahna.',
          };
        } else if (isEvening) {
          return {
            'text': hasName ? 'ಶುಭ ಸಂಜೆ, $firstName.' : 'ಶುಭ ಸಂಜೆ.',
            'phonetic': hasName ? 'Shubha sanje, $firstName.' : 'Shubha sanje.',
          };
        } else {
          return {
            'text': hasName ? 'ಶುಭ ರಾತ್ರಿ, $firstName.' : 'ಶುಭ ರಾತ್ರಿ.',
            'phonetic': hasName ? 'Shubha rathri, $firstName.' : 'Shubha rathri.',
          };
        }

      case 'hi':
        if (isMorning) {
          return {
            'text': hasName ? 'शुभ प्रभात, $firstName।' : 'शुभ प्रभात।',
            'phonetic': hasName ? 'Shubh prabhat, $firstName.' : 'Shubh prabhat.',
          };
        } else if (isAfternoon) {
          return {
            'text': hasName ? 'शुभ दोपहर, $firstName।' : 'शुभ दोपहर।',
            'phonetic': hasName ? 'Shubh dopahar, $firstName.' : 'Shubh dopahar.',
          };
        } else if (isEvening) {
          return {
            'text': hasName ? 'शुभ संध्या, $firstName।' : 'शुभ संध्या।',
            'phonetic': hasName ? 'Shubh sandhya, $firstName.' : 'Shubh sandhya.',
          };
        } else {
          return {
            'text': hasName ? 'शुभ रात्रि, $firstName।' : 'शुभ रात्रि।',
            'phonetic': hasName ? 'Shubh ratri, $firstName.' : 'Shubh ratri.',
          };
        }

      case 'en':
      default:
        if (isMorning) {
          return {
            'text': hasName ? 'Good morning, $firstName.' : 'Good morning.',
            'phonetic': hasName ? 'Good morning, $firstName.' : 'Good morning.',
          };
        } else if (isAfternoon) {
          return {
            'text': hasName ? 'Good afternoon, $firstName.' : 'Good afternoon.',
            'phonetic': hasName ? 'Good afternoon, $firstName.' : 'Good afternoon.',
          };
        } else if (isEvening) {
          return {
            'text': hasName ? 'Good evening, $firstName.' : 'Good evening.',
            'phonetic': hasName ? 'Good evening, $firstName.' : 'Good evening.',
          };
        } else {
          return {
            'text': hasName ? 'Good night, $firstName.' : 'Good night.',
            'phonetic': hasName ? 'Good night, $firstName.' : 'Good night.',
          };
        }
    }
  }

  /// Multilingual voice translations for spoken voice assistant with optional personalization
  static Map<String, String> getSpokenVoiceTranslations({
    required String languageCode,
    required NotificationType type,
    String? userName,
    int? hour,
  }) {
    final greeting = getPersonalizedTimeGreeting(
      languageCode: languageCode,
      userName: userName,
      hour: hour,
    );

    final rawSpoken = _getRawSpokenContent(
      languageCode: languageCode,
      type: type,
    );

    return {
      'text': '${greeting['text']} ${rawSpoken['text']}'.trim(),
      'phonetic': '${greeting['phonetic']} ${rawSpoken['phonetic']}'.trim(),
    };
  }

  static Map<String, String> _getRawSpokenContent({
    required String languageCode,
    required NotificationType type,
  }) {
    switch (type) {
      case NotificationType.medicine:
        switch (languageCode) {
          case 'te':
            return {
              'text': 'మీ మందు వేసుకునే సమయం వచ్చింది.',
              'phonetic': 'Mee mandu vesukune samayam vachindi',
            };
          case 'ta':
            return {
              'text': 'உங்கள் மருந்து எடுத்துக்கொள்ளும் நேரம் வந்துவிட்டது.',
              'phonetic': 'Ungal marunthu eduthukkollum neram vanthuvittathu',
            };
          case 'kn':
            return {
              'text': 'ನಿಮ್ಮ ಔಷಧಿಯನ್ನು ತೆಗೆದುಕೊಳ್ಳುವ ಸಮಯ ಬಂದಿದೆ.',
              'phonetic': 'Nimma aushadhiyannu tegedukolluva samaya bandide',
            };
          case 'hi':
            return {
              'text': 'आपकी दवा लेने का समय हो गया है।',
              'phonetic': 'Aapki dawa lene ka samay ho gaya hai',
            };
          default:
            return {
              'text': 'It is time to take your prescribed medicine.',
              'phonetic': "It's time to take your medicine.",
            };
        }
      case NotificationType.foodGuidance:
        switch (languageCode) {
          case 'te':
            return {
              'text': 'మీ వ్యక్తిగతీకరించిన ఆహార మార్గదర్శకత్వం సిద్ధంగా ఉంది.',
              'phonetic': 'Mee aahara maargadarshakatvam siddhamga vundi',
            };
          case 'ta':
            return {
              'text': 'உங்கள் தனிப்பயனாக்கப்பட்ட உணவு வழிகாட்டுதல் தயாராக உள்ளது.',
              'phonetic': 'Ungal unavu vazhikaattuthal thayaaraga ullathu',
            };
          case 'kn':
            return {
              'text': 'ನಿಮ್ಮ ವೈಯಕ್ತಿಕಗೊಳಿಸಿದ ಆಹಾರ ಮಾರ್ಗದರ್ಶನ ಸಿದ್ಧವಾಗಿದೆ.',
              'phonetic': 'Nimma aahara maargadarshana siddhavaagide',
            };
          case 'hi':
            return {
              'text': 'आपका व्यक्तिगत आहार मार्गदर्शन तैयार है।',
              'phonetic': 'Aapka aahar margadarshan taiyar hai',
            };
          default:
            return {
              'text': 'Your personalized food guidance is ready.',
              'phonetic': 'Your personalized food guidance is ready.',
            };
        }
      case NotificationType.healthyMeal:
        switch (languageCode) {
          case 'te':
            return {
              'text': 'మీ ఆరోగ్యకరమైన భోజన సమయం వచ్చింది.',
              'phonetic': 'Mee arogyakaramaina bhojana samayam vachindi',
            };
          case 'ta':
            return {
              'text': 'உங்கள் ஆரோக்கியமான உணவுக்கான நேரம் இது.',
              'phonetic': 'Ungal arokiyamaana unavukkaana neram ithu',
            };
          case 'kn':
            return {
              'text': 'ನಿಮ್ಮ ಆರೋಗ್ಯಕರ ಊಟದ ಸಮಯ ಬಂದಿದೆ.',
              'phonetic': 'Nimma arogyakara ootada samaya bandide',
            };
          case 'hi':
            return {
              'text': 'आपके स्वस्थ भोजन का समय हो गया है।',
              'phonetic': 'Aapke swasth bhojan ka samay ho gaya hai',
            };
          default:
            return {
              'text': "It's time for your healthy meal.",
              'phonetic': "It's time for your meal.",
            };
        }
      case NotificationType.water:
        switch (languageCode) {
          case 'te':
            return {
              'text': 'మంచి నీరు త్రాగాల్సిన సమయం వచ్చింది.',
              'phonetic': 'Manchi neeru traagaalsina samayam vachindi',
            };
          case 'ta':
            return {
              'text': 'தண்ணீர் குடிக்கும் நேரம் வந்துவிட்டது.',
              'phonetic': 'Thanneer kudikkum neram vanthuvittathu',
            };
          case 'kn':
            return {
              'text': 'ನೀರು ಕುಡಿಯುವ ಸಮಯ ಬಂದಿದೆ.',
              'phonetic': 'Neeru kudiyuva samaya bandide',
            };
          case 'hi':
            return {
              'text': 'पानी पीने का समय हो गया है।',
              'phonetic': 'Pani peene ka samay ho gaya hai',
            };
          default:
            return {
              'text': 'Time to drink water and stay hydrated.',
              'phonetic': 'Time to drink water.',
            };
        }
      case NotificationType.screeningReminder:
        switch (languageCode) {
          case 'te':
            return {
              'text': 'మీ షెడ్యూల్ చేసిన స్క్రీనింగ్ సమయం వచ్చింది.',
              'phonetic': 'Mee scheduled screening samayam vachindi',
            };
          case 'ta':
            return {
              'text': 'உங்கள் திட்டமிடப்பட்ட பரிசோதனைக்கான நேரம் இது.',
              'phonetic': 'Ungal parisothanaikkaana neram ithu',
            };
          case 'kn':
            return {
              'text': 'ನಿಮ್ಮ ನಿಗದಿತ ಸ್ಕ್ರೀನಿಂಗ್ ಸಮಯ ಬಂದಿದೆ.',
              'phonetic': 'Nimma nigadhitha screening samaya bandide',
            };
          case 'hi':
            return {
              'text': 'आपकी निर्धारित स्क्रीनिंग का समय हो गया है।',
              'phonetic': 'Aapki screening ka samay ho gaya hai',
            };
          default:
            return {
              'text': 'It is time for your scheduled cancer screening.',
              'phonetic': 'It is time for your scheduled screening.',
            };
        }
      case NotificationType.healthReminder:
        switch (languageCode) {
          case 'te':
            return {
              'text': 'మీ వ్యక్తిగత ఆరోగ్య మార్గదర్శకాలను పాటించండి.',
              'phonetic': 'Mee arogya maargadarshakaalannu paatinchandi',
            };
          case 'ta':
            return {
              'text': 'உங்கள் தனிப்பயனாக்கப்பட்ட சுகாதார வழிகாட்டுதலைப் பின்பற்றுங்கள்.',
              'phonetic': 'Ungal sugaathaara vazhikaattuthalai pinpatrungal',
            };
          case 'kn':
            return {
              'text': 'ನಿಮ್ಮ ವೈಯಕ್ತಿಕಗೊಳಿಸಿದ ಆರೋಗ್ಯ ಮಾರ್ಗದರ್ಶನವನ್ನು ಅನುಸರಿಸಿ.',
              'phonetic': 'Nimma arogya maargadarshanavannu anusarisi',
            };
          case 'hi':
            return {
              'text': 'अपने व्यक्तिगत स्वास्थ्य मार्गदर्शन का पालन करें।',
              'phonetic': 'Apne swasthya margadarshan ka palan karein',
            };
          default:
            return {
              'text': 'Remember to follow your personalized health guidance.',
              'phonetic': 'Remember to follow your health guidance.',
            };
        }
      case NotificationType.screeningCompleted:
        switch (languageCode) {
          case 'te':
            return {
              'text': 'మీ జెనోమిక్ స్క్రీనింగ్ పూర్తయింది.',
              'phonetic': 'Mee genomic screening poorthayindi',
            };
          case 'ta':
            return {
              'text': 'உங்கள் மரபணு பரிசோதனை முடிந்தது.',
              'phonetic': 'Ungal marabanu parisothanai mudinthathu',
            };
          case 'kn':
            return {
              'text': 'ನಿಮ್ಮ ಜಿನೊಮಿಕ್ ಸ್ಕ್ರೀನಿಂಗ್ ಪೂರ್ಣಗೊಂಡಿದೆ.',
              'phonetic': 'Nimma genomic screening poornagondide',
            };
          case 'hi':
            return {
              'text': 'आपकी जीनोमिक स्क्रीनिंग पूरी हो चुकी है।',
              'phonetic': 'Aapki genomic screening poori ho chuki hai',
            };
          default:
            return {
              'text': 'Your genomic screening has been completed.',
              'phonetic': 'Your genomic screening has been completed.',
            };
        }
    }
  }
}
