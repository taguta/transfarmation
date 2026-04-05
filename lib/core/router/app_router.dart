
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/contracts/presentation/screens/contract_farming_screen.dart';
import '../../features/diagnosis/presentation/screens/diagnosis_screen.dart';
import '../../features/expert/presentation/screens/expert_chat_screen.dart';
import '../../features/expert/presentation/screens/expert_list_screen.dart';
import '../../features/farm_records/presentation/screens/farm_record_screen.dart';
import '../../features/financing/presentation/screens/apply_loan_screen.dart';
import '../../features/financing/presentation/screens/loan_offers_screen.dart';
import '../../features/financing/presentation/screens/loan_status_screen.dart';
import '../../features/financing/presentation/screens/repayment_dashboard_screen.dart';
import '../../features/group_buying/presentation/screens/group_buying_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/inputs/presentation/screens/input_marketplace_screen.dart';
import '../../features/inputs/presentation/screens/subsidy_tracking_screen.dart';
import '../../features/labor_management/presentation/screens/labor_dashboard_screen.dart';
import '../../features/traceability/presentation/screens/traceability_screen.dart';
import '../../features/community/presentation/screens/community_board_screen.dart';
import '../../features/iot_devices/presentation/screens/iot_dashboard_screen.dart';
import '../../features/knowledge/presentation/screens/knowledge_base_screen.dart';
import '../../features/knowledge/presentation/screens/crop_detail_screen.dart';
import '../../features/knowledge/presentation/screens/livestock_detail_screen.dart';
import '../../features/knowledge/presentation/screens/pest_disease_detail_screen.dart';
import '../../features/market_prices/presentation/screens/market_price_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../../features/marketplace/presentation/screens/sell_produce_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/sync_ui/presentation/screens/sync_screen.dart';
import '../../features/savings/presentation/screens/savings_group_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/shell/presentation/screens/app_shell.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/weather/presentation/screens/weather_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';



final appRouterProvider = Provider<GoRouter>((ref) {
  // We strictly use the architecture's provider stream, never direct SDK calls
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Wait for auth to initialize
      if (authState.isLoading) return null;

      final user = authState.valueOrNull;
      final loc = state.matchedLocation;

      // Unprotected routes
      if (loc == '/' || loc == '/onboarding') return null;

      final isAuthRoute = loc == '/login' || loc == '/register';

      // Security Guard: Prevent unauthenticated deep-linking
      if (user == null && !isAuthRoute) {
        return '/login';
      }

      // If securely authed, don't let them hit login again
      if (user != null && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
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
                builder: (context, state) => const RepaymentDashboardScreen(),
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
            routes: [
              GoRoute(
                path: 'sync',
                builder: (context, state) => const SyncScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/services',
            builder: (context, state) => const ServicesScreen(),
          ),
          GoRoute(
            path: '/knowledge',
            builder: (context, state) => const KnowledgeBaseScreen(),
            routes: [
              GoRoute(
                path: 'crop/:id',
                builder:
                    (context, state) =>
                        CropDetailScreen(cropId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'livestock/:id',
                builder:
                    (context, state) => LivestockDetailScreen(
                      livestockId: state.pathParameters['id']!,
                    ),
              ),
              GoRoute(
                path: 'pest/:id',
                builder:
                    (context, state) => PestDiseaseDetailScreen(
                      pestId: state.pathParameters['id']!,
                    ),
              ),
            ],
          ),
          GoRoute(
            path: '/inputs',
            builder: (context, state) => const InputMarketplaceScreen(),
            routes: [
              GoRoute(
                path: 'subsidies',
                builder: (context, state) => const SubsidyTrackingScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/savings',
            builder: (context, state) => const SavingsGroupScreen(),
          ),
          GoRoute(
            path: '/diagnosis',
            builder: (context, state) => const DiagnosisScreen(),
          ),
          GoRoute(
            path: '/weather',
            builder: (context, state) => const WeatherScreen(),
          ),
          GoRoute(
            path: '/farm-records',
            builder: (context, state) => const FarmRecordScreen(),
          ),
          GoRoute(
            path: '/labor-management',
            builder: (context, state) => const LaborDashboardScreen(),
          ),
          GoRoute(
            path: '/group-buying',
            builder: (context, state) => const GroupBuyingScreen(),
          ),
          GoRoute(
            path: '/traceability',
            builder: (context, state) => const TraceabilityScreen(),
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityBoardScreen(),
          ),
          GoRoute(
            path: '/iot-dashboard',
            builder: (context, state) => const IotDashboardScreen(),
          ),
          GoRoute(
            path: '/market-prices',
            builder: (context, state) => const MarketPriceScreen(),
          ),
          GoRoute(
            path: '/contracts',
            builder: (context, state) => const ContractFarmingScreen(),
          ),
        ],
      ),
    ],
  );
});
