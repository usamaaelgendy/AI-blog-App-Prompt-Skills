import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';

// Events
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;

  AuthBloc(this._loginUseCase) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
