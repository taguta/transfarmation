import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/app_prefs.dart';

class WorkspaceAction {
  final String label;
  final IconData icon;
  final String route;
  const WorkspaceAction(this.label, this.icon, this.route);
}

/// A "lens" on the shared data core: the tools and metrics one role needs.
/// Adding a workspace is configuration, not a new app.
class Workspace {
  final String role;
  final String name;
  final String tagline;
  final IconData icon;
  final List<WorkspaceAction> actions;

  const Workspace({
    required this.role,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.actions,
  });
}

const workspaces = <String, Workspace>{
  'Farmer': Workspace(
    role: 'Farmer',
    name: 'My Farm',
    tagline: 'Plan, record, borrow and sell',
    icon: Icons.agriculture_rounded,
    actions: [
      WorkspaceAction('Feasibility\nPlan', Icons.request_quote_rounded, '/feasibility'),
      WorkspaceAction('Farm\nLedger', Icons.menu_book_rounded, '/ledger'),
      WorkspaceAction('My\nStatement', Icons.receipt_long_rounded, '/statement'),
      WorkspaceAction('Apply\nLoan', Icons.add_card_rounded, '/financing/apply'),
      WorkspaceAction('Sell\nProduce', Icons.sell_rounded, '/marketplace/sell'),
      WorkspaceAction('My\nFarm', Icons.landscape_rounded, '/farm-records'),
      WorkspaceAction('AI\nDiagnosis', Icons.document_scanner_rounded, '/diagnosis'),
      WorkspaceAction('Ask\nExpert', Icons.support_agent_rounded, '/expert'),
      WorkspaceAction('Weather\nAlerts', Icons.cloud_rounded, '/weather'),
      WorkspaceAction('Market\nPrices', Icons.trending_up_rounded, '/market-prices'),
      WorkspaceAction('Contracts', Icons.handshake_rounded, '/contracts'),
      WorkspaceAction('Farm\nInputs', Icons.store_rounded, '/inputs'),
      WorkspaceAction('Savings\nGroups', Icons.group_rounded, '/savings'),
      WorkspaceAction('Group\nBuying', Icons.shopping_cart_rounded, '/group-buying'),
      WorkspaceAction('Labour', Icons.engineering_rounded, '/labor-management'),
      WorkspaceAction('Traceability', Icons.qr_code_2_rounded, '/traceability'),
      WorkspaceAction('Knowledge\nBase', Icons.menu_book_outlined, '/knowledge'),
    ],
  ),
  'Lender': Workspace(
    role: 'Lender',
    name: 'Credit Desk',
    tagline: 'Loan book, repayments and risk',
    icon: Icons.account_balance_rounded,
    actions: [
      WorkspaceAction('Credit\nDesk', Icons.fact_check_rounded, '/credit-desk'),
      WorkspaceAction('Loan\nBook', Icons.account_balance_wallet_rounded, '/financing'),
      WorkspaceAction('Loan\nOffers', Icons.local_offer_rounded, '/financing/offers'),
      WorkspaceAction('Repayments', Icons.payments_rounded, '/financing/repayments'),
      WorkspaceAction('Market\nPrices', Icons.trending_up_rounded, '/market-prices'),
      WorkspaceAction('Weather\nRisk', Icons.cloud_rounded, '/weather'),
      WorkspaceAction('Alerts', Icons.notifications_rounded, '/notifications'),
    ],
  ),
  'Buyer': Workspace(
    role: 'Buyer',
    name: 'Buyer Portal',
    tagline: 'Source, contract and trace produce',
    icon: Icons.storefront_rounded,
    actions: [
      WorkspaceAction('Browse\nProduce', Icons.storefront_rounded, '/marketplace'),
      WorkspaceAction('Contracts', Icons.handshake_rounded, '/contracts'),
      WorkspaceAction('Market\nPrices', Icons.trending_up_rounded, '/market-prices'),
      WorkspaceAction('Traceability', Icons.qr_code_2_rounded, '/traceability'),
      WorkspaceAction('Group\nBuying', Icons.shopping_cart_rounded, '/group-buying'),
      WorkspaceAction('Alerts', Icons.notifications_rounded, '/notifications'),
    ],
  ),
  'Expert': Workspace(
    role: 'Expert',
    name: 'Advisory Desk',
    tagline: 'Advise farmers at scale',
    icon: Icons.science_rounded,
    actions: [
      WorkspaceAction('Farmer\nChats', Icons.support_agent_rounded, '/expert'),
      WorkspaceAction('AI\nDiagnosis', Icons.document_scanner_rounded, '/diagnosis'),
      WorkspaceAction('Knowledge\nBase', Icons.menu_book_outlined, '/knowledge'),
      WorkspaceAction('Community', Icons.forum_rounded, '/community'),
      WorkspaceAction('Weather\nAlerts', Icons.cloud_rounded, '/weather'),
      WorkspaceAction('Alerts', Icons.notifications_rounded, '/notifications'),
    ],
  ),
};

class WorkspaceState {
  final List<String> roles;
  final String active;
  const WorkspaceState(this.roles, this.active);

  Workspace get current => workspaces[active] ?? workspaces['Farmer']!;
}

/// One identity, many roles: the user holds a set of roles and switches the
/// active workspace without signing out. Persisted on the device.
class WorkspaceNotifier extends StateNotifier<WorkspaceState> {
  WorkspaceNotifier() : super(const WorkspaceState(['Farmer'], 'Farmer')) {
    _load();
  }

  Future<void> _load() async {
    final roles = await AppPrefs.roles;
    final active = await AppPrefs.role;
    final valid = roles.where(workspaces.containsKey).toList();
    if (valid.isEmpty) valid.add('Farmer');
    state = WorkspaceState(valid, valid.contains(active) ? active : valid.first);
  }

  Future<void> switchTo(String role) async {
    if (!state.roles.contains(role)) return;
    state = WorkspaceState(state.roles, role);
    await AppPrefs.setRole(role);
  }

  Future<void> addRole(String role) async {
    if (!workspaces.containsKey(role) || state.roles.contains(role)) return;
    final roles = [...state.roles, role];
    state = WorkspaceState(roles, role);
    await AppPrefs.setRoles(roles);
    await AppPrefs.setRole(role);
  }
}

final workspaceProvider =
    StateNotifierProvider<WorkspaceNotifier, WorkspaceState>(
      (ref) => WorkspaceNotifier(),
    );
