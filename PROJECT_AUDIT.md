# 🔬 Comprehensive Project Audit: Genomic Cancer Intelligence

**Date of Audit:** September 17, 2026  
**Audited Repository:** `Genomic-Cancer-Intelligence`  
**Application Type:** Cross-Platform Medical-AI Mobile & Web Application (Flutter/Dart)  
**Deployment Target:** Vercel (Web) & Android / iOS / Desktop (Native)  

---

## 1. Executive Summary & Current Project Understanding

The **Genomic Cancer Intelligence** project is an ambitious, visually polished Flutter application designed as an early cancer detection and intelligent patient health companion. It combines a **futuristic cyber-medical dark UI** with neon accents, custom Canvas-drawn animations (DNA radar scanners, holographic bio-visuals, waveforms, and robot avatars), local device notifications, multi-lingual text-to-speech (TTS) & speech-to-text (STT) voice assistance across 5 languages (English, Telugu, Tamil, Kannada, Hindi), and cancer screening workflows.

### Core Discovery:
The existing codebase is an **exceptionally well-crafted frontend presentation and client-state simulation layer**, but it currently **lacks a real machine learning (ML) backend, real genomic/imaging data processing pipelines, database persistence, and API integration**. 

- **Frontend:** 16 complete screens with responsive layout, custom dark neon themes, and multilingual voice interaction.
- **Backend & API:** Currently nonexistent (all data is managed via in-memory Flutter `ChangeNotifier` state).
- **ML / AI Intelligence:** Simulated UI animations and static demo outputs (e.g., hardcoded 87.6% confidence Lung Cancer result).
- **Storage / Persistence:** Ephemeral RAM memory; refreshing or restarting resets all user inputs, medicines, and notifications.

---

## 2. Current Architecture Breakdown

```
                               CURRENT ARCHITECTURE OVERVIEW

┌────────────────────────────────────────────────────────────────────────────────────────┐
│                               FLUTTER CLIENT APPLICATION                               │
│                                                                                        │
│  ┌─────────────────────────┐  ┌───────────────────────────┐  ┌───────────────────────┐ │
│  │     PRESENTATION        │  │     STATE MANAGEMENT      │  │     CORE SERVICES     │ │
│  │  - 16 Screen Flows      │  │  - OnboardingProvider     │  │  - NotificationService│ │
│  │  - Dark Neon Theme      │  │  - ScreeningProvider      │  │  - VoiceAssistant     │ │
│  │  - Custom Painters      │  │    (All In-Memory State)  │  │  - TtsService         │ │
│  │  - Custom Widgets       │  │                           │  │  - SttService         │ │
│  │                         │  │                           │  │  - InfoExtraction(NLP)│ │
│  └─────────────────────────┘  └───────────────────────────┘  └───────────────────────┘ │
│                                             ▲                                          │
│                                             │ In-Memory Data Flow                      │
│                                             ▼                                          │
│                               ┌───────────────────────────┐                            │
│                               │        DATA MODELS        │                            │
│                               │  - UserProfileModel       │                            │
│                               │  - ScreeningRecordModel   │                            │
│                               │  - FoodGuidanceModel      │                            │
│                               │  - NotificationItemModel  │                            │
│                               │  - ReminderModel          │                            │
│                               └───────────────────────────┘                            │
└────────────────────────────────────────────────────────────────────────────────────────┘
                                              │
                      ┌───────────────────────┴───────────────────────┐
                      │                   LIMITATION                  │
                      │  [No Backend Server]  [No Real ML Pipeline]  │
                      │  [No Remote API]      [No Persistent Database]│
                      └───────────────────────────────────────────────┘
```

### 2.1 Frontend Architecture
- **Framework:** Flutter SDK `^3.12.2` (Dart 3.x), multi-platform support (Android, iOS, Web, macOS, Windows, Linux).
- **Directory Structure:** Clean layered architecture:
  - `lib/core/`: Constants (`app_colors.dart`, `app_gradients.dart`, `app_theme.dart`, `app_typography.dart`), routes (`app_routes.dart`), and hardware/audio services.
  - `lib/data/models/`: Strongly typed Dart data models (`user_profile_model.dart`, `screening_record_model.dart`, `food_guidance_model.dart`, `notification_item_model.dart`, `reminder_model.dart`, `user_medicine_model.dart`, `language_model.dart`).
  - `lib/presentation/`:
    - `providers/`: Provider-based state management (`OnboardingProvider`, `ScreeningProvider`).
    - `screens/`: 16 numbered modular screen folders (`01_splash` to `16_voice_assistant`).
    - `widgets/`: Reusable futuristic widgets (`glow_container.dart`, `gradient_button.dart`, `custom_app_bar.dart`, `custom_text_field.dart`, `holographic_visuals.dart`, `ai_voice_assistant_sheet.dart`).

### 2.2 Screen Directory & Workflow Map
| Screen ID & Name | File Path | Current Purpose |
|---|---|---|
| `01_splash` | `lib/presentation/screens/01_splash/splash_screen.dart` | Hero launch splash displaying `splash_screen.png` with touch-to-start. |
| `02_language` | `lib/presentation/screens/02_language/language_selection_screen.dart` | Selection of EN, TE, TA, KN, HI with voice assistant support. |
| `03_gender` | `lib/presentation/screens/03_gender/gender_selection_screen.dart` | Gender selection (Male, Female, Other) with voice triggers. |
| `04_basic_info` | `lib/presentation/screens/04_basic_info/basic_info_screen.dart` | Form capturing Name, Age, Height, Weight, Blood Group with Indic voice NLP. |
| `05_how_it_works` | `lib/presentation/screens/05_how_it_works/how_it_works_screen.dart` | 3-step educational overview of liquid biopsy genomic screening. |
| `06_dashboard` | `lib/presentation/screens/06_dashboard/dashboard_screen.dart` | Main hub with personalized time greetings, quick actions, and screening launcher. |
| `07_screening` | `lib/presentation/screens/07_screening/cancer_screening_screen.dart` | Screening modality selector: Genomic Data vs. Medical Image. |
| `08_upload` (Genomic) | `lib/presentation/screens/08_upload/genomic_upload_screen.dart` | File picker for CSV/TXT/XLSX/PDF genomic datasets. |
| `08_upload` (Image) | `lib/presentation/screens/08_upload/medical_image_upload_screen.dart` | File picker for JPG/PNG/DICOM medical scans. |
| `09_analysis` | `lib/presentation/screens/09_analysis/ai_analysis_screen.dart` | Animated radar sweep & 4-step progress animation (~5.5s timer). |
| `10_result` (High Risk) | `lib/presentation/screens/10_result/high_risk_result_screen.dart` | High Risk report card (Demo: Lung Cancer, 87.6% confidence score). |
| `11_result` (Clear) | `lib/presentation/screens/11_result/no_high_risk_result_screen.dart` | No Abnormality Detected report card with lifestyle tips. |
| `12_reports` | `lib/presentation/screens/12_reports/reports_screen.dart` | List of latest and historical screening records with mock PDF export. |
| `13_history` | `lib/presentation/screens/13_history/screening_history_screen.dart` | Timeline view of past screening records and risk classifications. |
| `14_notifications` | `lib/presentation/screens/14_notifications/notifications_screen.dart` | Central reminder and notification management with real device scheduling. |
| `15_food_guidance` | `lib/presentation/screens/15_food_guidance/food_guidance_screen.dart` | Oncology nutrition recommendations and user medicine scheduler. |
| `16_voice_assistant` | `lib/presentation/screens/16_voice_assistant/voice_assistant_screen.dart` | Fullscreen voice player for multilingual spoken health notifications. |

---

## 3. Deep-Dive Audit of Subsystems

### 3.1 Machine Learning Pipeline & Prediction Functionality
- **Current Model Status:** **No ML models are loaded or executed.**
- **Analysis Execution:** `AIAnalysisScreen` runs a Dart `Timer.periodic` that increments progress from 15% to 100% in 60ms increments (~5.1 seconds). Upon reaching 100%, an unconditional timer triggers navigation:
  ```dart
  _navigationTimer = Timer(const Duration(milliseconds: 1000), () {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.highRiskResult);
    }
  });
  ```
- **Inputs & Outputs:**
  - *Input:* Selected filename and byte size string (content is unread).
  - *Output:* Static `ScreeningRecordModel` instance defaulted to Lung Cancer with 87.6% confidence score.

### 3.2 Preprocessing & Feature Extraction
- **File Handling:** Uses `file_picker: ^12.0.0` to read filename and compute file size (`file.length()`). File bytes are not loaded into memory buffers or parsed into genomic/imaging tensors.
- **Natural Language Preprocessing:** `InformationExtractionService` implements sophisticated regular expressions to normalize Indic digits (Devanagari, Telugu, Kannada, Tamil) and extract patient demographic fields from transcribed speech utterances.

### 3.3 Backend, APIs, & Network Layer
- **HTTP Client:** Not installed (no `http` or `dio` packages in `pubspec.yaml`).
- **REST / GraphQL Endpoints:** Zero external or internal API integrations.
- **Database / Cache:** Zero database packages (`sqflite`, `hive`, `shared_preferences`, or `drift` are not configured). All state is kept in memory and reset on hot-restart or browser reload.

### 3.4 Audio, Speech & Notification Subsystems
- **Text-to-Speech:** `flutter_tts: ^4.2.5` configured with custom voice selection, rate pacing (0.45-0.48), and multilingual mappings (`te-IN`, `ta-IN`, `kn-IN`, `hi-IN`, `en-US`).
- **Speech-to-Text:** `speech_to_text: ^7.0.0` configured with locale matchers and sound level streams.
- **Local Notifications:** `flutter_local_notifications: ^22.3.0` + `timezone: ^0.11.1` + `flutter_timezone: ^5.1.0` supporting Android exact alarms (`exactAllowWhileIdle`) and repeating daily/weekly channels.

### 3.5 Deployment & Repository Infrastructure
- **Git Remote:** `https://github.com/mounikaperumalapalli70-pixel/Genomic-Cancer-Intelligence.git` (branch `main`).
- **Vercel Web Deployment:** Deployed from `build/web` to Vercel via Vercel CLI (Project ID `prj_WLpUUQuXhN8VNZ5szLtOqWUKZhUK`).
- **CI/CD:** No GitHub Actions workflow currently set up for automated testing or building.

---

## 4. Current Limitations, Gaps, and Issues

| # | Domain | Identified Gap / Problem | Impact |
|---|---|---|---|
| 1 | **ML / Inference** | No real genomic classification or medical vision model exists. Hardcoded timer routes to a static mock Lung Cancer result. | App cannot provide genuine diagnostic utility. |
| 2 | **Data Processing** | Uploaded CSV/VCF/FASTA/DICOM files are not parsed, validated, or tokenized. | Users can upload arbitrary files without validation. |
| 3 | **Backend & Architecture** | No backend microservice or serverless API to handle heavy genomic/imaging compute. | Heavy ML inference cannot run on low-power client browsers/devices without a backend. |
| 4 | **Data Persistence** | No local or remote database; user profile, reminders, screening history disappear on refresh. | Poor user retention and lost medical screening records. |
| 5 | **Multimodal AI** | No unified model bridging genomic biomarkers (SNVs, indels, gene expression) with medical scans (CT, X-ray, MRI, Histopathology). | Lacks the multimodal diagnostic power required for clinical cancer intelligence. |
| 6 | **Evidence-Based Oncology** | No connection to oncological knowledgebases (ClinVar, COSMIC, Open Targets, ChEMBL, PubMed) for treatment intelligence. | Cannot map detected mutations to approved targeted therapies or clinical trials. |
| 7 | **Explainable AI (XAI)** | No SHAP/LIME feature importance for genomics or Grad-CAM heatmaps for medical images. | Results lack clinical interpretability and physician confidence. |
| 8 | **Web TTS / STT Browser Limits** | Browser auto-play policies and missing Web Speech recognition engines in some browsers cause silent failures. | Degraded voice experience on certain web browsers. |

---

## 5. Target Upgrade Vision: Multimodal Cancer Intelligence Platform

The planned upgrade will evolve this project into a comprehensive **Multimodal Medical AI Platform**:

```
                          TARGET MULTIMODAL PLATFORM ARCHITECTURE

 ┌────────────────────────────────────────────────────────────────────────────────────────┐
 │                              FLUTTER FRONTEND APPLICATION                              │
 │  - Multimodal Upload Center (Genomic CSV/VCF + Medical Scans DICOM/PNG)                │
 │  - Real-time Inference Status & Streaming Progress WebSocket/REST                      │
 │  - Interactive Explainable AI Dashboard (SHAP Bar Charts, Grad-CAM Heatmaps)           │
 │  - Evidence-Based Targeted Therapy & Clinical Trials Recommender                       │
 │  - Multilingual AI Voice Companion & Smart Health Timeline                            │
 └───────────────────────────────────────────┬────────────────────────────────────────────┘
                                             │ Secure HTTPS / REST / WebSockets
                                             ▼
 ┌────────────────────────────────────────────────────────────────────────────────────────┐
 │                       PYTHON FASTAPI BACKEND (AI ENGINE & API)                         │
 │                                                                                        │
 │  ┌─────────────────────────┐  ┌─────────────────────────┐  ┌─────────────────────────┐ │
 │  │   GENOMIC AI PIPELINE   │  │    VISION AI PIPELINE   │  │   TREATMENT INTELLIGENCE│ │
 │  │ - Variant & Expression  │  │ - ResNet / ViT Scan     │  │ - Biomarker -> Drug map │ │
 │  │   Feature Extraction    │  │   Classification        │  │ - OpenTargets / ClinVar │ │
 │  │ - Multi-Cancer Classifier│ │ - Grad-CAM Visualizer   │  │ - FDA Approved Therapies│ │
 │  │ - SHAP Attribution      │  │ - Lesion Segmentation   │  │ - Clinical Trials Match │ │
 │  └─────────────────────────┘  └─────────────────────────┘  └─────────────────────────┘ │
 │                                            ▲                                           │
 │                                            │                                           │
 │  ┌─────────────────────────────────────────┴─────────────────────────────────────────┐ │
 │  │                  MULTIMODAL FUSION & CONFIDENCE CALIBRATION LAYER                 │ │
 │  │  - Early / Late Fusion of Genomic Signature + Imaging Features                    │ │
 │  │  - Calibrated Multiclass Probabilities (Lung, Breast, Colorectal, Prostate, etc.) │ │
 │  │  - Uncertainty Quantification (Ensemble / Monte Carlo Dropout)                    │ │
 │  └───────────────────────────────────────────────────────────────────────────────────┘ │
 └───────────────────────────────────────────┬────────────────────────────────────────────┘
                                             │
                                             ▼
 ┌────────────────────────────────────────────────────────────────────────────────────────┐
 │                      PERSISTENCE & SCIENTIFIC KNOWLEDGE STORAGE                        │
 │  - SQLite / PostgreSQL: Patient Profiles, Screening Records, Audit Logs                │
 │  - Local Vector / Knowledge Cache: NCCN Guidelines, Drug Database, Variant Ontologies  │
 └────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Detailed File Modification & Creation Roadmap

### 6.1 Files that Should NOT be Modified (Preserve Core Identity & Assets)
Preserve the custom styling, themes, typography, and assets that give the app its futuristic identity:
1. `lib/core/constants/app_colors.dart` — Design tokens, neon accents, and dark surface colors.
2. `lib/core/constants/app_gradients.dart` — Custom radial and linear background gradients.
3. `lib/core/constants/app_typography.dart` — Font sizes and typography hierarchy.
4. `lib/core/constants/app_theme.dart` — Global dark Material theme configuration.
5. `lib/presentation/widgets/glow_container.dart` — Core reusable visual container.
6. `lib/presentation/widgets/gradient_button.dart` — Reusable action button.
7. `lib/presentation/widgets/custom_app_bar.dart` — Standardized header app bar.
8. `lib/presentation/widgets/status_bar_simulator.dart` — Immersive status bar preview widget.
9. `lib/presentation/widgets/holographic_visuals.dart` — Custom holographic canvas painter.
10. `assets/images/splash_screen.png` — Splash brand asset.

### 6.2 Existing Files Recommended for Modification
These files will be updated to transition from static simulation to real API-backed functionality:

| File Path | Recommended Modification |
|---|---|
| `pubspec.yaml` | Add `http: ^1.2.2`, `shared_preferences: ^2.3.2`, `fl_chart: ^0.70.0` (for confidence & SHAP charts). |
| `lib/data/models/screening_record_model.dart` | Expand model to support multimodal inputs, class probability distributions, biomarker lists, explainability data, and JSON serialization (`fromJson`, `toJson`). |
| `lib/presentation/providers/screening_provider.dart` | Integrate real HTTP service client, persistent caching via SharedPreferences/SQLite, dynamic result state, and error handling. |
| `lib/presentation/screens/08_upload/genomic_upload_screen.dart` | Support real file byte reading, genomic format validation (CSV header check), and upload progress. |
| `lib/presentation/screens/08_upload/medical_image_upload_screen.dart` | Support real image preview, scan format validation (PNG/JPG/DICOM), and upload dispatch. |
| `lib/presentation/screens/09_analysis/ai_analysis_screen.dart` | Replace simulated timer with real asynchronous backend API call and stage-by-stage status updates. |
| `lib/presentation/screens/10_result/high_risk_result_screen.dart` | Bind to dynamic API results: cancer type, multiclass probabilities, top genomic biomarker contributions, and interactive XAI visualization. |
| `lib/presentation/screens/11_result/no_high_risk_result_screen.dart` | Bind to dynamic API results with specific risk score breakdown. |
| `lib/presentation/screens/12_reports/reports_screen.dart` | Generate real PDF documents with dynamic screening details using `pdf: ^3.11.1` or backend PDF generator. |
| `lib/presentation/screens/15_food_guidance/food_guidance_screen.dart` | Dynamically link nutritional and lifestyle recommendations to specific predicted cancer types and patient biomarker profiles. |

### 6.3 New Files to be Created for Upgrade

#### A. Frontend Architecture Layer (`lib/`)
1. `lib/core/services/api_service.dart` — Central REST client for genomic analysis, image inference, treatment intelligence, and health status.
2. `lib/core/services/storage_service.dart` — Local storage service (SharedPreferences / SQLite) for persisting user profile, screening history, and reminders.
3. `lib/data/models/multimodal_analysis_result_model.dart` — Complete data model representing multimodal predictions, class probabilities, biomarkers, and XAI maps.
4. `lib/data/models/treatment_intelligence_model.dart` — Model representing biomarker-targeted drugs, clinical evidence, FDA approvals, and ongoing clinical trials.
5. `lib/data/models/explainability_model.dart` — Model for SHAP feature importances and Grad-CAM heatmap overlays.
6. `lib/presentation/widgets/probability_distribution_chart.dart` — Interactive bar/radar chart visualizing prediction confidence across cancer types.
7. `lib/presentation/widgets/explainable_ai_card.dart` — Visual component rendering top genomic driver mutations and image saliency/Grad-CAM overlays.
8. `lib/presentation/widgets/biomarker_treatment_card.dart` — Card displaying detected biomarkers and matched targeted therapies.

#### B. Backend Machine Learning & API Layer (`backend/`)
1. `backend/main.py` — FastAPI application entrypoint with CORS, health checks, and route registrations.
2. `backend/requirements.txt` — Python dependencies (`fastapi`, `uvicorn`, `torch`, `torchvision`, `scikit-learn`, `pandas`, `numpy`, `shap`, `opencv-python-headless`, `pydantic`).
3. `backend/routers/analysis_router.py` — Endpoints:
   - `POST /api/v1/analyze/genomic` — Genomic tabular/expression/mutation analysis.
   - `POST /api/v1/analyze/image` — Medical scan (CT/X-ray/Histopathology) classification.
   - `POST /api/v1/analyze/multimodal` — Combined genomic + imaging multimodal fusion.
4. `backend/routers/treatment_router.py` — Endpoint `POST /api/v1/treatment/intelligence` mapping genomic biomarkers to targeted therapies, evidence levels, and clinical trials.
5. `backend/services/genomic_classifier.py` — Lightweight ML classifier (LightGBM/RandomForest/NeuralNet) trained on cancer gene expression/biomarker signatures.
6. `backend/services/vision_classifier.py` — Deep learning vision model (ResNet/EfficientNet/ViT) with Grad-CAM heatmap generation.
7. `backend/services/multimodal_fusion.py` — Fusion engine combining genomic risk scores with imaging probability distributions.
8. `backend/services/xai_service.py` — Feature attribution generator computing SHAP values for genomic biomarkers.
9. `backend/services/treatment_knowledge_service.py` — Oncology knowledgebase linking biomarkers (e.g. *EGFR*, *KRAS*, *BRAF*, *BRCA1/2*, *HER2*, *TP53*) to approved therapies and trial matches.
10. `backend/sample_data/` — Validated sample CSVs and demo medical scans for instant testing and demonstration.

---

## 7. Verification & Safety Guidelines for Next Steps

1. **Non-Destructive Approach:** The existing Flutter UI flow, dark neon aesthetic, and voice assistant logic must remain intact while upgrading the underlying data and inference layer.
2. **Graceful Fallbacks:** The app should support offline/demo mode with realistic mock datasets if the backend server is unreachable.
3. **Medical Disclaimer Integrity:** All diagnostic screens must retain clear disclaimers stating that AI results are supportive screening insights and do not replace professional oncological consultation.
