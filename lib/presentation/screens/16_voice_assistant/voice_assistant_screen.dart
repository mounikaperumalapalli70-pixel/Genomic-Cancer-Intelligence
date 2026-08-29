import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/tts_service.dart';
import '../../../data/models/notification_item_model.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/screening_provider.dart';
import '../../widgets/custom_app_bar.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveformController;

  final TtsService _ttsService = TtsService();

  bool _isPlaying = false;
  bool _isLoading = false;
  String _status = 'Ready to speak';

  @override
  void initState() {
    super.initState();

    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // IMPORTANT:
    // Do NOT automatically speak when entering the screen.
    //
    // Browsers such as Chrome may block speech that starts without
    // a user interaction.
    //
    // The user must explicitly press the Play button.
  }

  @override
  void dispose() {
    _ttsService.stop();
    _waveformController.dispose();
    super.dispose();
  }

  Future<void> _speakCurrentNotification() async {
    if (_isLoading) return;

    final onboardingProvider =
        Provider.of<OnboardingProvider>(context, listen: false);

    final screeningProvider =
        Provider.of<ScreeningProvider>(context, listen: false);

    final selectedLang = onboardingProvider.selectedLanguage;
    final userName = onboardingProvider.profile.name;

    final activeNotification = screeningProvider.activeVoiceNotification;

    final spokenContent = NotificationItemModel.getSpokenVoiceTranslations(
      languageCode: selectedLang.code,
      type: activeNotification.type,
      userName: userName,
    );

    final textToSpeak =
        (spokenContent['text'] ?? activeNotification.message).trim();

    if (textToSpeak.isEmpty) {
      if (mounted) {
        setState(() {
          _status = 'No message available';
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Preparing voice...';
    });

    await _ttsService.stop();

    if (!mounted) return;

    setState(() {
      _status = 'Starting...';
    });

    final success = await _ttsService.speak(
      text: textToSpeak,
      languageCode: selectedLang.code,
      onStart: () {
        if (!mounted) return;

        setState(() {
          _isPlaying = true;
          _isLoading = false;
          _status = 'Speaking...';
        });

        _waveformController.repeat();
      },
      onComplete: () {
        if (!mounted) return;

        setState(() {
          _isPlaying = false;
          _isLoading = false;
          _status = 'Completed';
        });

        _waveformController.stop();
        _waveformController.reset();
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          _isPlaying = false;
          _isLoading = false;
          _status = 'Voice unavailable';
        });

        _waveformController.stop();
        _waveformController.reset();

        debugPrint('Voice Assistant Error: $error');
      },
    );

    if (!mounted) return;

    if (!success && !_isPlaying) {
      setState(() {
        _isLoading = false;
        _isPlaying = false;
        _status = 'Voice unavailable';
      });

      _waveformController.stop();
      _waveformController.reset();
    }
  }

  Future<void> _stopSpeaking() async {
    await _ttsService.stop();

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
      _isLoading = false;
      _status = 'Paused';
    });

    _waveformController.stop();
    _waveformController.reset();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying || _isLoading) {
      await _stopSpeaking();
    } else {
      await _speakCurrentNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final screeningProvider = Provider.of<ScreeningProvider>(context);

    final activeNotification = screeningProvider.activeVoiceNotification;
    final selectedLang = onboardingProvider.selectedLanguage;
    final userName = onboardingProvider.profile.name;

    final spokenContent = NotificationItemModel.getSpokenVoiceTranslations(
      languageCode: selectedLang.code,
      type: activeNotification.type,
      userName: userName,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundAura,
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                title: 'Voice Care Assistant',
                showBackButton: true,
                onBackPressed: () {
                  _ttsService.stop();
                  Navigator.of(context).maybePop();
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // ==========================
                      // VOICE ASSISTANT ICON
                      // ==========================
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: _isPlaying ? 104 : 84,
                        height: _isPlaying ? 104 : 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonBlue.withValues(alpha: 0.18),
                          border: Border.all(
                            color: AppColors.neonCyan.withValues(alpha: 0.85),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonCyan.withValues(
                                alpha: _isPlaying ? 0.65 : 0.35,
                              ),
                              blurRadius: _isPlaying ? 40 : 28,
                              spreadRadius: _isPlaying ? 8 : 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.record_voice_over_rounded,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 34),

                      // ==========================
                      // SPOKEN MESSAGE
                      // ==========================
                      Text(
                        spokenContent['text'] ?? activeNotification.message,
                        textAlign: TextAlign.center,
                        style: AppTypography.headingLarge.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        '(${spokenContent['phonetic'] ?? activeNotification.message})',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==========================
                      // STATUS
                      // ==========================
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _status,
                          key: ValueKey(_status),
                          style: AppTypography.bodySmall.copyWith(
                            color: _isPlaying
                                ? AppColors.neonCyan
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // ==========================
                      // WAVEFORM
                      // ==========================
                      SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: AnimatedBuilder(
                          animation: _waveformController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _AudioWaveformPainter(
                                progress: _waveformController.value,
                                isPlaying: _isPlaying,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==========================
                      // PLAY / STOP
                      // ==========================
                      GestureDetector(
                        onTap: _togglePlayback,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.primaryButton,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonBlue.withValues(alpha: 0.55),
                                blurRadius: _isPlaying ? 30 : 20,
                                spreadRadius: _isPlaying ? 4 : 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isLoading
                                ? Icons.hourglass_top_rounded
                                : _isPlaying
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ==========================
                      // LANGUAGE BADGE
                      // ==========================
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.neonCyan.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'Voice in ${selectedLang.name}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neonCyan,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioWaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;

  _AudioWaveformPainter({
    required this.progress,
    required this.isPlaying,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    const barCount = 36;
    final barWidth = size.width / (barCount * 1.5);
    final midY = size.height / 2;

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.neonCyan,
          AppColors.neonBlue,
          AppColors.neonPurple,
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      )
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    for (int i = 0; i < barCount; i++) {
      final x = i * (size.width / barCount) + barWidth / 2;
      double waveHeight = 6;

      if (isPlaying) {
        final frequency = (i / barCount) * 4 * math.pi;
        final animOffset = progress * 2 * math.pi;
        final sinVal = math.sin(frequency + animOffset).abs();
        final cosVal = math.cos((i / barCount) * 2 * math.pi - animOffset).abs();
        waveHeight = 8 + (sinVal * 0.6 + cosVal * 0.4) * (size.height * 0.7);
      }

      canvas.drawLine(
        Offset(x, midY - waveHeight / 2),
        Offset(x, midY + waveHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AudioWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isPlaying != isPlaying;
  }
}

