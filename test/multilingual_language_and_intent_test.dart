import 'package:flutter_test/flutter_test.dart';
import 'package:genomic_cancer_intelligence/core/services/information_extraction_service.dart';
import 'package:genomic_cancer_intelligence/presentation/providers/onboarding_provider.dart';

void main() {
  group('Multilingual Language Extraction Tests (All 5 Languages)', () {
    final nlp = InformationExtractionService();

    test('Telugu language detection matches native, transliteration, and natural phrases', () {
      expect(nlp.extractLanguage('Telugu'), equals('te'));
      expect(nlp.extractLanguage('telugu'), equals('te'));
      expect(nlp.extractLanguage('తెలుగు'), equals('te'));
      expect(nlp.extractLanguage('I want Telugu'), equals('te'));
      expect(nlp.extractLanguage('Telugu language please'), equals('te'));
      expect(nlp.extractLanguage('నాకు తెలుగు కావాలి'), equals('te'));
      expect(nlp.extractLanguage('తెలుగులో మాట్లాడండి'), equals('te'));
      expect(nlp.extractLanguage('telugulo matladu'), equals('te'));
      expect(nlp.extractLanguage('తేలుగు'), equals('te'));
      expect(nlp.extractLanguage('తెలుగు భాష'), equals('te'));
    });

    test('Hindi language detection matches native, transliteration, and natural phrases', () {
      expect(nlp.extractLanguage('Hindi'), equals('hi'));
      expect(nlp.extractLanguage('hindi'), equals('hi'));
      expect(nlp.extractLanguage('हिंदी'), equals('hi'));
      expect(nlp.extractLanguage('हिन्दी'), equals('hi'));
      expect(nlp.extractLanguage('I want Hindi'), equals('hi'));
      expect(nlp.extractLanguage('मुझे हिंदी चाहिए'), equals('hi'));
      expect(nlp.extractLanguage('हिंदी में बात करो'), equals('hi'));
      expect(nlp.extractLanguage('hindi bhasha'), equals('hi'));
      expect(nlp.extractLanguage('हिंदी भाषा'), equals('hi'));
    });

    test('Tamil language detection matches native, transliteration, and natural phrases', () {
      expect(nlp.extractLanguage('Tamil'), equals('ta'));
      expect(nlp.extractLanguage('thamizh'), equals('ta'));
      expect(nlp.extractLanguage('tamizh'), equals('ta'));
      expect(nlp.extractLanguage('தமிழ்'), equals('ta'));
      expect(nlp.extractLanguage('I want Tamil'), equals('ta'));
      expect(nlp.extractLanguage('எனக்கு தமிழ் வேண்டும்'), equals('ta'));
      expect(nlp.extractLanguage('தமிழில் பேசுங்கள்'), equals('ta'));
      expect(nlp.extractLanguage('தமிழ் மொழி'), equals('ta'));
    });

    test('Kannada language detection matches native, transliteration, and natural phrases', () {
      expect(nlp.extractLanguage('Kannada'), equals('kn'));
      expect(nlp.extractLanguage('kannada'), equals('kn'));
      expect(nlp.extractLanguage('ಕನ್ನಡ'), equals('kn'));
      expect(nlp.extractLanguage('I want Kannada'), equals('kn'));
      expect(nlp.extractLanguage('ನನಗೆ ಕನ್ನಡ ಬೇಕು'), equals('kn'));
      expect(nlp.extractLanguage('ಕನ್ನಡದಲ್ಲಿ ಮಾತನಾಡಿ'), equals('kn'));
      expect(nlp.extractLanguage('ಕನ್ನಡ ಭಾಷೆ'), equals('kn'));
    });

    test('English language detection matches native, transliteration, and natural phrases', () {
      expect(nlp.extractLanguage('English'), equals('en'));
      expect(nlp.extractLanguage('english'), equals('en'));
      expect(nlp.extractLanguage('I want English'), equals('en'));
      expect(nlp.extractLanguage('Select English please'), equals('en'));
      expect(nlp.extractLanguage('ఇంగ్లీష్'), equals('en'));
      expect(nlp.extractLanguage('ஆங்கிலம்'), equals('en'));
      expect(nlp.extractLanguage('ಇಂಗ್ಲಿಷ್'), equals('en'));
      expect(nlp.extractLanguage('अंग्रेजी'), equals('en'));
      expect(nlp.extractLanguage('इंग्लिश'), equals('en'));
    });

    test('Returns null for unrelated phrases', () {
      expect(nlp.extractLanguage('Hello how are you'), isNull);
      expect(nlp.extractLanguage(''), isNull);
      expect(nlp.extractLanguage('12345'), isNull);
    });
  });

  group('Multilingual Conversational Intent Extraction Tests', () {
    final nlp = InformationExtractionService();

    test('Start Screening intent matches across English, Telugu, Hindi, Tamil, Kannada', () {
      // English
      expect(nlp.extractConversationalIntent('Start screening'), equals(ConversationalIntent.startScreening));
      expect(nlp.extractConversationalIntent('I want to start cancer screening'), equals(ConversationalIntent.startScreening));
      expect(nlp.extractConversationalIntent('Take test now'), equals(ConversationalIntent.startScreening));

      // Telugu
      expect(nlp.extractConversationalIntent('నాకు స్క్రీనింగ్ ప్రారంభించాలి'), equals(ConversationalIntent.startScreening));
      expect(nlp.extractConversationalIntent('క్యాన్సర్ స్క్రీనింగ్ ప్రారంభించండి'), equals(ConversationalIntent.startScreening));
      expect(nlp.extractConversationalIntent('స్క్రీనింగ్ స్టార్ట్ చేయి'), equals(ConversationalIntent.startScreening));

      // Hindi
      expect(nlp.extractConversationalIntent('स्क्रीनिंग शुरू करें'), equals(ConversationalIntent.startScreening));
      expect(nlp.extractConversationalIntent('कैंसर स्क्रीनिंग शुरू करो'), equals(ConversationalIntent.startScreening));
      expect(nlp.extractConversationalIntent('जांच शुरू करें'), equals(ConversationalIntent.startScreening));

      // Tamil
      expect(nlp.extractConversationalIntent('ஸ்கிரீனிங் தொடங்கவும்'), equals(ConversationalIntent.startScreening));
      expect(nlp.extractConversationalIntent('புற்றுநோய் பரிசோதனை தொடங்கு'), equals(ConversationalIntent.startScreening));

      // Kannada
      expect(nlp.extractConversationalIntent('ಸ್ಕ್ರೀನಿಂಗ್ ಪ್ರಾರಂಭಿಸಿ'), equals(ConversationalIntent.startScreening));
      expect(nlp.extractConversationalIntent('ಕ್ಯಾನ್ಸರ್ ಸ್ಕ್ರೀನಿಂಗ್ ಶುರು ಮಾಡಿ'), equals(ConversationalIntent.startScreening));
    });

    test('View Reports intent matches across 5 languages', () {
      expect(nlp.extractConversationalIntent('View reports'), equals(ConversationalIntent.viewReports));
      expect(nlp.extractConversationalIntent('నా రిపోర్ట్స్ చూపించు'), equals(ConversationalIntent.viewReports));
      expect(nlp.extractConversationalIntent('मेरी रिपोर्ट्स दिखाएं'), equals(ConversationalIntent.viewReports));
      expect(nlp.extractConversationalIntent('அறிக்கைகளைக் காட்டு'), equals(ConversationalIntent.viewReports));
      expect(nlp.extractConversationalIntent('ವರದಿಗಳನ್ನು ತೋರಿಸಿ'), equals(ConversationalIntent.viewReports));
    });

    test('Food Guidance intent matches across 5 languages', () {
      expect(nlp.extractConversationalIntent('Food guidance'), equals(ConversationalIntent.foodGuidance));
      expect(nlp.extractConversationalIntent('ఆహార సలహాలు'), equals(ConversationalIntent.foodGuidance));
      expect(nlp.extractConversationalIntent('आहार मार्गदर्शन'), equals(ConversationalIntent.foodGuidance));
      expect(nlp.extractConversationalIntent('உணவு வழிகாட்டல்'), equals(ConversationalIntent.foodGuidance));
      expect(nlp.extractConversationalIntent('ಆಹಾರ ಮಾರ್ಗದರ್ಶನ'), equals(ConversationalIntent.foodGuidance));
    });

    test('Screening History intent matches across 5 languages', () {
      expect(nlp.extractConversationalIntent('Screening history'), equals(ConversationalIntent.screeningHistory));
      expect(nlp.extractConversationalIntent('స్క్రీనింగ్ హిస్టరీ'), equals(ConversationalIntent.screeningHistory));
      expect(nlp.extractConversationalIntent('स्क्रीनिंग इतिहास'), equals(ConversationalIntent.screeningHistory));
      expect(nlp.extractConversationalIntent('பரிசோதனை வரலாறு'), equals(ConversationalIntent.screeningHistory));
      expect(nlp.extractConversationalIntent('ಸ್ಕ್ರೀನಿಂಗ್ ಇತಿಹಾಸ'), equals(ConversationalIntent.screeningHistory));
    });
  });

  group('OnboardingProvider Single Source of Truth for Language', () {
    test('Language changes correctly update selectedLanguage and profile', () {
      final provider = OnboardingProvider();
      expect(provider.selectedLanguageCode, equals('en'));
      expect(provider.selectedLanguage.name, equals('English'));

      // Select Telugu
      provider.selectLanguage('te');
      expect(provider.selectedLanguageCode, equals('te'));
      expect(provider.selectedLanguage.name, equals('Telugu'));
      expect(provider.selectedLanguage.nativeName, equals('తెలుగు'));
      expect(provider.profile.languageCode, equals('te'));

      // Select Hindi
      provider.selectLanguage('hi');
      expect(provider.selectedLanguageCode, equals('hi'));
      expect(provider.selectedLanguage.name, equals('Hindi'));
      expect(provider.selectedLanguage.nativeName, equals('हिंदी'));
      expect(provider.profile.languageCode, equals('hi'));

      // Select Tamil
      provider.selectLanguage('ta');
      expect(provider.selectedLanguageCode, equals('ta'));
      expect(provider.selectedLanguage.name, equals('Tamil'));
      expect(provider.selectedLanguage.nativeName, equals('தமிழ்'));
      expect(provider.profile.languageCode, equals('ta'));

      // Select Kannada
      provider.selectLanguage('kn');
      expect(provider.selectedLanguageCode, equals('kn'));
      expect(provider.selectedLanguage.name, equals('Kannada'));
      expect(provider.selectedLanguage.nativeName, equals('ಕನ್ನಡ'));
      expect(provider.profile.languageCode, equals('kn'));
    });
  });
}
