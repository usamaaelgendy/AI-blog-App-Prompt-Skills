import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, User>> call(LoginParams params) {
    if (params.email.isEmpty) {
      return Future.value(const Left(ValidationFailure('Email is required')));
    }
    if (params.password.length < 6) {
      return Future.value(const Left(ValidationFailure('Password must be at least 6 characters')));
    }
    return _repository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}
