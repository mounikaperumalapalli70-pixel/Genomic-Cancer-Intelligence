import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_gradients.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/information_extraction_service.dart';
import '../../core/services/stt_service.dart';
import '../../core/services/tts_service.dart';
import '../../core/services/voice_assistant_service.dart';
import '../../data/models/language_model.dart';
import '../../data/models/user_profile_model.dart';

/// Floating AI Assistant Widget with "Need help? Ask AI Assistant" speech bubble
class AiAssistantFab extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const AiAssistantFab({
    super.key,
    required this.onTap,
    this.label = 'Need help?\nAsk AI Assistant',
  });

  @override
  State<AiAssistantFab> createState() => _AiAssistantFabState();
}

class _AiAssistantFabState extends State<AiAssistantFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Speech Bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Need help?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Ask AI Assistant',
                style: TextStyle(
                  color: AppColors.textHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),

        // Robot Icon Button
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.tealMint,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(
                        alpha: 0.25 + _pulseController.value * 0.2,
                      ),
                      blurRadius: 12 + _pulseController.value * 6,
                      spreadRadius: 1 + _pulseController.value * 1.5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Robot Avatar Vector Drawing Widget
class RobotAvatar extends StatelessWidget {
  final double size;
  final bool isGlowing;

  const RobotAvatar({
    super.key,
    this.size = 64,
    this.isGlowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RobotAvatarPainter(isGlowing: isGlowing),
      ),
    );
  }
}

class _RobotAvatarPainter extends CustomPainter {
  final bool isGlowing;
  _RobotAvatarPainter({this.isGlowing = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer Head Capsule
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 2),
        width: size.width * 0.72,
        height: size.height * 0.58,
      ),
      Radius.circular(size.width * 0.22),
    );

    final headPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE8FAF6), Color(0xFFC2EFEB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(headRect.outerRect);

    canvas.drawRRect(headRect, headPaint);

    // Visor
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 2),
        width: size.width * 0.56,
        height: size.height * 0.38,
      ),
      Radius.circular(size.width * 0.14),
    );

    final visorPaint = Paint()
      ..color = const Color(0xFF173B4D)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(visorRect, visorPaint);

    // Cyan Eyes
    final eyePaint = Paint()
      ..color = AppColors.primaryTeal
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx - size.width * 0.13, center.dy - 2), size.width * 0.065, eyePaint);
    canvas.drawCircle(Offset(center.dx + size.width * 0.13, center.dy - 2), size.width * 0.065, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _RobotAvatarPainter oldDelegate) =>
      oldDelegate.isGlowing != isGlowing;
}

class AiVoiceAssistantSheet extends StatefulWidget {
  final AssistantMode mode;
  final String initialLanguageCode;
  final ExtractedBasicInfo? currentInfo;
  final void Function(String languageCode)? onLanguageSelected;
  final void Function(Gender gender)? onGenderSelected;
  final void Function(ExtractedBasicInfo info)? onBasicInfoUpdated;
  final void Function(ConversationalIntent intent)? onIntentDetected;
  final VoidCallback? onComplete;

  const AiVoiceAssistantSheet({
    super.key,
    required this.mode,
    required this.initialLanguageCode,
    this.currentInfo,
    this.onLanguageSelected,
    this.onGenderSelected,
    this.onBasicInfoUpdated,
    this.onIntentDetected,
    this.onComplete,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required AssistantMode mode,
    required String initialLanguageCode,
    ExtractedBasicInfo? currentInfo,
    void Function(String languageCode)? onLanguageSelected,
    void Function(Gender gender)? onGenderSelected,
    void Function(ExtractedBasicInfo info)? onBasicInfoUpdated,
    void Function(ConversationalIntent intent)? onIntentDetected,
    VoidCallback? onComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AiVoiceAssistantSheet(
        mode: mode,
        initialLanguageCode: initialLanguageCode,
        currentInfo: currentInfo,
        onLanguageSelected: onLanguageSelected,
        onGenderSelected: onGenderSelected,
        onBasicInfoUpdated: onBasicInfoUpdated,
        onIntentDetected: onIntentDetected,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<AiVoiceAssistantSheet> createState() => _AiVoiceAssistantSheetState();
}

class _AiVoiceAssistantSheetState extends State<AiVoiceAssistantSheet>
    with SingleTickerProviderStateMixin {
  final VoiceAssistantService _voiceService = VoiceAssistantService();
  final SttService _stt = SttService();
  final TtsService _tts = TtsService();

  late AnimationController _waveformController;

  String _spokenMessage = 'Starting AI Assistant...';
  String? _phoneticMessage;
  String _status = 'Connecting...';
  late String _activeLang;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _activeLang = widget.initialLanguageCode;

    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _startSession();
  }

  @override
  void dispose() {
    _voiceService.stopSession();
    _waveformController.dispose();
    super.dispose();
  }

  void _startSession() {
    _voiceService.startSession(
      mode: widget.mode,
      languageCode: _activeLang,
      existingInfo: widget.currentInfo,
      onAiMessage: (message, phonetic) {
        if (!mounted) return;
        setState(() {
          _spokenMessage = message;
          _phoneticMessage = phonetic;
        });
      },
      onStatus: (status) {
        if (!mounted) return;
        setState(() {
          _status = status;
        });
      },
      onLanguage: (lang) {
        if (!mounted) return;
        setState(() {
          _activeLang = lang;
        });
        widget.onLanguageSelected?.call(lang);
      },
      onGender: (gender) {
        widget.onGenderSelected?.call(gender);
      },
      onBasicInfo: (info) {
        widget.onBasicInfoUpdated?.call(info);
      },
      onIntent: (intent) {
        widget.onIntentDetected?.call(intent);
      },
      onComplete: () {
        if (!mounted || _isDismissed) return;
        _isDismissed = true;
        setState(() {
          _status = widget.mode == AssistantMode.languageSelection
              ? 'Language selected! Continuing...'
              : 'Action completed!';
        });
        widget.onComplete?.call();
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
      },
    );
  }

  void _handleMicTap() async {
    if (_stt.isListening) {
      await _stt.stopListening();
    } else {
      await _tts.stop();
      await _stt.startListening(
        languageCode: _activeLang,
        onResult: (words, isFinal) {
          if (!mounted) return;
          setState(() {
            _status = 'Heard: "$words"';
          });
          _voiceService.handleExternalSpeechInput(
            words,
            isFinal,
            mode: widget.mode,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageName = LanguageModel.supportedLanguages
        .firstWhere(
          (l) => l.code == _activeLang,
          orElse: () => LanguageModel.supportedLanguages.first,
        )
        .name;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 14,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          // Header Row with Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Language indicator badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLightBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryTeal.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.record_voice_over_rounded, size: 13, color: AppColors.primaryTeal),
                    const SizedBox(width: 5),
                    Text(
                      languageName,
                      style: const TextStyle(
                        color: AppColors.primaryTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                onPressed: () {
                  _voiceService.stopSession();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Robot Avatar & Spoken Dialogue Box Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceElevated,
                  border: Border.all(color: AppColors.borderTeal.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: RobotAvatar(size: 48, isGlowing: true),
                ),
              ),
              const SizedBox(width: 14),

              // AI Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _spokenMessage,
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHeading,
                        height: 1.3,
                      ),
                    ),
                    if (_phoneticMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _phoneticMessage!,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Status Line
          Text(
            _status,
            style: TextStyle(
              color: _status.contains('Listening')
                  ? AppColors.statusSuccess
                  : AppColors.primaryTeal,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          // Audio Waveform Visualizer
          SizedBox(
            height: 36,
            child: AnimatedBuilder(
              animation: _waveformController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(18, (i) {
                    final normalized = math.sin(_waveformController.value * 2 * math.pi + i * 0.4);
                    final h = (normalized.abs() * 26).clamp(4.0, 32.0);
                    return Container(
                      width: 3.5,
                      height: h,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        gradient: AppGradients.tealMint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Mic Control Button
          GestureDetector(
            onTap: _handleMicTap,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.primaryButton,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap microphone to speak',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}
