import 'package:flutter_test/flutter_test.dart';
import 'package:ecolanka/services/auth_service.dart';
import 'package:ecolanka/providers/auth_provider.dart';

void main() {
  group('AuthService Mock Mode Tests', () {
    late AuthService authService;

    setUp(() {
      AuthService.useMockMode = true;
      authService = AuthService();
    });

    test('sendOtp returns mock verificationId', () async {
      String? receivedId;
      await authService.sendOtp(
        phoneNumber: '+94771234567',
        onCodeSent: (id, _) => receivedId = id,
        onError: (_) {},
        onAutoVerified: (_) {},
      );

      expect(receivedId, contains('mock_verification_id_for_+94771234567'));
    });

    test('verifyOtp succeeds with 123456', () async {
      final user = await authService.verifyOtp(
        verificationId: 'mock_id',
        smsCode: '123456',
        phoneNumber: '+94771234567',
      );

      expect(user.isMock, isTrue);
      expect(user.phoneNumber, '+94771234567');
      expect(user.role, 'user');
    });

    test('verifyOtp fails with invalid code', () async {
      expect(
        () => authService.verifyOtp(
          verificationId: 'mock_id',
          smsCode: '000000',
          phoneNumber: '+94771234567',
        ),
        throwsException,
      );
    });

    test('signInWithGoogle returns mock user', () async {
      final user = await authService.signInWithGoogle();
      expect(user.isMock, isTrue);
      expect(user.email, 'google.mock@reshare.lk');
    });

    test('signInWithEmail returns mock user', () async {
      final user = await authService.signInWithEmail(email: 'user@test.lk');
      expect(user.isMock, isTrue);
      expect(user.email, 'user@test.lk');
    });
  });

  group('AuthProvider State Management Tests', () {
    late AuthProvider provider;

    setUp(() {
      provider = AuthProvider();
      provider.toggleMockMode(true);
    });

    test('Initial state is AuthInitial', () {
      expect(provider.state, isA<AuthInitial>());
      expect(provider.isAuthenticated, isFalse);
    });

    test('sendOtp transitions to CodeSent state', () async {
      final success = await provider.sendOtp('+94771234567');
      expect(success, isTrue);
      expect(provider.state, isA<CodeSent>());
      final codeSent = provider.state as CodeSent;
      expect(codeSent.phoneNumber, '+94771234567');
    });

    test('verifyOtp with 123456 transitions to Authenticated', () async {
      await provider.sendOtp('+94771234567');
      final success = await provider.verifyOtp('123456');

      expect(success, isTrue);
      expect(provider.state, isA<Authenticated>());
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.phoneNumber, '+94771234567');
    });

    test('verifyOtp with wrong code transitions to AuthError', () async {
      await provider.sendOtp('+94771234567');
      final success = await provider.verifyOtp('999999');

      expect(success, isFalse);
      expect(provider.state, isA<AuthError>());
      expect(provider.errorMessage, contains('Invalid OTP'));
    });
  });
}
