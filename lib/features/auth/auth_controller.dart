import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';

class AuthUIState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const AuthUIState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  AuthUIState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return AuthUIState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AuthController extends Notifier<AuthUIState> {
  late final AuthService _authService;

  @override
  AuthUIState build() {
    _authService = ref.watch(authServiceProvider);
    return const AuthUIState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        // User cancelled flow
        state = state.copyWith(isLoading: false);
        return false;
      }
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _authService.signOut();
    state = const AuthUIState();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthUIState>(AuthController.new);
