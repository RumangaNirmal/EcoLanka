import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _onContinueWithPhone(BuildContext context) {
    context.push('/phone-number');
  }

  Future<void> _onContinueWithGoogle(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();
    if (success && context.mounted) {
      context.go('/home');
    } else if (context.mounted && authProvider.state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((authProvider.state as AuthError).message),
          backgroundColor: AppColors.colorError,
        ),
      );
    }
  }

  void _onContinueWithEmail(BuildContext context) {
    context.push('/email-login');
  }

  void _showInfoDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text(body, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoading = authProvider.isLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // Dev Mock Mode Toggle Badge
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FilterChip(
                  label: Text(
                    authProvider.useMockMode ? 'Mock: ON' : 'Firebase: ON',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: authProvider.useMockMode ? const Color(0xFF1B5E20) : const Color(0xFF0D47A1),
                    ),
                  ),
                  selected: authProvider.useMockMode,
                  selectedColor: const Color(0xFFE8F5E9),
                  backgroundColor: const Color(0xFFE3F2FD),
                  side: BorderSide(
                    color: authProvider.useMockMode ? const Color(0xFFA5D6A7) : const Color(0xFF90CAF9),
                  ),
                  onSelected: (val) {
                    authProvider.toggleMockMode(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 2),
                        content: Text(
                          val
                              ? 'Mock Mode Enabled (Instant phone & OTP: 123456)'
                              : 'Real Firebase Auth Mode Enabled',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top / Center Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ReShare Logo with soft glow effect
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandPrimary.withValues(alpha: 0.35),
                                blurRadius: 26,
                                spreadRadius: 6,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            AppImages.logo,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.eco_rounded,
                                size: 44,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Heading
                        const Text(
                          'Welcome to ReShare',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tagline
                        Text(
                          'Share more, waste less — empower communities together in Sri Lanka.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Buttons & Terms
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Primary Button: Login with Mobile Number
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _onContinueWithPhone(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone_iphone_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Login with Mobile Number',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Secondary Button 1: Continue with Google
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => _onContinueWithGoogle(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'G',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF4285F4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        color: Color(0xFF1F2937),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Secondary Button 2: Continue with Email
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => _onContinueWithEmail(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mail_outline_rounded, color: Color(0xFF1F2937), size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Continue with Email',
                                style: TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Footer: Terms of Service and Privacy Policy
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'By continuing, you agree to our ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showInfoDialog(
                              context,
                              'Terms of Service',
                              'Welcome to ReShare. By using this service, you agree to treat community members with dignity, list items accurately, and uphold safe item exchange practices across Sri Lanka.',
                            ),
                            child: Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            ' and ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showInfoDialog(
                              context,
                              'Privacy Policy',
                              'Your privacy is essential. ReShare protects your mobile number, email, and location data in compliance with Sri Lankan data protection guidelines and Cloud Firestore security standards.',
                            ),
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
