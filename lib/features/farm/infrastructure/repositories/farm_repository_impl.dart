import '../../domain/entities/farm.dart';
import '../../domain/repositories/farm_repository.dart';
import '../datasource/farm_remote_datasource.dart';
import '../datasource/farm_local_datasource.dart';

class FarmRepositoryImpl implements FarmRepository {
  final FarmRemoteDataSource remoteDataSource;
  final FarmLocalDataSource localDataSource;

  FarmRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<Farm?> getFarm(String id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final localFarm = await localDataSource.getCachedFarm(id);
      if (localFarm != null) return localFarm;
    }
    // Logic: var remoteFarm = await remoteDataSource.getFarm(id);
    // Logic: await localDataSource.cacheFarm(remoteFarm);
    // return remoteFarm;
    return null;
  }
}
