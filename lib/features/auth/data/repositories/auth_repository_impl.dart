import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart' as entity;
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<Either<Failure, entity.User>> login(
    String email,
    String password,
  ) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = UserModel.fromJson(response.user!.userMetadata!);
    return Right(user.toEntity());
  }

  @override
  Future<Either<Failure, entity.User>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      final user = UserModel.fromJson(response.user!.userMetadata!);
      return Right(user.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
