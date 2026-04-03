import '../entities/farming_contract.dart';

abstract class ContractRepository {
  Future<List<FarmingContract>> getContracts({
    String? region,
    String? commodity,
  });
  Future<void> applyToContract(String contractId, String farmerId);
  Future<List<FarmingContract>> getMyContracts(String farmerId);
}
