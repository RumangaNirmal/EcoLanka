import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const int _otpLength = 6;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _countdown = 0);
      } else {
        if (mounted) setState(() => _countdown--);
      }
    });
  }

  Future<void> _handleVerify([String? pin]) async {
    final code = pin ?? _pinController.text.trim();
    if (code.length != _otpLength) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(code);

    if (mounted) {
      if (success) {
        context.go('/home');
      } else if (authProvider.state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((authProvider.state as AuthError).message),
            backgroundColor: AppColors.colorError,
          ),
        );
      }
    }
  }

  Future<void> _handleResend() async {
    if (_countdown > 0) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendOtp(widget.phoneNumber);

    if (mounted) {
      if (success) {
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new 6-digit verification code has been dispatched.'),
            backgroundColor: AppColors.brandPrimary,
          ),
        );
      } else if (authProvider.state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((authProvider.state as AuthError).message),
            backgroundColor: AppColors.colorError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brandPrimary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brandPrimary, width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.colorError, width: 1.5),
      ),
    );

    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoading = authProvider.isLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Header
                  const Text(
                    'OTP Verification',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Enter the 6-digit code sent to \${widget.phoneNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Change phone number',
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.brandPrimary),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),

                  // Mock Mode helper banner
                  if (authProvider.useMockMode)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA5D6A7)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2E7D32), size: 16),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Mock Mode: Enter 123456 to verify successfully.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _pinController.text = '123456';
                              _handleVerify('123456');
                            },
                            child: const Text(
                              'Auto Fill',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brandPrimary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // 6-Digit Pin Input Field with Auto-Focus, Backspace & Paste
                  Center(
                    child: Pinput(
                      length: _otpLength,
                      controller: _pinController,
                      focusNode: _focusNode,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      errorPinTheme: errorPinTheme,
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      showCursor: true,
                      autofocus: true,
                      onCompleted: (pin) => _handleVerify(pin),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 60-Second Countdown & Resend Button
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _countdown > 0
                              ? 'Resend OTP in 00:\$secondsStr'
                              : "Didn't receive the code?",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_countdown == 0) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _handleResend,
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // "Verify" Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _handleVerify(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                            )
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
