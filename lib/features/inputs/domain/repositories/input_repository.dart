import '../entities/farm_input.dart';

abstract class InputRepository {
  Future<List<FarmInput>> getInputs({String? category});
  Future<void> applyForSubsidy(SubsidyApplication application);
  Future<List<SubsidyApplication>> getMyApplications(String farmerId);
  Future<List<SubsidyProgram>> getSubsidyPrograms();
}
