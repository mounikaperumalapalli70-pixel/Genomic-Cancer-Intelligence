import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_display_name_helper.dart';
import '../../../data/models/user_profile_model.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/screening_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Text(
          'Confirm Sign Out',
          style: AppTypography.headingSmall.copyWith(fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to sign out from your clinical session?',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final onboarding = Provider.of<OnboardingProvider>(context, listen: false);
      final screening = Provider.of<ScreeningProvider>(context, listen: false);
      
      onboarding.clearAuth();
      screening.resetSessionState();
      await authService.signOut();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.accountCheck,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = Provider.of<OnboardingProvider>(context);
    final profile = onboarding.profile;
    final resolvedName = UserDisplayNameHelper.getResolvedDisplayName(
      profileName: profile.name,
      authDisplayName: onboarding.authDisplayName,
      email: onboarding.authEmail,
    );
    final displayName = resolvedName ?? 'Not provided';
    final email = onboarding.authEmail != null && onboarding.authEmail!.isNotEmpty
        ? onboarding.authEmail!
        : 'Not provided';
    final language = onboarding.selectedLanguage;
    final photoUrl = onboarding.authPhotoUrl;

    final ageDisplay = profile.age != null ? '${profile.age} yrs' : 'Not provided';
    final bloodDisplay = (profile.bloodGroup != null && profile.bloodGroup!.isNotEmpty)
        ? profile.bloodGroup!
        : 'Not provided';
    final genderDisplay = profile.gender != null
        ? (profile.gender == Gender.male
            ? 'Male'
            : (profile.gender == Gender.female ? 'Female' : 'Other'))
        : 'Not provided';

    final avatarChar = (resolvedName != null && resolvedName.isNotEmpty)
        ? resolvedName[0].toUpperCase()
        : 'P';

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
                title: 'Clinical Profile & Settings',
                showBackButton: true,
                onBackPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      // User Identity Card
                      GlowContainer(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(20),
                        backgroundColor: AppColors.surfaceCard,
                        borderWidth: 1.5,
                        borderColor: AppColors.borderTeal.withValues(alpha: 0.3),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.tealMint,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryTeal.withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: photoUrl != null && photoUrl.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) => Center(
                                          child: Text(
                                            avatarChar,
                                            style: AppTypography.headingMedium.copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        avatarChar,
                                        style: AppTypography.headingMedium.copyWith(color: Colors.white),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: AppTypography.headingSmall.copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    email,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.mint.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Active Patient Account',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.darkTeal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Basic Vitals Summary
                      Row(
                        children: [
                          Expanded(
                            child: _buildVitalChip(
                              label: 'Age',
                              value: ageDisplay,
                              icon: Icons.cake_outlined,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildVitalChip(
                              label: 'Blood',
                              value: bloodDisplay,
                              icon: Icons.water_drop_outlined,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildVitalChip(
                              label: 'Gender',
                              value: genderDisplay,
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Settings Options List
                      _buildSettingsSection(
                        title: 'Preferences & Language',
                        items: [
                          _SettingsItem(
                            icon: Icons.translate_rounded,
                            title: 'Selected Language',
                            subtitle: '${language.name} (${language.nativeName})',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRoutes.languageSelection);
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.notifications_active_outlined,
                            title: 'Screening Reminders',
                            subtitle: 'Daily medicine & test notifications',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRoutes.notifications);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      _buildSettingsSection(
                        title: 'Clinical Data & Privacy',
                        items: [
                          _SettingsItem(
                            icon: Icons.history_rounded,
                            title: 'Screening History',
                            subtitle: 'View past TCGA & imaging tests',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRoutes.screeningHistory);
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.security_rounded,
                            title: 'HIPAA & Data Privacy Notice',
                            subtitle: 'De-identified genomic research protocols',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.primaryTeal,
                                  content: Text('All data is encrypted in transit and at rest adhering to research protocols.'),
                                ),
                              );
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.info_outline_rounded,
                            title: 'About Platform',
                            subtitle: 'Version 1.0.0 • TCGA Calibrated AI',
                            onTap: () {
                              showAboutDialog(
                                context: context,
                                applicationName: 'Genomic Cancer Intelligence',
                                applicationVersion: '1.0.0+1',
                                applicationIcon: Image.asset('assets/images/app_logo.png', width: 48),
                                children: [
                                  const Text('Multimodal AI platform for precision oncology, RNA-seq biomarker classification, and medical imaging diagnostics.'),
                                ],
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sign Out Button
                      GestureDetector(
                        onTap: () => _handleLogout(context),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.statusDanger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.statusDanger.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.statusDanger,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sign Out',
                                  style: AppTypography.buttonText.copyWith(
                                    color: AppColors.statusDanger,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildVitalChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryTeal),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textHeading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: AppTypography.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (ctx, idx) => const Divider(height: 1, color: AppColors.borderSubtle),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: AppColors.primaryTeal, size: 20),
                ),
                title: Text(item.title, style: AppTypography.bodyMedium),
                subtitle: Text(item.subtitle, style: AppTypography.bodySmall),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
                onTap: item.onTap,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
