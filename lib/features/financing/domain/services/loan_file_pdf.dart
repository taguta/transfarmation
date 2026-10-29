import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../ledger/domain/entities/ledger_entry.dart';
import '../../../ledger/domain/farmer_statement.dart';
import '../entities/loan.dart';

/// A loan file a lender can read in a few minutes: who is asking, for what,
/// what the farmer's own records show, and what the farmer chose to share.
///
/// Everything comes from the farmer's own ledger and loan application, and the
/// file says so. It is not a credit score or a guarantee. Uses only the
/// built-in PDF fonts, so text is kept to plain ASCII.
class LoanFilePdf {
  static final _money = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

  static Future<Uint8List> build({
    required Loan loan,
    required FarmerStatement statement,
    required List<LedgerEntry> entries,
    String farmerName = '',
    String? sharedWith,
    DateTime? generatedAt,
  }) async {
    final doc = pw.Document(title: 'Loan file - ${loan.id}');
    final when = DateFormat.yMMMd().format(generatedAt ?? DateTime.now());

    pw.Widget h(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
      child: pw.Text(t, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
    );
    pw.Widget kv(String a, String b) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(a), pw.Text(b, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))],
      ),
    );

    final dated = entries.map((e) => e.date).toList()..sort();
    final records = entries.isEmpty
        ? 'No ledger entries yet. The figures below are therefore empty.'
        : '${entries.length} ledger entries from ${DateFormat.yMMMd().format(dated.first)} '
            'to ${DateFormat.yMMMd().format(dated.last)}.';

    final plan = loan.planSummary;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => [
          pw.Text('Loan File', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          if (farmerName.isNotEmpty) pw.Text('Applicant: $farmerName'),
          pw.Text('Reference: ${loan.id}'),
          pw.Text('Generated on $when with Transfarmation'),

          h('Request'),
          kv('Amount requested', _money.format(loan.amount)),
          kv('Status', loan.status.name),
          if (loan.purpose != null) kv('Purpose', loan.purpose!),
          if (loan.repaymentPeriod != null) kv('Repayment period', loan.repaymentPeriod!),
          if (loan.lenderName != null) kv('Lender', loan.lenderName!),
          if (loan.amountRepaid > 0) kv('Repaid so far', _money.format(loan.amountRepaid)),

          h('Farm'),
          if (loan.farmName != null) kv('Farm', loan.farmName!),
          if (loan.cropType != null) kv('Main crop', loan.cropType!),
          if (loan.farmSize != null) kv('Farm size', '${loan.farmSize} ha'),
          if (loan.province != null) kv('Province', loan.province!),
          if (loan.farmingType != null) kv('Farming type', loan.farmingType!),

          h('What the farmer\'s records show'),
          pw.Text(records),
          pw.SizedBox(height: 4),
          kv('Money in', _money.format(statement.income)),
          kv('Money spent', _money.format(statement.costs)),
          kv('Owed on other active loans', _money.format(statement.loanOutstanding)),
          kv(
            statement.isOwing ? 'Position if settled today (owing)' : 'Position if settled today',
            _money.format(statement.takeHome),
          ),
          if (statement.costsByCategory.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text('Largest costs:'),
            for (final c in statement.costsByCategory.entries.take(5))
              kv('  ${c.key}', _money.format(c.value)),
          ],

          if (plan != null && plan.isNotEmpty) ...[
            h('Feasibility plan shared by the farmer'),
            for (final e in plan.entries) kv(e.key, '${e.value}'),
          ],

          h('Sharing'),
          pw.Text(
            sharedWith == null
                ? 'The farmer has not named a recipient for this file.'
                : 'Shared by the farmer with $sharedWith on $when.',
          ),

          pw.SizedBox(height: 16),
          pw.Text(
            'Important: these figures come from entries the farmer made in their own records and have not '
            'been audited or verified by Transfarmation. A lender should confirm them before lending. This '
            'document is not a credit score, a loan offer or a contract.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );

    return doc.save();
  }
}
