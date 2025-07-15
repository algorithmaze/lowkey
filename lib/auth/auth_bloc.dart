import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:local_auth/local_auth.dart';
import 'package:lowkey/contacts/user_repository.dart';
import 'package:uuid/uuid.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final supabase_flutter.SupabaseClient _supabaseClient;
  final LocalAuthentication _localAuth;
  final UserRepository _userRepository;
  final Uuid _uuid = const Uuid();

  AuthBloc({
    required supabase_flutter.SupabaseClient supabaseClient,
    required LocalAuthentication localAuth,
    required UserRepository userRepository,
  })  : _supabaseClient = supabaseClient,
        _localAuth = localAuth,
        _userRepository = userRepository,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthCheckStatus>(_onAuthCheckStatus);
    on<AuthBiometricLoginRequested>(_onAuthBiometricLoginRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final supabase_flutter.AuthResponse response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      if (response.user != null) {
        emit(AuthAuthenticated(user: response.user!));
      } else {
        emit(const AuthError(message: 'Login failed: User not found.'));
      }
    } on supabase_flutter.AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _supabaseClient.auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = _supabaseClient.auth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthBiometricLoginRequested(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;
      final bool isSupported = await _localAuth.isDeviceSupported();

      if (canAuthenticate && isSupported) {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to login to Lowkey',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (didAuthenticate) {
          // Assuming a successful biometric authentication means the user is already
          // logged in via Supabase or we need to handle a silent re-authentication.
          // For simplicity, we'll check the current user.
          final user = _supabaseClient.auth.currentUser;
          if (user != null) {
            emit(AuthAuthenticated(user: user));
          } else {
            emit(const AuthError(message: 'Biometric login successful, but no active Supabase session found. Please login with email/password.'));
          }
        } else {
          emit(const AuthError(message: 'Biometric authentication failed or cancelled.'));
        }
      } else {
        emit(const AuthError(message: 'Biometrics not available or not set up on your device.'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final supabase_flutter.AuthResponse response =
          await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
        data: {'username': event.username},
      );
      if (response.user == null) {
        emit(const AuthError(message: 'Signup failed'));
        return;
      }
      // The profile is now created by a trigger, so we don't need to call this.
      // await _userRepository.createUserProfile(
      //   userId: response.user!.id,
      //   username: event.username,
      // );
      emit(AuthAuthenticated(user: response.user!));
    } on supabase_flutter.AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}