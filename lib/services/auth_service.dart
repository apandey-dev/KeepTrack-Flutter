import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirestoreService firestoreService;

  AuthService({
    FirebaseAuth? auth,
    required this.firestoreService,
  })  : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Sign in with Email and Password with clean human-readable error messages
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await _syncUserToFirestore(user);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during sign in. Please try again.';
    }
  }

  /// Sign up with Email and Password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        if (displayName != null && displayName.trim().isNotEmpty) {
          await user.updateDisplayName(displayName.trim());
        }
        await _syncUserToFirestore(user, nameOverride: displayName);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during registration. Please try again.';
    }
  }

  /// Google Sign In flow with real profile synchronization
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final authz = await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz?.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final googleName = googleUser.displayName;
        final googlePhoto = googleUser.photoUrl;

        if (googleName != null && googleName.isNotEmpty) {
          try {
            await user.updateDisplayName(googleName);
          } catch (_) {}
        }
        if (googlePhoto != null && googlePhoto.isNotEmpty) {
          try {
            await user.updatePhotoURL(googlePhoto);
          } catch (_) {}
        }
        try {
          await user.reload();
        } catch (_) {}

        final refreshedUser = _auth.currentUser ?? user;
        await _syncUserToFirestore(
          refreshedUser,
          nameOverride: googleName ?? refreshedUser.displayName,
          photoOverride: googlePhoto ?? refreshedUser.photoURL,
        );
      }
      return userCredential;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User cancelled the sign-in flow
        return null;
      }
      throw 'Google Sign-In failed: ${e.description ?? e.code.name}';
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google Sign-In failed: ${e.toString()}';
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  /// Sign out from both Firebase and Google provider
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);
    } catch (e) {
      await _auth.signOut();
    }
  }

  /// Helper to record profile data in Firestore `users/{uid}`
  Future<void> _syncUserToFirestore(
    User user, {
    String? nameOverride,
    String? photoOverride,
  }) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: nameOverride ?? user.displayName,
      photoUrl: photoOverride ?? user.photoURL,
      lastLoginAt: DateTime.now(),
    );
    await firestoreService.saveOrUpdateUserProfile(userModel);
  }

  /// Human-friendly error translation
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account exists with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please verify your credentials.';
      case 'email-already-in-use':
        return 'This email address is already registered. Try signing in.';
      case 'invalid-email':
        return 'The email address format is not valid.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This user account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network connection error. Check your internet connection.';
      case 'popup-closed-by-user':
        return 'Sign in was cancelled.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return AuthService(firestoreService: firestore);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userProfileProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).watchUserProfile(uid);
});
