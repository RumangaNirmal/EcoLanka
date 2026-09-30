import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isPasswordlessMode = false;
  bool _isValidEmail = false;

  final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final valid = _emailRegex.hasMatch(_emailController.text.trim());
    if (valid != _isValidEmail && mounted) {
      setState(() => _isValidEmail = valid);
    }
  }

  Future<void> _handleEmailAuth() async {
    if (!_isValidEmail) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signInWithEmail(
      email: email,
      password: _isPasswordlessMode ? null : password,
      isPasswordless: _isPasswordlessMode,
    );

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
                    'Email Sign In',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _isPasswordlessMode
                        ? 'We will send a secure sign-in link directly to your email.'
                        : 'Sign in with your email and password to access ReShare.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  // Mock banner
                  if (authProvider.useMockMode) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA5D6A7)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mock Mode: Any valid email connects immediately.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF1B5E20), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Email input field
                  const Text(
                    'Email Address',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email_outlined, color: AppColors.brandPrimary, size: 20),
                        hintText: 'you@example.com',
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  if (!_isPasswordlessMode) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Password',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.lock_outline_rounded, color: AppColors.brandPrimary, size: 20),
                          hintText: '••••••••',
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Passwordless Toggle switch
                  Row(
                    children: [
                      Switch.adaptive(
                        value: _isPasswordlessMode,
                        activeThumbColor: AppColors.brandPrimary,
                        onChanged: (val) => setState(() => _isPasswordlessMode = val),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Passwordless sign-in link',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // "Continue" action button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isValidEmail && !isLoading) ? _handleEmailAuth : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        disabledBackgroundColor: AppColors.brandPrimary.withValues(alpha: 0.35),
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
                          : Text(
                              _isPasswordlessMode ? 'Send Magic Link' : 'Sign In',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Link back to Mobile Login
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        context.pop();
                        context.push('/phone-number');
                      },
                      icon: const Icon(Icons.phone_iphone_rounded, size: 18, color: AppColors.brandPrimary),
                      label: const Text(
                        'Login with Mobile Number',
                        style: TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 14,
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
