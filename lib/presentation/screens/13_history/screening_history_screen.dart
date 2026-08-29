import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/screening_record_model.dart';
import '../../providers/screening_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';

class ScreeningHistoryScreen extends StatelessWidget {
  const ScreeningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final records = screeningProvider.records;
    final dateFormat = DateFormat('dd MMM yyyy • h:mm a');

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
                title: 'Screening History',
                showBackButton: true,
                onBackPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: records.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final formattedDate = dateFormat.format(record.timestamp);

                    Color statusColor;
                    String statusText;
                    IconData recordIcon;

                    switch (record.riskLevel) {
                      case ScreeningRiskLevel.highRisk:
                        statusColor = AppColors.neonRed;
                        statusText = 'High Risk Detected';
                        recordIcon = Icons.warning_amber_rounded;
                        break;
                      case ScreeningRiskLevel.lowRisk:
                        statusColor = AppColors.neonAmber;
                        statusText = 'Low Risk';
                        recordIcon = Icons.info_outline_rounded;
                        break;
                      case ScreeningRiskLevel.noAbnormality:
                        statusColor = AppColors.neonGreen;
                        statusText = 'No Abnormality Detected';
                        recordIcon = Icons.check_circle_outline_rounded;
                        break;
                    }

                    return GlowContainer(
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      backgroundColor: AppColors.surfaceCard,
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              recordIcon,
                              color: statusColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  record.title,
                                  style: AppTypography.headingSmall.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  statusText,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.borderSubtle),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'View Report',
                              style: TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              screeningProvider.setActiveScreeningResult(record);
                              if (record.riskLevel == ScreeningRiskLevel.highRisk) {
                                Navigator.of(context).pushNamed(AppRoutes.highRiskResult);
                              } else {
                                Navigator.of(context).pushNamed(AppRoutes.noHighRiskResult);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


