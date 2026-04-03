import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/farm_input.dart';

class InputLocalDataSource {
  final Database db;
  InputLocalDataSource(this.db);

  Future<void> saveInput(FarmInput input) async {
    await db.insert('farm_inputs', {
      'id': input.id,
      'name': input.name,
      'category': input.category,
      'supplier': input.supplier,
      'description': input.description,
      'price': input.price,
      'unit': input.unit,
      'bulkPrice': input.bulkPrice,
      'bulkMinQuantity': input.bulkMinQuantity,
      'isVerified': input.isVerified ? 1 : 0,
      'inStock': input.inStock ? 1 : 0,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FarmInput>> getInputs({String? category}) async {
    final rows =
        category != null
            ? await db.query(
              'farm_inputs',
              where: 'category = ?',
              whereArgs: [category],
            )
            : await db.query('farm_inputs');
    return rows
        .map(
          (r) => FarmInput(
            id: r['id'] as String,
            name: r['name'] as String,
            category: r['category'] as String,
            supplier: r['supplier'] as String? ?? '',
            description: r['description'] as String? ?? '',
            price: (r['price'] as num).toDouble(),
            unit: r['unit'] as String? ?? 'each',
            bulkPrice: (r['bulkPrice'] as num?)?.toDouble(),
            bulkMinQuantity: r['bulkMinQuantity'] as int?,
            isVerified: (r['isVerified'] as int?) == 1,
            inStock: (r['inStock'] as int?) == 1,
          ),
        )
        .toList();
  }

  Future<void> saveSubsidyApplication(SubsidyApplication app) async {
    await db.insert('subsidy_applications', {
      'id': app.id,
      'programId': app.programId,
      'programName': app.programName,
      'status': app.status,
      'appliedDate': app.appliedDate.toIso8601String(),
      'amountApproved': app.amountApproved,
      'notes': app.notes,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SubsidyApplication>> getMyApplications() async {
    final rows = await db.query(
      'subsidy_applications',
      orderBy: 'appliedDate DESC',
    );
    return rows
        .map(
          (r) => SubsidyApplication(
            id: r['id'] as String,
            programId: r['programId'] as String,
            programName: r['programName'] as String? ?? '',
            status: r['status'] as String? ?? 'applied',
            appliedDate: DateTime.parse(r['appliedDate'] as String),
            amountApproved: (r['amountApproved'] as num?)?.toDouble(),
            notes: r['notes'] as String?,
          ),
        )
        .toList();
  }
}
