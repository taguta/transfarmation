import 'package:sqflite/sqflite.dart';
import '../../features/farm_records/domain/entities/farm.dart';
import '../../features/financing/domain/entities/loan.dart';
import '../../features/farm_records/infrastructure/datasource/local/farm_sqlite.dart';
import '../../features/financing/infrastructure/datasource/local/loan_sqlite.dart';

class DataSeeder {
  final Database db;
  final FarmLocalDataSource farmLocal;
  final LoanLocalDataSource loanLocal;

  DataSeeder(this.db, this.farmLocal, this.loanLocal);

  Future<void> seedIfEmpty() async {
    final farmsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM farms'));
    if (farmsCount == 0) {
      final farms = [
      Farm(
        id: '1',
        name: 'Baba Tonde\'s Homestead',
        farmerId: 'farmer-001',
        totalHectares: 8.5,
        region: 'Region II',
        soilType: 'Red clay loam',
        waterSource: 'Borehole',
        latitude: -17.8292,
        longitude: 31.0522,
        address: 'Chihota, Mashonaland East',
        fields: [
          FarmField(
            id: 'f1',
            name: 'Munda weMaize',
            hectares: 3.0,
            currentCrop: 'Maize (SC 513)',
            season: '2024/25',
            status: 'growing',
            expenses: [
              FieldExpense(id: 'e1', category: 'seed', description: 'SeedCo SC 513 - 25kg', amount: 45, date: DateTime(2024, 10, 15)),
              FieldExpense(id: 'e2', category: 'fertilizer', description: 'Compound D - 200kg', amount: 120, date: DateTime(2024, 10, 15)),
              FieldExpense(id: 'e3', category: 'fertilizer', description: 'AN Top Dress - 150kg', amount: 85, date: DateTime(2024, 12, 5)),
              FieldExpense(id: 'e4', category: 'chemicals', description: 'Bullet (glyphosate)', amount: 20, date: DateTime(2024, 10, 10)),
              FieldExpense(id: 'e5', category: 'labour', description: 'Planting labour (5 people x 2 days)', amount: 50, date: DateTime(2024, 10, 16)),
            ],
          ),
          FarmField(
            id: 'f2',
            name: 'Soya Field',
            hectares: 2.0,
            currentCrop: 'Soya Beans (Dina)',
            season: '2024/25',
            status: 'growing',
            expenses: [
              FieldExpense(id: 'e6', category: 'seed', description: 'Dina soya - 60kg', amount: 65, date: DateTime(2024, 11, 1)),
              FieldExpense(id: 'e7', category: 'chemicals', description: 'Inoculant', amount: 15, date: DateTime(2024, 11, 1)),
              FieldExpense(id: 'e8', category: 'fertilizer', description: 'SSP - 100kg', amount: 55, date: DateTime(2024, 11, 1)),
            ],
          ),
          FarmField(
            id: 'f3',
            name: 'Vegetable Garden',
            hectares: 0.5,
            currentCrop: 'Tomatoes',
            season: '2024/25',
            status: 'harvested',
            yieldTonnes: 1.2,
            expenses: [
              FieldExpense(id: 'e9', category: 'seed', description: 'Rodade seedlings', amount: 12, date: DateTime(2024, 7, 15)),
              FieldExpense(id: 'e10', category: 'chemicals', description: 'Ridomil Gold', amount: 18, date: DateTime(2024, 8, 1)),
            ],
          ),
          FarmField(
            id: 'f4',
            name: 'Groundnut Plot',
            hectares: 1.5,
            currentCrop: 'Fallow',
            season: '2024/25',
            status: 'fallow',
          ),
        ],
        livestockRecords: [
          LivestockRecord(
            id: 'l1',
            type: 'cattle',
            tagNumber: 'MES-0045',
            name: 'Mhofu',
            breed: 'Mashona',
            sex: 'Bull',
            dateOfBirth: DateTime(2020, 3, 15),
            weight: 450,
            status: 'active',
            vetEvents: [
              VetEvent(id: 'v1', type: 'vaccination', description: 'Lumpy Skin Disease vaccine', date: DateTime(2024, 9, 20), administeredBy: 'Dr Moyo'),
              VetEvent(id: 'v2', type: 'dipping', description: 'Routine dipping - Amitraz', date: DateTime(2024, 11, 1)),
            ],
          ),
          LivestockRecord(
            id: 'l2',
            type: 'cattle',
            tagNumber: 'MES-0052',
            breed: 'Mashona x Brahman',
            sex: 'Cow',
            dateOfBirth: DateTime(2021, 8, 10),
            weight: 380,
            status: 'active',
            vetEvents: [
              VetEvent(id: 'v3', type: 'vaccination', description: 'Blackleg vaccine', date: DateTime(2024, 9, 20), administeredBy: 'Dr Moyo'),
            ],
          ),
          LivestockRecord(
            id: 'l3',
            type: 'poultry',
            breed: 'Road Runner',
            sex: 'Mixed',
            status: 'active',
            vetEvents: [
              VetEvent(id: 'v4', type: 'vaccination', description: 'Newcastle Disease - Lasota', date: DateTime(2024, 10, 5)),
            ],
          ),
          LivestockRecord(
            id: 'l4',
            type: 'goat',
            tagNumber: 'G-012',
            breed: 'Indigenous',
            sex: 'Female',
            dateOfBirth: DateTime(2022, 6, 1),
            weight: 35,
            status: 'active',
            vetEvents: [
              VetEvent(id: 'v5', type: 'deworming', description: 'Valbazen dewormer', date: DateTime(2024, 10, 15)),
            ],
          ),
        ],
      ),
      ];

      for (var farm in farms) {
        await farmLocal.saveFarm(farm);
        for (var field in farm.fields) {
          await farmLocal.saveField(farm.id, field);
        }
        for (var livestock in farm.livestockRecords) {
          await farmLocal.saveLivestock(farm.id, livestock);
        }
      }
    }

    final loansCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM loans'));
    if (loansCount == 0) {
      final loans = [
        Loan(
          id: 'loan-001',
          farmerId: 'farmer-001',
          amount: 1200,
          status: LoanStatus.approved,
          createdAt: DateTime(2026, 1, 15),
          isSynced: true,
          farmName: 'Moyo Family Farm',
          cropType: 'Maize',
          purpose: 'Input Purchase',
          repaymentPeriod: '6 months',
          farmSize: 12,
          amountRepaid: 480,
          lenderName: 'AgriFinance ZW',
        ),
        Loan(
          id: 'loan-002',
          farmerId: 'farmer-001',
          amount: 3500,
          status: LoanStatus.pending,
          createdAt: DateTime(2026, 3, 1),
          isSynced: true,
          farmName: 'Moyo Family Farm',
          cropType: 'Soya Beans',
          purpose: 'Irrigation',
          repaymentPeriod: '12 months',
          farmSize: 12,
          amountRepaid: 0,
          lenderName: 'FarmFund Africa',
        ),
        Loan(
          id: 'loan-003',
          farmerId: 'farmer-001',
          amount: 800,
          status: LoanStatus.completed,
          createdAt: DateTime(2025, 11, 1),
          isSynced: true,
          farmName: 'Moyo Family Farm',
          cropType: 'Soya Beans',
          purpose: 'Input Purchase',
          repaymentPeriod: '6 months',
          farmSize: 12,
          amountRepaid: 800,
          lenderName: 'ZimAgri Micro',
        ),
        Loan(
          id: 'loan-004',
          farmerId: 'farmer-001',
          amount: 450,
          status: LoanStatus.rejected,
          createdAt: DateTime(2025, 10, 10),
          isSynced: true,
          farmName: 'Moyo Family Farm',
          cropType: 'Maize',
          purpose: 'Equipment',
          repaymentPeriod: '3 months',
          farmSize: 12,
          amountRepaid: 0,
          lenderName: 'AgriFinance ZW',
        ),
      ];

      for (var loan in loans) {
        await loanLocal.saveLoan(loan);
      }
    }
  }
}
