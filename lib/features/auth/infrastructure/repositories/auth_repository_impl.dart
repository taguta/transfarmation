import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity?> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) {
    return remoteDataSource.signInWithEmail(email, password);
  }

  @override
  Future<UserEntity> register(String email, String password, String name) {
    return remoteDataSource.register(email, password, name);
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }
}
