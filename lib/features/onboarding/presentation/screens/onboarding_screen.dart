import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_prefs.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  String _role = 'Farmer';

  // Each page leads with what the farmer gets on their own, offline, on day one.
  static const _pages = [
    _OnboardingPage(
      icon: Icons.request_quote_rounded,
      title: 'A Plan Your Bank Accepts',
      subtitle:
          'Build a 24-month cash-flow plan in minutes.\nNo clerk, no waiting, works without signal.',
      color: AppColors.accent,
    ),
    _OnboardingPage(
      icon: Icons.menu_book_rounded,
      title: 'Know Where Your Money Goes',
      subtitle:
          'Record sales and costs as they happen.\nYour ledger builds the track record lenders trust.',
      color: AppColors.primary,
    ),
    _OnboardingPage(
      icon: Icons.document_scanner_rounded,
      title: 'Snap & Solve',
      subtitle:
          'Photograph a sick crop for a diagnosis and remedy.\nUnsure results go to a real agronomist.',
      color: AppColors.info,
    ),
    _OnboardingPage(
      icon: Icons.handshake_rounded,
      title: 'Fair Contracts, Fair Markets',
      subtitle:
          'Plain-language contracts, live market prices,\nand levies deducted openly, never hidden.',
      color: AppColors.marketplace,
    ),
  ];

  static const _roles = [
    ('Farmer', Icons.agriculture_rounded, 'I grow crops or keep livestock'),
    ('Lender', Icons.account_balance_rounded, 'I finance farmers'),
    ('Buyer', Icons.storefront_rounded, 'I buy produce or contract growers'),
    ('Expert', Icons.science_rounded, 'I advise farmers (agronomist / vet)'),
  ];

  int get _lastIndex => _pages.length; // role page follows the value pages

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppPrefs.completeOnboarding(_role);
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_currentPage < _lastIndex) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _lastIndex;
    final total = _pages.length + 1;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Voice guide is coming soon in Shona and Ndebele.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.mic_rounded, size: 18),
                      label: Text(
                        'Voice Guide',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          isLast
                              ? null
                              : () => _controller.animateToPage(
                                _lastIndex,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              ),
                      child: Text(
                        isLast ? '' : 'Skip',
                        style: AppTextStyles.labelLg.copyWith(
                          color: Palette.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: total,
                    itemBuilder:
                        (context, i) =>
                            i < _pages.length ? _pages[i] : _rolePage(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      total,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == i
                                  ? AppColors.primary
                                  : Palette.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    0,
                    AppSpacing.xxl,
                    AppSpacing.xxxl,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(isLast ? 'Get Started' : 'Continue'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rolePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        children: [
          Text(
            'How will you use Transfarmation?',
            style: AppTextStyles.h1.copyWith(color: Palette.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'One account, many roles. You can change this later.',
            style: AppTextStyles.bodyMd.copyWith(
              color: Palette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final (name, icon, desc) in _roles)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => setState(() => _role = name),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color:
                        _role == name
                            ? Palette.primarySurface
                            : Palette.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color:
                          _role == name ? AppColors.primary : Palette.border,
                      width: _role == name ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: AppColors.primary, size: 28),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTextStyles.labelLg),
                            Text(
                              desc,
                              style: AppTextStyles.bodySm.copyWith(
                                color: Palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_role == name)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: color),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            title,
            style: AppTextStyles.h1.copyWith(color: Palette.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            subtitle,
            style: AppTextStyles.bodyLg.copyWith(
              color: Palette.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
