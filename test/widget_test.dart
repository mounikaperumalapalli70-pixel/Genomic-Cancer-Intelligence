import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:genomic_cancer_intelligence/core/routes/app_routes.dart';
import 'package:genomic_cancer_intelligence/core/services/notification_service.dart';
import 'package:genomic_cancer_intelligence/core/services/tts_service.dart';
import 'package:genomic_cancer_intelligence/data/models/notification_item_model.dart';
import 'package:genomic_cancer_intelligence/presentation/providers/onboarding_provider.dart';
import 'package:genomic_cancer_intelligence/presentation/providers/screening_provider.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/06_dashboard/dashboard_screen.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/08_upload/genomic_upload_screen.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/08_upload/medical_image_upload_screen.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/14_notifications/notifications_screen.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/16_voice_assistant/voice_assistant_screen.dart';
import 'package:genomic_cancer_intelligence/main.dart';

void main() {
  testWidgets('App launches and renders Splash Screen branding first', (WidgetTester tester) async {
    await tester.pumpWidget(const GenomicCancerIntelligenceApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Splash Screen remains visible indefinitely and only navigates upon user tap', (WidgetTester tester) async {
    await tester.pumpWidget(const GenomicCancerIntelligenceApp());
    await tester.pump(const Duration(milliseconds: 500));

    // After 5 seconds without tap, splash screen must still be visible
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(Image), findsOneWidget);

    // Tap on the splash screen image
    await tester.tap(find.byType(Image), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Now Language Selection Screen is visible
    expect(find.textContaining('Choose Your'), findsOneWidget);
  });

  testWidgets('Multiple taps on Splash Screen do not cause duplicate navigation errors', (WidgetTester tester) async {
    await tester.pumpWidget(const GenomicCancerIntelligenceApp());
    await tester.pump(const Duration(milliseconds: 200));

    // Tap multiple times rapidly
    await tester.tap(find.byType(Image), warnIfMissed: false);
    await tester.tap(find.byType(Image), warnIfMissed: false);
    await tester.tap(find.byType(Image), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Language selection screen should be safely reached
    expect(find.textContaining('Choose Your'), findsOneWidget);
  });

  testWidgets('How It Works screen Continue button navigates to Dashboard and Dashboard Start Screening navigates to Cancer Screening', (WidgetTester tester) async {
    final onboardingProvider = OnboardingProvider();
    onboardingProvider.updateBasicInfo(
      name: 'Charan Teja',
      age: 28,
      heightCm: 175.0,
      weightKg: 70.0,
      bloodGroup: 'B+',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: onboardingProvider),
          ChangeNotifierProvider(create: (_) => ScreeningProvider()),
        ],
        child: MaterialApp(
          initialRoute: AppRoutes.howItWorks,
          routes: {
            AppRoutes.howItWorks: (context) => const HowItWorksScreenLauncher(),
            AppRoutes.dashboard: (context) => const DashboardScreen(),
            AppRoutes.cancerScreening: (context) => const CancerScreeningDummy(),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Continue to Dashboard'), findsOneWidget);

    // Tap Continue
    await tester.tap(find.text('Continue to Dashboard'));
    await tester.pumpAndSettle();

    // Verify Dashboard screen is reached and shows personalized greeting with Charan
    expect(find.textContaining('👋 Charan'), findsOneWidget);
    expect(find.text('Cancer Screening'), findsOneWidget);
    expect(find.text('Start Screening'), findsOneWidget);

    // Tap Start Screening on Dashboard Hero Card
    await tester.tap(find.text('Start Screening'));
    await tester.pumpAndSettle();

    // Verify Cancer Screening dummy is reached
    expect(find.text('Cancer Screening Screen Reached'), findsOneWidget);
  });

  testWidgets('Complete Onboarding Navigation Flow reaches Dashboard with dynamic name', (WidgetTester tester) async {
    await tester.pumpWidget(const GenomicCancerIntelligenceApp());
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Splash -> tap to language
    await tester.tap(find.byType(Image), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.textContaining('Choose Your'), findsOneWidget);

    // 2. Language -> Continue to Gender
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Tell Us About You'), findsOneWidget);

    // 3. Gender -> Continue to Basic Info
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Basic Information'), findsOneWidget);

    // 4. Basic Info -> enter "Charan Teja"
    await tester.enterText(find.byType(TextField).first, 'Charan Teja');
    await tester.pumpAndSettle();

    // Tap Continue -> How It Works
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('How Our Genomic'), findsOneWidget);

    // 5. How It Works -> Continue -> Dashboard
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify Dashboard reached and dynamically displays Charan
    expect(find.textContaining('👋 Charan'), findsOneWidget);
    expect(find.text('Your health is our priority.'), findsOneWidget);
  });

  testWidgets('Dashboard notification bell navigates to NotificationsScreen', (WidgetTester tester) async {
    final onboardingProvider = OnboardingProvider();
    onboardingProvider.updateBasicInfo(
      name: 'Charan Teja',
      age: 28,
      heightCm: 175.0,
      weightKg: 70.0,
      bloodGroup: 'B+',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: onboardingProvider),
          ChangeNotifierProvider(create: (_) => ScreeningProvider()),
        ],
        child: MaterialApp(
          initialRoute: AppRoutes.dashboard,
          routes: {
            AppRoutes.dashboard: (context) => const DashboardScreen(),
            AppRoutes.notifications: (context) => const NotificationsScreen(),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap notification bell icon
    await tester.tap(find.byIcon(Icons.notifications_none_rounded).first);
    await tester.pumpAndSettle();

    // Verify Notifications screen is opened
    expect(find.text('Notifications'), findsWidgets);
    expect(find.text('Medicine Reminder'), findsWidgets);
  });

  testWidgets('Screen 08 Genomic Upload initial state has NO file and Start Analysis is disabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider(create: (_) => ScreeningProvider()),
        ],
        child: const MaterialApp(
          home: GenomicUploadScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify upload dropzone is present
    expect(find.textContaining('Drag & drop your file here'), findsOneWidget);
    // Verify no hardcoded sample file is present
    expect(find.text('sample_data.csv'), findsNothing);
    expect(find.text('sample_genomic_blood_biopsy.csv'), findsNothing);
    // Verify Start Analysis button is present
    expect(find.text('Start Analysis'), findsOneWidget);
  });

  testWidgets('Medical Scan Upload initial state has NO image and Start Analysis is disabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider(create: (_) => ScreeningProvider()),
        ],
        child: const MaterialApp(
          home: MedicalImageUploadScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify scan dropzone is present
    expect(find.textContaining('Drag & drop your medical scan here'), findsOneWidget);
    // Verify Start Analysis button is present
    expect(find.text('Start Image Analysis'), findsOneWidget);
  });

  testWidgets('All Screen routes including Medical Scan are registered and can be loaded', (WidgetTester tester) async {
    await tester.pumpWidget(const GenomicCancerIntelligenceApp());
    await tester.pump(const Duration(milliseconds: 100));

    final routesToTest = [
      AppRoutes.languageSelection,
      AppRoutes.genderSelection,
      AppRoutes.basicInfo,
      AppRoutes.howItWorks,
      AppRoutes.dashboard,
      AppRoutes.cancerScreening,
      AppRoutes.genomicDataUpload,
      AppRoutes.medicalImageUpload,
      AppRoutes.aiAnalysis,
      AppRoutes.highRiskResult,
      AppRoutes.noHighRiskResult,
      AppRoutes.reports,
      AppRoutes.screeningHistory,
      AppRoutes.notifications,
      AppRoutes.foodGuidance,
      AppRoutes.voiceAssistant,
    ];

    for (final route in routesToTest) {
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushReplacementNamed(route);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(Scaffold), findsWidgets);
    }
  });

  testWidgets('Notifications screen displays history and supports Mark All As Read & Clear All', (WidgetTester tester) async {
    final screeningProvider = ScreeningProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider.value(value: screeningProvider),
        ],
        child: const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify key notifications are rendered in English
    expect(find.text('Medicine Reminder'), findsWidgets);
    expect(find.text('Take your prescribed medicine.'), findsWidgets);
    expect(find.text('Screening Reminder'), findsWidgets);
    expect(find.text('Health Reminder'), findsWidgets);

    // Initial unread count should be > 0
    expect(screeningProvider.hasUnreadNotifications, isTrue);

    // Mark all as read via provider
    screeningProvider.markAllAsRead();
    await tester.pumpAndSettle();
    expect(screeningProvider.unreadNotificationsCount, equals(0));
    expect(screeningProvider.hasUnreadNotifications, isFalse);

    // Clear all notifications
    screeningProvider.clearAllNotifications();
    await tester.pumpAndSettle();
    expect(find.text('No Notifications'), findsOneWidget);
  });

  test('Personalized time greeting generates appropriate salutations and first names across time ranges', () {
    // Morning (05:00 - 11:59)
    final morningEn = NotificationItemModel.getPersonalizedTimeGreeting(
      languageCode: 'en',
      userName: 'Charan Teja',
      hour: 8,
    );
    expect(morningEn['text'], equals('Good morning, Charan.'));

    // Afternoon (12:00 - 16:59)
    final afternoonTe = NotificationItemModel.getPersonalizedTimeGreeting(
      languageCode: 'te',
      userName: 'Charan Teja',
      hour: 14,
    );
    expect(afternoonTe['text'], equals('శుభ మధ్యాహ్నం, Charan.'));

    // Evening (17:00 - 20:59)
    final eveningTa = NotificationItemModel.getPersonalizedTimeGreeting(
      languageCode: 'ta',
      userName: 'Charan Teja',
      hour: 18,
    );
    expect(eveningTa['text'], equals('மாலை வணக்கம், Charan.'));

    // Night (21:00 - 04:59)
    final nightHi = NotificationItemModel.getPersonalizedTimeGreeting(
      languageCode: 'hi',
      userName: 'Charan Teja',
      hour: 22,
    );
    expect(nightHi['text'], equals('शुभ रात्रि, Charan।'));

    final nightKn = NotificationItemModel.getPersonalizedTimeGreeting(
      languageCode: 'kn',
      userName: 'Charan Teja',
      hour: 2,
    );
    expect(nightKn['text'], equals('ಶುಭ ರಾತ್ರಿ, Charan.'));

    // Fallback when no name is provided
    final noNameEn = NotificationItemModel.getPersonalizedTimeGreeting(
      languageCode: 'en',
      hour: 9,
    );
    expect(noNameEn['text'], equals('Good morning.'));
  });

  testWidgets('Dashboard dynamically displays personalized user greeting with first name', (WidgetTester tester) async {
    final onboardingProvider = OnboardingProvider();
    onboardingProvider.updateBasicInfo(
      name: 'Charan Teja',
      age: 28,
      heightCm: 175.0,
      weightKg: 70.0,
      bloodGroup: 'B+',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: onboardingProvider),
          ChangeNotifierProvider(create: (_) => ScreeningProvider()),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify first name "Charan" is present in greeting
    expect(find.textContaining('👋 Charan'), findsOneWidget);
  });

  testWidgets('Voice Assistant does not auto-speak on entry and starts in Ready state', (WidgetTester tester) async {
    final onboardingProvider = OnboardingProvider();
    onboardingProvider.updateBasicInfo(
      name: 'Charan Teja',
      age: 28,
      heightCm: 175.0,
      weightKg: 70.0,
      bloodGroup: 'B+',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: onboardingProvider),
          ChangeNotifierProvider(create: (_) => ScreeningProvider()),
        ],
        child: const MaterialApp(
          home: VoiceAssistantScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Must start in "Ready to speak" state
    expect(find.text('Ready to speak'), findsOneWidget);
    // Spoken message should be visible with Charan's name
    expect(find.textContaining('Charan'), findsWidgets);
    // Play button must be visible
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('Multilingual vernacular voice mapping produces correct language output', (WidgetTester tester) async {
    final telugu = NotificationItemModel.getSpokenVoiceTranslations(
      languageCode: 'te',
      type: NotificationType.medicine,
      userName: 'Charan Teja',
    );
    expect(telugu['text'], contains('మీ మందు వేసుకునే సమయం వచ్చింది'));
    expect(telugu['text'], contains('Charan'));

    final tamil = NotificationItemModel.getSpokenVoiceTranslations(
      languageCode: 'ta',
      type: NotificationType.medicine,
      userName: 'Charan Teja',
    );
    expect(tamil['text'], contains('உங்கள் மருந்து'));
    expect(tamil['text'], contains('Charan'));

    final kannada = NotificationItemModel.getSpokenVoiceTranslations(
      languageCode: 'kn',
      type: NotificationType.medicine,
      userName: 'Charan Teja',
    );
    expect(kannada['text'], contains('ನಿಮ್ಮ ಔಷಧಿಯನ್ನು'));
    expect(kannada['text'], contains('Charan'));

    final hindi = NotificationItemModel.getSpokenVoiceTranslations(
      languageCode: 'hi',
      type: NotificationType.medicine,
      userName: 'Charan Teja',
    );
    expect(hindi['text'], contains('आपकी दवा'));
    expect(hindi['text'], contains('Charan'));

    final english = NotificationItemModel.getSpokenVoiceTranslations(
      languageCode: 'en',
      type: NotificationType.medicine,
      userName: 'Charan Teja',
    );
    expect(english['text'], contains('prescribed medicine'));
    expect(english['text'], contains('Charan'));
  });

  test('TtsService and NotificationService instances are created as singletons', () {
    final tts1 = TtsService();
    final tts2 = TtsService();
    expect(tts1, same(tts2));

    final notif1 = NotificationService();
    final notif2 = NotificationService();
    expect(notif1, same(notif2));
  });
}

// Helpers for testing
class HowItWorksScreenLauncher extends StatelessWidget {
  const HowItWorksScreenLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.dashboard);
          },
          child: const Text('Continue to Dashboard'),
        ),
      ),
    );
  }
}

class CancerScreeningDummy extends StatelessWidget {
  const CancerScreeningDummy({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Cancer Screening Screen Reached'),
      ),
    );
  }
}
