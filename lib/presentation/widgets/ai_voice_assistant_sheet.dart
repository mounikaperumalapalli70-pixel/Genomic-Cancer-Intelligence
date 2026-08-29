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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
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
                  color: Colors.grey.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'Ask AI Assistant',
                style: TextStyle(
                  color: Colors.black,
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
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF24488A),
                      Color(0xFF0E1A38),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(
                      alpha: 0.7 + _pulseController.value * 0.3,
                    ),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(
                        alpha: 0.3 + _pulseController.value * 0.3,
                      ),
                      blurRadius: 14 + _pulseController.value * 6,
                      spreadRadius: 1 + _pulseController.value * 2,
                    ),
                  ],
                ),
                child: Center(
                  child: RobotAvatar(
                    size: 32,
                    isGlowing: _pulseController.value > 0.5,
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
    final radius = size.width * 0.42;

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
        colors: [Color(0xFFE8EEF8), Color(0xFFB0C4DE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(headRect.outerRect);

    canvas.drawRRect(headRect, headPaint);

    // Dark Screen Visor
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 2),
        width: size.width * 0.56,
        height: size.height * 0.38,
      ),
      Radius.circular(size.width * 0.14),
    );

    final visorPaint = Paint()..color = const Color(0xFF091224);
    canvas.drawRRect(visorRect, visorPaint);

    // Glowing Cyan Eyes (Happy curved arches or circles)
    final eyePaint = Paint()
      ..color = isGlowing ? const Color(0xFF00FFFF) : const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final leftEye = Offset(center.dx - size.width * 0.13, center.dy - 3);
    final rightEye = Offset(center.dx + size.width * 0.13, center.dy - 3);

    final leftEyePath = Path()
      ..moveTo(leftEye.dx - 3, leftEye.dy + 1)
      ..quadraticBezierTo(leftEye.dx, leftEye.dy - 3, leftEye.dx + 3, leftEye.dy + 1);

    final rightEyePath = Path()
      ..moveTo(rightEye.dx - 3, rightEye.dy + 1)
      ..quadraticBezierTo(rightEye.dx, rightEye.dy - 3, rightEye.dx + 3, rightEye.dy + 1);

    canvas.drawPath(leftEyePath, eyePaint);
    canvas.drawPath(rightEyePath, eyePaint);

    // Headphones (Left & Right Ear Cups)
    final earPaint = Paint()
      ..color = const Color(0xFF2C5BA8)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - radius * 0.88, center.dy - 2),
          width: size.width * 0.14,
          height: size.height * 0.32,
        ),
        Radius.circular(size.width * 0.06),
      ),
      earPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.88, center.dy - 2),
          width: size.width * 0.14,
          height: size.height * 0.32,
        ),
        Radius.circular(size.width * 0.06),
      ),
      earPaint,
    );

    // Headband
    final bandPaint = Paint()
      ..color = const Color(0xFF2C5BA8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;

    final bandPath = Path()
      ..moveTo(center.dx - radius * 0.7, center.dy - size.height * 0.28)
      ..quadraticBezierTo(
        center.dx,
        center.dy - size.height * 0.48,
        center.dx + radius * 0.7,
        center.dy - size.height * 0.28,
      );
    canvas.drawPath(bandPath, bandPaint);
  }

  @override
  bool shouldRepaint(covariant _RobotAvatarPainter oldDelegate) =>
      oldDelegate.isGlowing != isGlowing;
}

/// Modal Bottom Sheet for Real Two-Way Voice Interaction
class AiVoiceAssistantSheet extends StatefulWidget {
  final AssistantMode mode;
  final String initialLanguageCode;
  final ExtractedBasicInfo? currentInfo;
  final void Function(String languageCode)? onLanguageSelected;
  final void Function(Gender gender)? onGenderSelected;
  final void Function(ExtractedBasicInfo info)? onBasicInfoUpdated;

  const AiVoiceAssistantSheet({
    super.key,
    required this.mode,
    required this.initialLanguageCode,
    this.currentInfo,
    this.onLanguageSelected,
    this.onGenderSelected,
    this.onBasicInfoUpdated,
  });

  static Future<void> show({
    required BuildContext context,
    required AssistantMode mode,
    required String initialLanguageCode,
    ExtractedBasicInfo? currentInfo,
    void Function(String languageCode)? onLanguageSelected,
    void Function(Gender gender)? onGenderSelected,
    void Function(ExtractedBasicInfo info)? onBasicInfoUpdated,
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

  @override
  void initState() {
    super.initState();
    _activeLang = widget.initialLanguageCode;

    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Start voice session ONLY when bottom sheet is explicitly opened by user
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
      onComplete: () {
        if (!mounted) return;
        setState(() {
          _status = 'Information updated successfully!';
        });
        Future.delayed(const Duration(milliseconds: 1400), () {
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
        color: const Color(0xFF0D1B36),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: AppColors.neonBlue.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonBlue.withValues(alpha: 0.35),
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
              color: Colors.white24,
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
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.record_voice_over_rounded, size: 13, color: AppColors.neonCyan),
                    const SizedBox(width: 5),
                    Text(
                      languageName,
                      style: const TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
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
              // 3D Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceElevated,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: RobotAvatar(size: 56, isGlowing: true),
                ),
              ),
              const SizedBox(width: 16),

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
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    if (_phoneticMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _phoneticMessage!,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.neonCyan,
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
                  ? AppColors.neonGreen
                  : AppColors.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          // Audio Waveform Visualizer
          SizedBox(
            width: double.infinity,
            height: 36,
            child: AnimatedBuilder(
              animation: _waveformController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _VoiceSheetWaveformPainter(
                    progress: _waveformController.value,
                    isListening: _stt.isListening,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Large Microphone Action Button
          GestureDetector(
            onTap: _handleMicTap,
            child: ValueListenableBuilder<bool>(
              valueListenable: _stt.isListeningNotifier,
              builder: (context, isListening, child) {
                return Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.primaryButton,
                    border: Border.all(
                      color: isListening ? AppColors.neonCyan : Colors.white24,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonBlue.withValues(
                          alpha: isListening ? 0.75 : 0.4,
                        ),
                        blurRadius: isListening ? 26 : 14,
                        spreadRadius: isListening ? 3 : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _VoiceSheetWaveformPainter extends CustomPainter {
  final double progress;
  final bool isListening;

  _VoiceSheetWaveformPainter({
    required this.progress,
    required this.isListening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 30;
    final barWidth = size.width / (barCount * 1.6);
    final midY = size.height / 2;

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.neonCyan,
          AppColors.neonBlue,
          AppColors.neonPurple,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    for (int i = 0; i < barCount; i++) {
      final x = i * (size.width / barCount) + barWidth / 2;
      double waveHeight = 4.0;

      final frequency = (i / barCount) * 4 * math.pi;
      final animOffset = progress * 2 * math.pi;
      final sinVal = math.sin(frequency + animOffset).abs();
      final cosVal = math.cos((i / barCount) * 2 * math.pi - animOffset).abs();

      if (isListening) {
        waveHeight = 6 + (sinVal * 0.7 + cosVal * 0.3) * (size.height * 0.8);
      } else {
        waveHeight = 4 + (sinVal * 0.3) * (size.height * 0.35);
      }

      canvas.drawLine(
        Offset(x, midY - waveHeight / 2),
        Offset(x, midY + waveHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceSheetWaveformPainter oldDelegate) => true;
}
