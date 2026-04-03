import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/farming_contract.dart';
import '../../domain/repositories/contract_repository.dart';
import '../datasource/local/contract_sqlite.dart';
import '../datasource/remote/contract_firestore.dart';

class ContractRepositoryImpl implements ContractRepository {
  final ContractLocalDataSource local;
  final ContractRemoteDataSource remote;
  final Database db;

  ContractRepositoryImpl(this.local, this.remote, this.db);

  @override
  Future<List<FarmingContract>> getContracts({String? region, String? commodity}) async {
    try {
      final contracts = await remote.fetchContracts(region: region, commodity: commodity);
      for (final c in contracts) {
        await local.saveContract(c);
      }
      return contracts;
    } catch (_) {
      return local.getContracts();
    }
  }

  @override
  Future<void> applyToContract(String contractId, String farmerId) async {
    // Usually we save a local copy of 'Application' here before sending remote.
    // For now we persist it correctly before network request.
    try {
      await remote.applyToContract(contractId, farmerId);
    } catch (_) {
      await db.insert('sync_queue', {
        'id': '\${contractId}_\$farmerId',
        'type': 'contract_application',
        'payload': jsonEncode({
          'contractId': contractId,
          'farmerId': farmerId,
        }),
        'retryCount': 0,
      });
    }
  }

  @override
  Future<List<FarmingContract>> getMyContracts(String farmerId) {
    return local.getContracts();
  }
}
