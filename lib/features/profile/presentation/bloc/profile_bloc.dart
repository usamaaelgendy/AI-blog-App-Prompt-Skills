import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user.dart';

// Events
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {
  final String userId;
  LoadProfile(this.userId);
}

// States
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  ProfileLoaded(this.user);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    // TODO: Load profile from repository
    emit(ProfileLoaded(User(
      id: event.userId,
      name: 'Test User',
      email: 'test@example.com',
      avatarUrl: 'https://i.pravatar.cc/150',
    )));
  }
}
