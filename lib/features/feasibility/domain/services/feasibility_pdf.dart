import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../entities/feasibility_plan.dart';
import 'feasibility_calculator.dart';

/// Builds a lender-ready PDF of a feasibility plan: a plain-language summary,
/// the assumptions behind it and the 24-month cash flow.
///
/// Uses only the built-in PDF fonts, so text is kept to plain ASCII.
class FeasibilityPdf {
  static final _money = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

  static Future<Uint8List> build({
    required FeasibilityInputs inputs,
    required FeasibilityResult result,
    String farmerName = '',
    DateTime? generatedAt,
  }) async {
    final doc = pw.Document(title: 'Farm Feasibility Plan - ${inputs.crop}');
    final when = DateFormat.yMMMd().format(generatedAt ?? DateTime.now());
    final cycles = FeasibilityCalculator.horizonMonths ~/
        (cropTemplates[inputs.crop] ?? tobaccoTemplate).cycleMonths;

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

    final verdict = result.bankable
        ? 'On these numbers the plan covers its costs and the loan repayments.'
        : 'On these numbers the plan has weaknesses a lender will notice (see below).';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => [
          pw.Text('Farm Feasibility Plan', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.Text('${inputs.crop} - ${inputs.hectares} hectare(s) - 24 months'),
          if (farmerName.isNotEmpty) pw.Text('Prepared for: $farmerName'),
          pw.Text('Generated on $when with Transfarmation'),

          h('In plain words'),
          pw.Text(
            'The farmer plans to grow ${inputs.hectares} hectare(s) of ${inputs.crop} '
            'over $cycles season(s) and expects to earn about ${_money.format(result.totalRevenue)}. '
            'Growing costs are about ${_money.format(result.totalCosts)}'
            '${result.totalLevies > 0 ? ' and statutory levies about ${_money.format(result.totalLevies)}' : ''}. '
            '${inputs.loanAmount > 0 ? 'A loan of ${_money.format(inputs.loanAmount)} at ${inputs.annualInterestPct}% a year would be repaid over ${inputs.loanTermMonths} months, starting after ${inputs.graceMonths} months. Total repayments are about ${_money.format(result.totalRepayment)}. ' : 'No loan is planned. '}'
            'After everything, the farmer expects to keep about ${_money.format(result.netProfit)}. $verdict',
          ),

          h('Key numbers'),
          kv('Revenue (24 months)', _money.format(result.totalRevenue)),
          kv('Production costs', _money.format(result.totalCosts)),
          kv('Statutory levies', _money.format(result.totalLevies)),
          kv('Loan repayments', _money.format(result.totalRepayment)),
          kv('  of which interest', _money.format(result.totalInterest)),
          kv('Net profit', _money.format(result.netProfit)),
          kv('Debt service cover', result.dscr.isFinite ? result.dscr.toStringAsFixed(2) : 'No loan'),
          kv('Lowest cash balance', _money.format(result.minCash)),
          kv('Break-even price', '${_money.format(result.breakEvenPricePerKg)}/kg (expected ${inputs.pricePerKg}/kg)'),

          if (result.warnings.isNotEmpty) ...[
            h('Points to note'),
            for (final w in result.warnings) pw.Text('- $w'),
          ],

          h('Assumptions'),
          kv('Expected yield', '${inputs.yieldKgPerHa.toStringAsFixed(0)} kg per hectare'),
          kv('Expected price', '\$${inputs.pricePerKg} per kg'),
          kv('Own cash put in', _money.format(inputs.ownContribution)),
          pw.SizedBox(height: 4),
          pw.Text('Production cost per hectare, per season:'),
          for (final e in inputs.costPerHa.entries) kv('  ${e.key}', _money.format(e.value)),

          h('Month-by-month cash flow'),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerRight,
            headerAlignment: pw.Alignment.centerRight,
            headers: ['Month', 'Money in', 'Costs & levies', 'Loan', 'Cash balance'],
            data: [
              for (final m in result.months)
                [
                  DateFormat('MMM yyyy').format(m.month),
                  _money.format(m.revenue),
                  _money.format(m.costs + m.levies),
                  _money.format(m.loanDraw - m.repayment),
                  _money.format(m.closingCash),
                ],
            ],
          ),

          pw.SizedBox(height: 16),
          pw.Text(
            'Important: these are the farmer\'s own estimates and standard crop figures, not audited '
            'results. A lender should confirm the numbers before lending. This document is not a loan '
            'offer or a contract.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );

    return doc.save();
  }
}
