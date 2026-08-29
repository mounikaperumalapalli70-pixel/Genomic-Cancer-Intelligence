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

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTab = 0; // 0: Latest Report, 1: All Reports

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final records = screeningProvider.records;
    final displayedRecords = _selectedTab == 0 ? records.take(1).toList() : records;

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
                title: 'Reports',
                showBackButton: true,
                onBackPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Segmented Tab Controls
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTabButton(
                                label: 'Latest Report',
                                isSelected: _selectedTab == 0,
                                onTap: () => setState(() => _selectedTab = 0),
                              ),
                            ),
                            Expanded(
                              child: _buildTabButton(
                                label: 'All Reports',
                                isSelected: _selectedTab == 1,
                                onTap: () => setState(() => _selectedTab = 1),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Report Cards List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedRecords.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final record = displayedRecords[index];
                          return _buildReportCard(context, record, screeningProvider);
                        },
                      ),

                      const SizedBox(height: 24),
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

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    ScreeningRecordModel record,
    ScreeningProvider provider,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy • h:mm a');
    final formattedDate = dateFormat.format(record.timestamp);
    final isHighRisk = record.riskLevel == ScreeningRiskLevel.highRisk;

    return GlowContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceCard,
      borderGradient: isHighRisk ? AppGradients.neonBorderPink : null,
      glowColor: isHighRisk ? AppColors.neonRed : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isHighRisk
                      ? const Color(0xFF3B1520)
                      : const Color(0xFF0E382B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHighRisk ? AppColors.neonRed : AppColors.neonGreen,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: isHighRisk ? AppColors.neonRed : AppColors.neonGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Result badge text
          Row(
            children: [
              Text(
                'Result: ',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                isHighRisk ? 'High Risk Detected' : 'No Abnormality Detected',
                style: AppTypography.bodySmall.copyWith(
                  color: isHighRisk ? AppColors.neonRed : AppColors.neonGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons: View Report & Download PDF
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.neonBlue),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('View Report', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    provider.setActiveScreeningResult(record);
                    if (isHighRisk) {
                      Navigator.of(context).pushNamed(AppRoutes.highRiskResult);
                    } else {
                      Navigator.of(context).pushNamed(AppRoutes.noHighRiskResult);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryButton,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Download PDF', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surfaceElevated,
                          content: Text('Downloading PDF report for ${record.title}...'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


