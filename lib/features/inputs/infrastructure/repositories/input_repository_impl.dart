import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/farm_input.dart';
import '../../domain/repositories/input_repository.dart';
import '../datasource/local/input_sqlite.dart';
import '../datasource/remote/input_firestore.dart';

class InputRepositoryImpl implements InputRepository {
  final InputLocalDataSource local;
  final InputRemoteDataSource remote;
  final Database db;

  InputRepositoryImpl(this.local, this.remote, this.db);

  @override
  Future<List<FarmInput>> getInputs({String? category}) async {
    try {
      final inputs = await remote.fetchInputs(category: category);
      for (final i in inputs) {
        await local.saveInput(i);
      }
      return inputs;
    } catch (_) {
      return local.getInputs(category: category);
    }
  }

  @override
  Future<void> applyForSubsidy(SubsidyApplication application) async {
    await local.saveSubsidyApplication(application);
    try {
      await remote.sendSubsidyApplication(application);
    } catch (_) {
      await db.insert('sync_queue', {
        'id': application.id,
        'type': 'subsidy_application',
        'payload': jsonEncode({
          'id': application.id,
          'programId': application.programId,
          'programName': application.programName,
          'status': application.status,
          'appliedDate': application.appliedDate.toIso8601String(),
        }),
        'retryCount': 0,
      });
    }
  }

  @override
  Future<List<SubsidyApplication>> getMyApplications(String farmerId) {
    return local.getMyApplications();
  }

  @override
  Future<List<SubsidyProgram>> getSubsidyPrograms() async {
    // Subsidy programs are fetched from Firestore, no local cache needed for MVP
    return [];
  }
}
