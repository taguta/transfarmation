import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/providers/data_providers.dart';
import '../../../../core/utils/app_prefs.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Farmer';
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _consent = false;
  String _gender = 'Prefer not to say';
  String _ageBand = 'Prefer not to say';
  bool _consentError = false;

  /// Bump when the wording below changes, so stored consents stay traceable.
  static const _consentVersion = '2026-10-v1';

  @override
  void initState() {
    super.initState();
    AppPrefs.role.then((r) {
      if (mounted) setState(() => _selectedRole = r);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    setState(() => _consentError = !_consent);
    if (!formOk || !_consent) return;
    setState(() => _isLoading = true);
    // Read everything up front: the sign-in guard moves the user to /home as
    // soon as the account exists, which disposes this screen before the awaits
    // below finish. Using `ref` or the controllers afterwards would throw and
    // the profile and consent record would never be saved.
    final repo = ref.read(authRepositoryProvider);
    final db = ref.read(databaseProvider);
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final role = _selectedRole;
    final gender = _gender;
    final ageBand = _ageBand;
    try {
      await repo.register(email, password, name);
      await _saveProfile(
        db,
        name: name,
        phone: phone,
        role: role,
        gender: gender,
        ageBand: ageBand,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        String msg = 'Registration failed. Please try again.';
        if (e is FirebaseAuthException) { // Will need FirebaseAuth import if compiling checks exception type explicitly
          msg = _errorMessage(e.code);
        } else {
          msg = e.toString().contains('Exception') ? e.toString().replaceAll('Exception: ', '') : msg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Stores role and phone locally and queues them for sync, so they are not lost.
  Future<void> _saveProfile(
    Database db, {
    required String name,
    required String phone,
    required String role,
    required String gender,
    required String ageBand,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await AppPrefs.setRole(role);
    await db.insert('sync_queue', {
      'id': 'profile_$uid',
      'type': 'user_profile',
      'payload': jsonEncode({
        'id': uid,
        'userId': uid,
        'name': name,
        'phone': phone,
        'role': role,
        'gender': gender,
        'ageBand': ageBand,
        'consentVersion': _consentVersion,
        'consentAt': DateTime.now().toUtc().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }),
      'retryCount': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  String _errorMessage(String code) => switch (code) {
    'email-already-in-use' => 'An account already exists with this email.',
    'invalid-email' => 'Please enter a valid email address.',
    'weak-password' => 'Password is too weak. Use at least 6 characters.',
    'operation-not-allowed' => 'Email registration is not enabled.',
    _ => 'Registration failed. Please try again.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isLoading ? null : () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: Breakpoints.formWidth,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  style: AppTextStyles.h1.copyWith(
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'One account for your farm, finances and markets',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: Palette.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator:
                      (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '+263...',
                  ),
                  validator:
                      (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'I am a...',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Farmer', child: Text('Farmer')),
                    DropdownMenuItem(value: 'Lender', child: Text('Lender')),
                    DropdownMenuItem(value: 'Buyer', child: Text('Buyer')),
                    DropdownMenuItem(
                      value: 'Expert',
                      child: Text('Expert / Agronomist'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedRole = v!),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Optional. Used only to see whether women and young farmers are
                // being reached, never to decide access or credit.
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Gender (optional)',
                    prefixIcon: Icon(Icons.diversity_1_outlined),
                  ),
                  items: [
                    for (final g in ['Female', 'Male', 'Prefer not to say'])
                      DropdownMenuItem(value: g, child: Text(g)),
                  ],
                  onChanged: (v) => setState(() => _gender = v!),
                ),
                const SizedBox(height: AppSpacing.lg),

                DropdownButtonFormField<String>(
                  initialValue: _ageBand,
                  decoration: const InputDecoration(
                    labelText: 'Age (optional)',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  items: [
                    for (final a in ['Under 25', '25–35', '36–55', 'Over 55', 'Prefer not to say'])
                      DropdownMenuItem(value: a, child: Text(a)),
                  ],
                  onChanged: (v) => setState(() => _ageBand = v!),
                ),
                const SizedBox(height: AppSpacing.lg),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                  ),
                  validator:
                      (v) =>
                          (v != null && v.length < 6)
                              ? 'Min 6 characters'
                              : null,
                ),

                const SizedBox(height: AppSpacing.lg),

                CheckboxListTile(
                  value: _consent,
                  onChanged: _isLoading
                      ? null
                      : (v) => setState(() {
                          _consent = v ?? false;
                          _consentError = false;
                        }),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'I agree that Transfarmation may store my name, phone number, '
                    'farm and location details to run my account. My details are only '
                    'shared with a lender, contractor or regulator when I choose to '
                    'share them, and I can ask for them to be deleted.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: _consentError ? AppColors.error : Palette.textSecondary,
                    ),
                  ),
                ),
                if (_consentError)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: Text(
                      'Please agree to continue',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
                    ),
                  ),

                const SizedBox(height: AppSpacing.xxl),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: Palette.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.go('/login'),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
