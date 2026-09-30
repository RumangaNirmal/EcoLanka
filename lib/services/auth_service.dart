import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Authentication States for state management
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});
}

class CodeSent extends AuthState {
  final String verificationId;
  final int? resendToken;
  final String phoneNumber;

  const CodeSent({
    required this.verificationId,
    this.resendToken,
    required this.phoneNumber,
  });
}

class Authenticated extends AuthState {
  final AppUser user;
  const Authenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

/// Unified User model supporting both Firebase users and mock mode
class AppUser {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final String role;
  final bool isMock;

  const AppUser({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.role = 'user',
    this.isMock = false,
  });

  factory AppUser.fromFirebase(User user, {String role = 'user'}) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      role: role,
      isMock: false,
    );
  }

  factory AppUser.mock({String? phone, String? email}) {
    return AppUser(
      uid: 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: phone ?? '+94771234567',
      email: email ?? 'tester@reshare.lk',
      displayName: 'ReShare Tester',
      photoUrl: null,
      role: 'user',
      isMock: true,
    );
  }
}

class AuthService {
  /// Toggle flag for testing without Firebase credentials
  static bool useMockMode = true;

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  FirebaseAuth? get firebaseAuth {
    try {
      return _auth;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get firestore {
    try {
      return _firestore;
    } catch (_) {
      return null;
    }
  }

  /// Check current user
  AppUser? get currentUser {
    if (useMockMode) return null;
    final user = _auth.currentUser;
    return user != null ? AppUser.fromFirebase(user) : null;
  }

  /// Sends 6-digit OTP to mobile number
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String errorMessage) onError,
    required Function(AppUser user) onAutoVerified,
    int? forceResendingToken,
  }) async {
    if (useMockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      // In mock mode, any valid 9-10 digit number proceeds
      onCodeSent('mock_verification_id_for_$phoneNumber', null);
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCred = await _auth.signInWithCredential(credential);
            if (userCred.user != null) {
              await _syncUserToFirestore(userCred.user!);
              onAutoVerified(AppUser.fromFirebase(userCred.user!));
            }
          } catch (e) {
            onError(e.toString());
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Phone verification failed (${e.code}).');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout reached
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Verifies 6-digit OTP
  Future<AppUser> verifyOtp({
    required String verificationId,
    required String smsCode,
    String? phoneNumber,
  }) async {
    if (useMockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (smsCode == '123456') {
        return AppUser.mock(phone: phoneNumber);
      } else {
        throw Exception('Invalid OTP. In mock mode, enter 123456.');
      }
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCred = await _auth.signInWithCredential(credential);
      if (userCred.user == null) {
        throw Exception('User authentication failed.');
      }
      await _syncUserToFirestore(userCred.user!);
      return AppUser.fromFirebase(userCred.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw Exception('The OTP code entered is incorrect.');
      } else if (e.code == 'session-expired') {
        throw Exception('The OTP code has expired. Please request a new one.');
      }
      throw Exception(e.message ?? 'Verification failed.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Google Sign-In using GoogleAuthProvider
  Future<AppUser> signInWithGoogle() async {
    if (useMockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return AppUser.mock(email: 'google.mock@reshare.lk');
    }

    try {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      final UserCredential userCred;
      if (kIsWeb) {
        userCred = await _auth.signInWithPopup(googleProvider);
      } else {
        userCred = await _auth.signInWithProvider(googleProvider);
      }

      if (userCred.user == null) {
        throw Exception('Google sign-in was cancelled or failed.');
      }
      await _syncUserToFirestore(userCred.user!);
      return AppUser.fromFirebase(userCred.user!);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Google Sign-In failed.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Email Sign-In (Supports password or passwordless link)
  Future<AppUser> signInWithEmail({
    required String email,
    String? password,
    bool isPasswordless = false,
  }) async {
    if (useMockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return AppUser.mock(email: email);
    }

    try {
      if (isPasswordless) {
        final actionCodeSettings = ActionCodeSettings(
          url: 'https://reshare-a047d.firebaseapp.com/finishSignUp',
          handleCodeInApp: true,
          androidPackageName: 'com.ecolanka.ecolanka',
          androidInstallApp: true,
          androidMinimumVersion: '12',
        );
        await _auth.sendSignInLinkToEmail(
          email: email,
          actionCodeSettings: actionCodeSettings,
        );
        throw Exception('A sign-in link has been sent to $email. Please check your inbox.');
      } else {
        UserCredential userCred;
        try {
          userCred = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password ?? '',
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            userCred = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password ?? '',
            );
          } else {
            rethrow;
          }
        }
        if (userCred.user == null) throw Exception('Email sign-in failed.');
        await _syncUserToFirestore(userCred.user!);
        return AppUser.fromFirebase(userCred.user!);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Email sign-in failed.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Sync user document to Firestore users collection
  Future<void> _syncUserToFirestore(User user) async {
    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final doc = await userDocRef.get();
      if (!doc.exists) {
        await userDocRef.set({
          'uid': user.uid,
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'displayName': user.displayName,
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'role': 'user',
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore sync notice: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!useMockMode) {
      await _auth.signOut();
    }
  }
}
