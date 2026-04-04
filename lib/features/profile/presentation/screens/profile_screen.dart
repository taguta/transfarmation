import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'New Farmer';
    final initials = displayName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final email = user?.email ?? 'Farmer · Mashonaland East';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Profile avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials.isNotEmpty ? initials : 'F',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                displayName,
                style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user != null ? 'Verified User' : 'Guest Account',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Stats row
              Row(
                children: [
                  _ProfileStat(label: 'Farm Size', value: '12 ha'),
                  const SizedBox(width: AppSpacing.md),
                  _ProfileStat(label: 'Loans', value: '3'),
                  const SizedBox(width: AppSpacing.md),
                  _ProfileStat(label: 'Score', value: '72'),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Settings sections
              _SectionHeader(title: 'Account'),
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Edit Profile'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              hintText: displayName,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Phone/Email',
                              hintText: email,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.agriculture_rounded,
                title: 'Farm Details',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Update Farm Profile', style: AppTextStyles.h2),
                          const SizedBox(height: AppSpacing.lg),
                          const TextField(decoration: InputDecoration(labelText: 'Farm Size (Hectares)', border: OutlineInputBorder())),
                          const SizedBox(height: AppSpacing.md),
                          const TextField(decoration: InputDecoration(labelText: 'Primary Crops', border: OutlineInputBorder())),
                          const SizedBox(height: AppSpacing.xl),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Update')),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.security_rounded,
                title: 'Security',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Security'),
                      content: const Text('Password reset instructions will be sent to your email.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Send Reset Link'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(title: 'Data & Sync'),
              _SettingsTile(
                icon: Icons.cloud_sync_rounded,
                title: 'Data Synchronization',
                subtitle: 'Manage offline uploads',
                onTap: () => context.go('/profile/sync'),
              ),

              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(title: 'Preferences'),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch.adaptive(
                  value: themeMode == ThemeMode.dark,
                  onChanged:
                      (_) => ref.read(themeModeProvider.notifier).toggle(),
                  activeTrackColor: AppColors.primary,
                ),
                onTap: () => ref.read(themeModeProvider.notifier).toggle(),
              ),
              _SettingsTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('Select Language'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('English (UK)'),
                        ),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Shona'),
                        ),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Ndebele'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Notification Preferences', style: AppTextStyles.h2),
                          const SizedBox(height: AppSpacing.lg),
                          SwitchListTile(
                            value: true,
                            onChanged: (v) {},
                            title: const Text('Push Notifications'),
                          ),
                          SwitchListTile(
                            value: true,
                            onChanged: (v) {},
                            title: const Text('SMS Alerts (Weather)'),
                          ),
                          SwitchListTile(
                            value: false,
                            onChanged: (v) {},
                            title: const Text('Email Updates'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(title: 'Support'),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help Center',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help Center opened')),
                ),
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About Transfarmation',
                subtitle: 'Version 0.1.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Transfarmation',
                    applicationVersion: 'v0.1.0-alpha',
                    applicationLegalese: '© 2026 E-Matte Group. All rights reserved.',
                    applicationIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.filter_vintage_rounded, color: Colors.white, size: 36),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      try {
                        await GoogleSignIn().signOut();
                      } catch (_) {}
                      if (context.mounted) {
                        context.go('/login');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signed out successfully.')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error signing out: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(
          title,
          style: AppTextStyles.labelMd.copyWith(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              )
              : null,
      trailing:
          trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
      onTap: onTap,
    );
  }
}
