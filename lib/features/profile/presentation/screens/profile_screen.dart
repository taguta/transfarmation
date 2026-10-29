import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/theme_provider.dart';
import '../../../advisory/presentation/providers/advisory_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../farm/presentation/providers/farm_providers.dart';
import '../providers/profile_providers.dart';
import '../../domain/entities/profile_settings.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final userState = ref.watch(authStateProvider);
    final user = userState.valueOrNull ?? FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'New Farmer';
    final initials = displayName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final email = user?.email ?? 'Farmer · Mashonaland East';
    final farmState = ref.watch(farmProvider);
    final farmSize = farmState.valueOrNull?.sizeHectares.toString() ?? '12';

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
                style: AppTextStyles.h2.copyWith(color: Palette.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: AppTextStyles.bodyMd.copyWith(
                  color: Palette.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Palette.primarySurface,
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
                  _ProfileStat(label: 'Farm Size', value: '$farmSize ha'),
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
                  final nameController = TextEditingController(text: displayName);
                  final emailController = TextEditingController(text: email);
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Edit Profile'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: emailController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Phone/Email',
                              border: OutlineInputBorder(),
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
                          onPressed: () async {
                            try {
                              await user?.updateDisplayName(nameController.text.trim());
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(content: Text('Profile updated successfully.')),
                                );
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('Error updating profile: $e')),
                                );
                              }
                            }
                          },
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
                  final sizeController = TextEditingController(text: farmSize);
                  final farmNameController = TextEditingController(text: farmState.valueOrNull?.name ?? 'My Farm');
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
                          TextField(controller: farmNameController, decoration: const InputDecoration(labelText: 'Farm Name', border: OutlineInputBorder())),
                          const SizedBox(height: AppSpacing.md),
                          TextField(controller: sizeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Farm Size (Hectares)', border: OutlineInputBorder())),
                          const SizedBox(height: AppSpacing.xl),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                final size = double.tryParse(sizeController.text.trim()) ?? 0.0;
                                await ref.read(farmProvider.notifier).updateFarmProfile(size, farmNameController.text.trim());
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(content: Text('Farm details updated successfully.')),
                                  );
                                }
                              },
                              child: const Text('Update'),
                            ),
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

              if (ref.watch(isAdminProvider).valueOrNull == true) ...[
                const SizedBox(height: AppSpacing.xl),
                _SectionHeader(title: 'Administration'),
                _SettingsTile(
                  icon: Icons.verified_user_rounded,
                  title: 'Verify Experts',
                  subtitle: 'Review agronomist and vet applications',
                  onTap: () => context.push('/admin/experts'),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(title: 'Data & Sync'),
              _SettingsTile(
                icon: Icons.cloud_sync_rounded,
                title: 'Data Synchronization',
                subtitle: 'Manage offline uploads',
                onTap: () => context.go('/profile/sync'),
              ),
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                title: 'Request data deletion',
                subtitle: 'Ask us to delete your account data',
                onTap: () => _requestDeletion(context, ref),
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
                subtitle: ref.watch(appLanguageProvider).label,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('Select Language'),
                      children: [
                        for (final l in AppLanguage.values)
                          SimpleDialogOption(
                            onPressed: AppStrings.isAvailable(l)
                                ? () {
                                    ref.read(appLanguageProvider.notifier).set(l);
                                    Navigator.pop(ctx);
                                  }
                                : null,
                            child: Text(
                              AppStrings.isAvailable(l)
                                  ? l.label
                                  : '${l.label} (being translated with native speakers)',
                            ),
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
                      child: Consumer(
                        builder: (ctx, ref, _) {
                          final settingsAsync = ref.watch(profileSettingsProvider);
                          final settings = settingsAsync.valueOrNull ?? const ProfileSettings();
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Notification Preferences', style: AppTextStyles.h2),
                              const SizedBox(height: AppSpacing.lg),
                              SwitchListTile(
                                value: settings.pushNotifications,
                                onChanged: (v) {
                                  ref.read(profileRepositoryProvider).updateSettings(settings.copyWith(pushNotifications: v));
                                  ref.invalidate(profileSettingsProvider);
                                },
                                title: const Text('Push Notifications'),
                              ),
                              SwitchListTile(
                                value: settings.smsAlerts,
                                onChanged: (v) {
                                  ref.read(profileRepositoryProvider).updateSettings(settings.copyWith(smsAlerts: v));
                                  ref.invalidate(profileSettingsProvider);
                                },
                                title: const Text('SMS Alerts (Weather)'),
                                ),
                              SwitchListTile(
                                value: settings.emailUpdates,
                                onChanged: (v) {
                                  ref.read(profileRepositoryProvider).updateSettings(settings.copyWith(emailUpdates: v));
                                  ref.invalidate(profileSettingsProvider);
                                },
                                title: const Text('Email Updates'),
                              ),
                            ],
                          );
                        }
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

/// Asks for the farmer's data to be deleted. The request is queued locally,
/// so it is kept and sent even if the farmer is offline when they tap it.
Future<void> _requestDeletion(BuildContext context, WidgetRef ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final messenger = ScaffoldMessenger.of(context);
  if (uid == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Sign in to request data deletion.')),
    );
    return;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete my data?'),
      content: const Text(
        'We will delete your account data after checking the request. '
        'You may lose access to your records, loans and contracts. '
        'Records a lender or contractor must keep by law may be retained.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Send request'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(databaseProvider).insert('sync_queue', {
    'id': 'deletion_$uid',
    'type': 'data_deletion_request',
    'payload': jsonEncode({
      'id': 'deletion_$uid',
      'userId': uid,
      'requestedAt': DateTime.now().toIso8601String(),
      'status': 'requested',
    }),
    'retryCount': 0,
  }, conflictAlgorithm: ConflictAlgorithm.replace);
  messenger.showSnackBar(
    const SnackBar(content: Text('Request saved. It will be sent when you are online.')),
  );
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
          color: Palette.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Palette.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.h2.copyWith(color: Palette.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Palette.textTertiary,
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
          style: AppTextStyles.labelMd.copyWith(color: Palette.textTertiary),
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
          color: Palette.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: Palette.textSecondary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.labelLg.copyWith(color: Palette.textPrimary),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(
                  color: Palette.textTertiary,
                ),
              )
              : null,
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: Palette.textTertiary,
          ),
      onTap: onTap,
    );
  }
}
