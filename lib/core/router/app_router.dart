import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/expert/presentation/screens/expert_chat_screen.dart';
import '../../features/expert/presentation/screens/expert_list_screen.dart';
import '../../features/farm/presentation/screens/add_crop_screen.dart';
import '../../features/farm/presentation/screens/farm_records_screen.dart';
import '../../features/financing/presentation/screens/apply_loan_screen.dart';
import '../../features/financing/presentation/screens/loan_offers_screen.dart';
import '../../features/financing/presentation/screens/loan_status_screen.dart';
import '../../features/financing/presentation/screens/repayment_dashboard_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../../features/marketplace/presentation/screens/sell_produce_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/shell/presentation/screens/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/marketplace',
            builder: (context, state) => const MarketplaceScreen(),
            routes: [
              GoRoute(
                path: 'sell',
                builder: (context, state) => const SellProduceScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/financing',
            builder: (context, state) => const LoanStatusScreen(),
            routes: [
              GoRoute(
                path: 'apply',
                builder: (context, state) => const ApplyLoanScreen(),
              ),
              GoRoute(
                path: 'offers',
                builder: (context, state) => const LoanOffersScreen(),
              ),
              GoRoute(
                path: 'repayments',
                builder: (context, state) =>
                    const RepaymentDashboardScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/expert',
            builder: (context, state) => const ExpertListScreen(),
            routes: [
              GoRoute(
                path: 'chat',
                builder: (context, state) => const ExpertChatScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/farm',
            builder: (context, state) => const FarmRecordsScreen(),
            routes: [
              GoRoute(
                path: 'add-crop',
                builder: (context, state) => const AddCropScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
  );
});
