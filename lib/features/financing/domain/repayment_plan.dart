import 'entities/loan.dart';

enum InstalmentStatus { paid, partial, overdue, upcoming }

class Instalment {
  final int number;
  final DateTime dueDate;
  final double amount;
  final double paid;
  final InstalmentStatus status;

  const Instalment({
    required this.number,
    required this.dueDate,
    required this.amount,
    required this.paid,
    required this.status,
  });

  double get remaining => (amount - paid).clamp(0, amount);
}

/// An even split of a loan's principal over its repayment period, with the
/// payments the farmer has recorded applied to the earliest instalments first.
///
/// Interest and fees are set by the lender and are not stored on the loan, so
/// they are not included. This is a guide for planning, not the lender's
/// statement.
class RepaymentPlan {
  final List<Instalment> instalments;
  final double totalPaid;
  final double principal;

  const RepaymentPlan._(this.instalments, this.totalPaid, this.principal);

  double get outstanding => (principal - totalPaid).clamp(0, principal);
  bool get isPaidOff => principal > 0 && outstanding < 0.005;

  /// The first instalment that is not fully paid, or null when paid off.
  Instalment? get next {
    for (final i in instalments) {
      if (i.status != InstalmentStatus.paid) return i;
    }
    return null;
  }

  int get overdueCount =>
      instalments.where((i) => i.status == InstalmentStatus.overdue).length;

  /// Reads "12 months", "6", "18 Months" etc. Falls back to 12 when unclear.
  static int monthsFrom(String? period) {
    final match = RegExp(r'\d+').firstMatch(period ?? '');
    final months = match == null ? 12 : int.parse(match.group(0)!);
    return months.clamp(1, 120);
  }

  /// The first instalment falls one month after the loan was applied for.
  static DateTime dueDateFor(DateTime start, int number) {
    final monthIndex = start.month - 1 + number;
    final year = start.year + monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    // Day 28 at most, so every month has the date.
    final day = start.day > 28 ? 28 : start.day;
    return DateTime(year, month, day);
  }

  factory RepaymentPlan.forLoan(
    Loan loan,
    List<LoanPayment> payments, {
    DateTime? now,
  }) {
    return RepaymentPlan.build(
      principal: loan.amount,
      months: monthsFrom(loan.repaymentPeriod),
      start: loan.createdAt,
      paid: payments.fold<double>(0, (s, p) => s + p.amount),
      now: now ?? DateTime.now(),
    );
  }

  factory RepaymentPlan.build({
    required double principal,
    required int months,
    required DateTime start,
    required double paid,
    required DateTime now,
  }) {
    // Work in cents so the instalments always add back up to the principal.
    final totalCents = (principal * 100).round();
    final baseCents = totalCents ~/ months;
    var left = (paid * 100).round();
    final list = <Instalment>[];

    for (var n = 1; n <= months; n++) {
      final cents = n == months ? totalCents - baseCents * (months - 1) : baseCents;
      final applied = left < cents ? left : cents;
      left -= applied;
      final due = dueDateFor(start, n);
      final InstalmentStatus status;
      if (applied >= cents) {
        status = InstalmentStatus.paid;
      } else if (due.isBefore(DateTime(now.year, now.month, now.day))) {
        status = InstalmentStatus.overdue;
      } else if (applied > 0) {
        status = InstalmentStatus.partial;
      } else {
        status = InstalmentStatus.upcoming;
      }
      list.add(Instalment(
        number: n,
        dueDate: due,
        amount: cents / 100,
        paid: applied / 100,
        status: status,
      ));
    }
    return RepaymentPlan._(list, paid, principal);
  }
}
