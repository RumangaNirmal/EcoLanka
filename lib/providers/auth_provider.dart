import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

export '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = const AuthInitial();
  AppUser? _currentUser;
  String _phoneNumber = '';
  String? _verificationId;
  int? _resendToken;

  AuthState get state => _state;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _state is AuthLoading;
  bool get useMockMode => AuthService.useMockMode;
  String get phoneNumber => _phoneNumber;
  String? get verificationId => _verificationId;
  String? get errorMessage => (_state is AuthError) ? (_state as AuthError).message : null;

  void toggleMockMode(bool enabled) {
    AuthService.useMockMode = enabled;
    notifyListeners();
  }

  void resetState() {
    _state = const AuthInitial();
    notifyListeners();
  }

  /// Request OTP for mobile number
  Future<bool> sendOtp(String rawPhone, {int? forceResendingToken}) async {
    _state = const AuthLoading(message: 'Sending verification code...');
    _phoneNumber = rawPhone;
    notifyListeners();

    final completer = Completer<bool>();

    await _authService.sendOtp(
      phoneNumber: rawPhone,
      forceResendingToken: forceResendingToken ?? _resendToken,
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        _state = CodeSent(
          verificationId: verificationId,
          resendToken: resendToken,
          phoneNumber: rawPhone,
        );
        notifyListeners();
        if (!completer.isCompleted) completer.complete(true);
      },
      onError: (errorMessage) {
        _state = AuthError(errorMessage);
        notifyListeners();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAutoVerified: (user) {
        _currentUser = user;
        _state = Authenticated(user);
        notifyListeners();
        if (!completer.isCompleted) completer.complete(true);
      },
    );

    return completer.future;
  }

  /// Verify 6-digit OTP code
  Future<bool> verifyOtp(String code) async {
    if (_verificationId == null && !AuthService.useMockMode) {
      _state = const AuthError('Missing verification session. Please resend OTP.');
      notifyListeners();
      return false;
    }

    _state = const AuthLoading(message: 'Verifying code...');
    notifyListeners();

    try {
      final user = await _authService.verifyOtp(
        verificationId: _verificationId ?? 'mock_verification_id',
        smsCode: code,
        phoneNumber: _phoneNumber,
      );
      _currentUser = user;
      _state = Authenticated(user);
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _state = const AuthLoading(message: 'Signing in with Google...');
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      _currentUser = user;
      _state = Authenticated(user);
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Email
  Future<bool> signInWithEmail({
    required String email,
    String? password,
    bool isPasswordless = false,
  }) async {
    _state = const AuthLoading(message: 'Signing in with email...');
    notifyListeners();

    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
        isPasswordless: isPasswordless,
      );
      _currentUser = user;
      _state = Authenticated(user);
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _state = const AuthInitial();
    notifyListeners();
  }
}
