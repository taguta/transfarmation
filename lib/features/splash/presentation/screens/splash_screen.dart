import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // ─── Logo ──────────────────────────────────────────
            Container(
              width: size.width * 0.55,
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/transfarmation.jpeg',
                fit: BoxFit.contain,
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 32),

            // ─── App Name ──────────────────────────────────────
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Trans',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF333333),
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'farmation',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOut),

            const SizedBox(height: 12),

            // ─── Motto ─────────────────────────────────────────
            Text(
              '" People busy transforming their farming activities "',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.textTertiary : const Color(0xFF777777),
                letterSpacing: 0.3,
              ),
            )
                .animate(delay: 800.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOut),

            const Spacer(flex: 3),

            // ─── Loading indicator ─────────────────────────────
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: isDark
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primarySurface,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
                .animate(delay: 1200.ms)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 48),

            // ─── Footer ────────────────────────────────────────
            Text(
              'Empowering Farmers Digitally',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textTertiary : const Color(0xFFAAAAAA),
                letterSpacing: 1.2,
              ),
            )
                .animate(delay: 1000.ms)
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
