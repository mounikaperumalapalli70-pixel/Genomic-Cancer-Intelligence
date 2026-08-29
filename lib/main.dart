import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'presentation/providers/onboarding_provider.dart';
import 'presentation/providers/screening_provider.dart';
import 'presentation/screens/01_splash/splash_screen.dart';
import 'presentation/screens/02_language/language_selection_screen.dart';
import 'presentation/screens/03_gender/gender_selection_screen.dart';
import 'presentation/screens/04_basic_info/basic_info_screen.dart';
import 'presentation/screens/05_how_it_works/how_it_works_screen.dart';
import 'presentation/screens/06_dashboard/dashboard_screen.dart';
import 'presentation/screens/07_screening/cancer_screening_screen.dart';
import 'presentation/screens/08_upload/genomic_upload_screen.dart';
import 'presentation/screens/08_upload/medical_image_upload_screen.dart';
import 'presentation/screens/09_analysis/ai_analysis_screen.dart';
import 'presentation/screens/10_result/high_risk_result_screen.dart';
import 'presentation/screens/11_result/no_high_risk_result_screen.dart';
import 'presentation/screens/12_reports/reports_screen.dart';
import 'presentation/screens/13_history/screening_history_screen.dart';
import 'presentation/screens/14_notifications/notifications_screen.dart';
import 'presentation/screens/15_food_guidance/food_guidance_screen.dart';
import 'presentation/screens/16_voice_assistant/voice_assistant_screen.dart';

import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Notifications and Timezone configuration
  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  // Set immersive status bar styling for futuristic dark look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF060A19),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const GenomicCancerIntelligenceApp());
}

class GenomicCancerIntelligenceApp extends StatelessWidget {
  const GenomicCancerIntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => ScreeningProvider()),
      ],
      child: MaterialApp(
        title: 'Genomic Cancer Intelligence',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          // Screens 01 to 06
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.languageSelection: (context) => const LanguageSelectionScreen(),
          AppRoutes.genderSelection: (context) => const GenderSelectionScreen(),
          AppRoutes.basicInfo: (context) => const BasicInfoScreen(),
          AppRoutes.howItWorks: (context) => const HowItWorksScreen(),
          AppRoutes.dashboard: (context) => const DashboardScreen(),

          // Screens 07 to 16
          AppRoutes.cancerScreening: (context) => const CancerScreeningScreen(),
          AppRoutes.genomicDataUpload: (context) => const GenomicUploadScreen(),
          AppRoutes.medicalImageUpload: (context) => const MedicalImageUploadScreen(),
          AppRoutes.aiAnalysis: (context) => const AIAnalysisScreen(),
          AppRoutes.highRiskResult: (context) => const HighRiskResultScreen(),
          AppRoutes.noHighRiskResult: (context) => const NoHighRiskResultScreen(),
          AppRoutes.reports: (context) => const ReportsScreen(),
          AppRoutes.screeningHistory: (context) => const ScreeningHistoryScreen(),
          AppRoutes.notifications: (context) => const NotificationsScreen(),
          AppRoutes.foodGuidance: (context) => const FoodGuidanceScreen(),
          AppRoutes.voiceAssistant: (context) => const VoiceAssistantScreen(),
        },
      ),
    );
  }
}
