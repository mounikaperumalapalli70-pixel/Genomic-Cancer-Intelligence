import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:genomic_cancer_intelligence/core/services/notification_service.dart';
import 'package:genomic_cancer_intelligence/core/services/tts_service.dart';
import 'package:genomic_cancer_intelligence/data/models/genomic_analysis_models.dart';
import 'package:genomic_cancer_intelligence/data/models/screening_record_model.dart';
import 'package:genomic_cancer_intelligence/presentation/providers/onboarding_provider.dart';
import 'package:genomic_cancer_intelligence/presentation/providers/screening_provider.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/06_dashboard/dashboard_screen.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/08_upload/genomic_upload_screen.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/08_upload/medical_image_upload_screen.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/10_result/high_risk_result_screen.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/10_result/medical_image_result_screen.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/14_notifications/notifications_screen.dart';
import 'package:genomic_cancer_intelligence/presentation/screens/16_voice_assistant/voice_assistant_screen.dart';
import 'package:genomic_cancer_intelligence/presentation/widgets/gradient_button.dart';
import 'package:genomic_cancer_intelligence/main.dart';

void main() {
  testWidgets('App launches and renders Splash Screen branding first', (WidgetTester tester) async {
    await tester.pumpWidget(const GenomicCancerIntelligenceApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Screen 08 Genomic Upload renders curated TCGA benchmark presets and enables on selection', (WidgetTester tester) async {
    final screeningProvider = ScreeningProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider.value(value: screeningProvider),
        ],
        child: const MaterialApp(
          home: GenomicUploadScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify benchmark presets and upload dropzone
    expect(find.textContaining('TCGA BENCHMARK SAMPLES'), findsOneWidget);
    expect(find.textContaining('Browse Expression File'), findsOneWidget);
    expect(find.text('Start AI Analysis'), findsOneWidget);

    // Initial state: Start AI Analysis is disabled when no file is selected
    final startBtn = tester.widget<GradientButton>(find.byType(GradientButton));
    expect(startBtn.onPressed, isNull);

    // Select curated Lung sample
    final lungSample = screeningProvider.curatedSamples.first;
    screeningProvider.selectCuratedSample(lungSample);
    await tester.pumpAndSettle();

    // Button should now be enabled
    final enabledBtn = tester.widget<GradientButton>(find.byType(GradientButton));
    expect(enabledBtn.onPressed, isNotNull);
  });

  testWidgets('Medical Scan Upload renders scan dropzone and enables on selection', (WidgetTester tester) async {
    final screeningProvider = ScreeningProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider.value(value: screeningProvider),
        ],
        child: const MaterialApp(
          home: MedicalImageUploadScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Browse Medical Scan'), findsOneWidget);
    expect(find.text('Start Image Analysis'), findsOneWidget);

    // Initial button state disabled
    final btn = tester.widget<GradientButton>(find.byType(GradientButton));
    expect(btn.onPressed, isNull);

    screeningProvider.setUploadedMedicalImage(name: 'chest_ct_scan.png', size: '2.5 MB');
    await tester.pumpAndSettle();

    final enabledBtn = tester.widget<GradientButton>(find.byType(GradientButton));
    expect(enabledBtn.onPressed, isNotNull);
  });

  testWidgets('High Risk Result Screen displays dynamic TCGA classification and XAI tabs', (WidgetTester tester) async {
    final screeningProvider = ScreeningProvider();
    screeningProvider.setActiveScreeningResult(
      ScreeningRecordModel(
        id: 'TEST-REC-01',
        title: 'Lung Adenocarcinoma Screening',
        timestamp: DateTime.now(),
        riskLevel: ScreeningRiskLevel.highRisk,
        likelyCancerType: 'lung adenocarcinoma',
        confidenceScore: 94.8,
        genomicResult: const GenomicPredictionResult(
          cancerType: 'lung adenocarcinoma',
          probability: 0.948,
          modelVersion: '1.0.0-tcga-pancan',
          modelName: 'TCGA Multiclass Genomic Cancer Classifier',
          topClasses: [
            ClassProbability(cancerType: 'lung adenocarcinoma', probability: 0.948),
            ClassProbability(cancerType: 'lung squamous cell carcinoma', probability: 0.032),
          ],
          classProbabilities: {'lung adenocarcinoma': 0.948},
          topContributingBiomarkers: [
            BiomarkerAttribution(
              gene: 'EGFR',
              expressionValue: 12.8,
              referenceMedian: 9.1,
              zScoreDeviation: 2.05,
              status: 'upregulated',
            ),
          ],
          inputSummary: InputSummary(
            totalGenesProvided: 25,
            selectedBiomarkersMatched: 25,
            totalModelFeatures: 2000,
            biomarkerCoveragePct: 100.0,
          ),
          disclaimer: 'FOR RESEARCH USE ONLY.',
        ),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider.value(value: screeningProvider),
        ],
        child: const MaterialApp(
          home: HighRiskResultScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('LUNG ADENOCARCINOMA'), findsWidgets);
    expect(find.textContaining('94.8%'), findsWidgets);
    expect(find.text('Biomarkers & XAI'), findsOneWidget);
    expect(find.text('Targeted Rx'), findsOneWidget);
    expect(find.text('Quantum ML'), findsOneWidget);
  });

  testWidgets('Medical Image Result Screen displays radiological findings, modality, and Grad-CAM', (WidgetTester tester) async {
    final screeningProvider = ScreeningProvider();
    screeningProvider.setActiveScreeningResult(
      ScreeningRecordModel(
        id: 'TEST-SCAN-01',
        title: 'Pulmonary CT Scan Analysis',
        timestamp: DateTime.now(),
        riskLevel: ScreeningRiskLevel.highRisk,
        likelyCancerType: 'Lung Parenchymal Nodule (Suspected Adenocarcinoma)',
        confidenceScore: 88.4,
        imageResult: const MedicalImageResult(
          filename: 'chest_ct_scan.png',
          scanModality: 'Pulmonary CT Scan',
          primaryFinding: 'Lung Parenchymal Nodule (Suspected Adenocarcinoma)',
          confidenceScore: 0.884,
          confidencePct: 88.4,
          riskTier: 'High Suspicion',
          lesionDescription: 'Hyperdense focal opacity in right upper lobe with irregular speculated margins.',
          classProbabilities: {
            'Lung Adenocarcinoma Nodule': 0.884,
            'Benign Granuloma': 0.072,
          },
          disclaimer: 'INVESTIGATIONAL RESEARCH USE ONLY.',
        ),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider.value(value: screeningProvider),
        ],
        child: const MaterialApp(
          home: MedicalImageResultScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MEDICAL VISION REPORT'), findsOneWidget);
    expect(find.textContaining('LUNG PARENCHYMAL NODULE'), findsWidgets);
    expect(find.textContaining('88.4%'), findsWidgets);
    expect(find.text('Pulmonary CT Scan'), findsWidgets);
    expect(find.text('GRAD-CAM SALIENCY HEATMAP'), findsOneWidget);
    expect(find.text('IMAGING FINDINGS & MARGINS'), findsOneWidget);
    expect(find.text('CLINICAL SAFETY & REGULATORY NOTICE'), findsOneWidget);
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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('👋 Charan'), findsOneWidget);
    expect(find.text('Your health is our priority.'), findsOneWidget);
  });

  testWidgets('Notifications screen displays history and options', (WidgetTester tester) async {
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
    await tester.pumpAndSettle();

    expect(find.textContaining('Notifications'), findsWidgets);
    expect(find.byIcon(Icons.add_alarm_rounded), findsOneWidget);
  });

  testWidgets('Voice Assistant initializes in Ready state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider(create: (_) => ScreeningProvider()),
        ],
        child: const MaterialApp(
          home: VoiceAssistantScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Voice Care Assistant'), findsWidgets);
    expect(find.text('Ready to speak'), findsOneWidget);
  });

  testWidgets('Genomic Cancer Intelligence Report strictly rejects imaging findings and displays valid genomic class', (WidgetTester tester) async {
    final screeningProvider = ScreeningProvider();
    
    // Simulate an active medical image screening record
    screeningProvider.setActiveScreeningResult(
      ScreeningRecordModel(
        id: 'SCAN-TEST-01',
        title: 'General Medical Scan Analysis',
        timestamp: DateTime.now(),
        riskLevel: ScreeningRiskLevel.highRisk,
        likelyCancerType: null,
        confidenceScore: 84.2,
        imageResult: const MedicalImageResult(
          filename: 'scan.png',
          scanModality: 'General Medical Radiography',
          primaryFinding: 'Focal Tissue Density Abnormality Detected',
          confidenceScore: 0.842,
          confidencePct: 84.2,
          riskTier: 'High Suspicion',
          lesionDescription: 'Focal asymmetric attenuation.',
          classProbabilities: {'Malignant Neoplasm Suspicion': 0.842},
          disclaimer: 'INVESTIGATIONAL RESEARCH USE ONLY.',
        ),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider.value(value: screeningProvider),
        ],
        child: const MaterialApp(
          home: HighRiskResultScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Genomic Report strictly displays Genomic Cancer Intelligence Report title
    expect(find.text('Genomic Cancer Intelligence Report'), findsOneWidget);

    // Verify it NEVER displays the medical imaging finding as Predicted Cancer Type
    expect(find.textContaining('FOCAL TISSUE DENSITY ABNORMALITY DETECTED'), findsNothing);

    // Verify it displays a valid genomic model class label (e.g. LUNG ADENOCARCINOMA) and genomic confidence
    expect(find.textContaining('LUNG ADENOCARCINOMA'), findsWidgets);
    expect(find.textContaining('84.2%'), findsNothing);
    expect(find.textContaining('94.8%'), findsWidgets);
  });

  testWidgets('TtsService and NotificationService singletons instantiate properly', (WidgetTester tester) async {
    final tts1 = TtsService();
    final tts2 = TtsService();
    expect(identical(tts1, tts2), isTrue);

    final notif1 = NotificationService();
    final notif2 = NotificationService();
    expect(identical(notif1, notif2), isTrue);
  });

  testWidgets('Treatment & Medicine Intelligence tab renders cancer location, molecular mechanisms, and evidence sources', (WidgetTester tester) async {
    final screeningProvider = ScreeningProvider();

    // Provide pre-built TreatmentIntelligence
    final sampleTreatment = TreatmentIntelligence(
      cancerType: 'lung adenocarcinoma',
      diseaseName: 'Lung Adenocarcinoma (NSCLC)',
      cancerSite: 'Bronchial & Pulmonary Alveolar Tissue / Lung',
      subtype: 'Non-Small Cell Lung Cancer (Adenocarcinoma Histology)',
      genomicDataLimitationNotice:
          'TCGA dataset reflects RNA-seq quantitative gene expression. Clinically actionable eligibility for targeted kinase inhibitors requires diagnostic DNA next-generation sequencing (NGS).',
      firstLineGuideline:
          'NCCN Guidelines (NSCLC v2.2024): Mandatory broad molecular panel testing for EGFR, ALK, KRAS G12C, ROS1, BRAF V600E, RET, METex14, ERBB2, and PD-L1 expression.',
      targetedTherapies: const [
        TargetedTherapy(
          drugName: 'Osimertinib (Tagrisso)',
          treatmentClass: '3rd-Generation Irreversible EGFR Tyrosine Kinase Inhibitor (TKI)',
          cancerType: 'lung adenocarcinoma',
          cancerSite: 'Bronchial & Pulmonary Alveolar Tissue / Lung',
          targetGene: 'EGFR',
          molecularTarget: 'Epidermal Growth Factor Receptor (EGFR / ErbB-1 / HER1)',
          targetBiologicalFunction: 'Transmembrane receptor tyrosine kinase activating Ras-Raf-MEK-ERK and PI3K-Akt pathways.',
          howItWorks: 'Covalently binds cysteine 797 (C797) in the ATP-binding pocket of mutated EGFR kinase domain, shutting down kinase auto-phosphorylation.',
          whyRelevant: 'Preferred first-line standard for EGFR-mutated advanced NSCLC (Exon 19 del / L858R).',
          requiredGenomicAlteration: 'Sensitizing EGFR Exon 19 In-Frame Deletion or Exon 21 L858R Substitution.',
          fdaStatus: 'FDA Approved',
          nccnEvidenceTier: 'NCCN Category 1',
          evidenceSource: 'NCCN Guidelines NSCLC v2.2024; Soria JC et al., FLAURA Trial, N Engl J Med 2018.',
          clinicalNotes: 'Demonstrated statistically significant overall survival advantage.',
          sampleMatch: true,
          biomarkerStatus: 'Gene Expression: Upregulated (+2.45 Z-Score)',
          alterationClassification: 'Gene-Expression Finding (RNA-Seq)',
          eligibilityStatus: 'Expression finding detected; diagnostic DNA mutation testing required for clinical eligibility.',
        ),
      ],
      resistanceMechanisms: const ['EGFR C797S tertiary mutation'],
      clinicalTrialsCriteria: const ['NCT04077463 (MARIPOSA): Phase III Bispecific EGFR/MET Antibody (Amivantamab) + Lazertinib.'],
      nutritionGuidance: const {},
      disclaimer: 'FOR RESEARCH USE ONLY.',
    );

    screeningProvider.setActiveScreeningResult(
      ScreeningRecordModel(
        id: 'REC-TEST-02',
        title: 'Lung Adenocarcinoma Screening',
        timestamp: DateTime.now(),
        riskLevel: ScreeningRiskLevel.highRisk,
        likelyCancerType: 'lung adenocarcinoma',
        confidenceScore: 94.8,
        treatmentIntelligence: sampleTreatment,
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider.value(value: screeningProvider),
        ],
        child: const MaterialApp(
          home: HighRiskResultScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Targeted Rx / Treatment Intelligence Tab
    await tester.tap(find.text('Targeted Rx'));
    await tester.pumpAndSettle();

    // Verify Cancer & Anatomical Location section
    expect(find.text('CANCER & ANATOMICAL LOCATION'), findsOneWidget);
    expect(find.textContaining('Primary Site:'), findsWidgets);

    // Verify Data Distinction & Clinical Actionability notice
    expect(find.text('DATA DISTINCTION & CLINICAL ACTIONABILITY'), findsOneWidget);

    // Verify Evidence-Based Therapies
    expect(find.text('EVIDENCE-BASED TARGETED THERAPIES'), findsOneWidget);
    expect(find.textContaining('Osimertinib (Tagrisso)'), findsWidgets);
    expect(find.textContaining('Target:'), findsWidgets);
    expect(find.textContaining('How It Works:'), findsWidgets);
    expect(find.textContaining('Why Relevant to this Tumor/Biomarker:'), findsWidgets);
    expect(find.textContaining('Source / Trial:'), findsWidgets);

    // Verify Clinical Trials
    expect(find.text('ACTIVE CLINICAL TRIAL CRITERIA (ClinicalTrials.gov)'), findsOneWidget);
  });
}

