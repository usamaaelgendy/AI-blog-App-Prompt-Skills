import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(String name, String email, String password);
  Future<Either<Failure, void>> resetPassword(String email);
  Future<void> logout();
}
