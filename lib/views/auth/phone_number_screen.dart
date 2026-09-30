import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _selectedCountryCode = '+94';
  String _selectedCountryFlag = '🇱🇰';
  bool _isInputValid = false;

  final List<Map<String, String>> _countries = [
    {'code': '+94', 'flag': '🇱🇰', 'name': 'Sri Lanka'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'United States'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'United Kingdom'},
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
    {'code': '+61', 'flag': '🇦🇺', 'name': 'Australia'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'United Arab Emirates'},
    {'code': '+65', 'flag': '🇸🇬', 'name': 'Singapore'},
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    final clean = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final authProvider = context.read<AuthProvider>();

    bool valid = false;
    if (authProvider.useMockMode) {
      valid = clean.length >= 9 && clean.length <= 10;
    } else {
      if (_selectedCountryCode == '+94') {
        valid = (clean.length == 9 && RegExp(r'^7[01245678]\d{7}$').hasMatch(clean)) ||
            (clean.length == 10 && RegExp(r'^07[01245678]\d{7}$').hasMatch(clean));
      } else {
        valid = clean.length >= 7 && clean.length <= 15;
      }
    }

    if (mounted && valid != _isInputValid) {
      setState(() {
        _isInputValid = valid;
      });
    }
  }

  String _formatFullPhoneNumber() {
    String clean = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (_selectedCountryCode == '+94' && clean.startsWith('0')) {
      clean = clean.substring(1);
    }
    return '$_selectedCountryCode$clean';
  }

  Future<void> _handleSendOtp() async {
    if (!_isInputValid) return;

    final fullPhone = _formatFullPhoneNumber();
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendOtp(fullPhone);

    if (mounted) {
      if (success) {
        context.push('/otp-verification', extra: fullPhone);
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

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Select Country Code',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final c = _countries[index];
                    final isSelected = c['code'] == _selectedCountryCode;
                    return ListTile(
                      leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
                      title: Text(c['name']!),
                      trailing: Text(
                        c['code']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.brandPrimary : Colors.grey.shade700,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountryCode = c['code']!;
                          _selectedCountryFlag = c['flag']!;
                        });
                        Navigator.pop(ctx);
                        _validateInput();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Header
                  const Text(
                    'Mobile Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Enter your mobile number to receive a 6-digit verification code.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mock mode hint banner
                  if (authProvider.useMockMode)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
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
                              'Mock Mode Active: Enter any 9-10 digit number to proceed.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF1B5E20), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Phone Input Container with Country Code
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _focusNode.hasFocus ? AppColors.brandPrimary : Colors.grey.shade300,
                        width: _focusNode.hasFocus ? 1.8 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      children: [
                        // Country Code Picker Button
                        InkWell(
                          onTap: _showCountryPicker,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                Text(_selectedCountryFlag, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedCountryCode,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey, size: 20),
                              ],
                            ),
                          ),
                        ),

                        // Divider
                        Container(
                          height: 28,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.grey.shade300,
                        ),

                        // Input field
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            decoration: InputDecoration(
                              hintText: _selectedCountryCode == '+94' ? '77 123 4567' : 'Mobile number',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              letterSpacing: 0.5,
                            ),
                            onSubmitted: (_) => _handleSendOtp(),
                          ),
                        ),

                        if (_phoneController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                            onPressed: () {
                              _phoneController.clear();
                              _validateInput();
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  if (_phoneController.text.isNotEmpty && !_isInputValid)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Text(
                        _selectedCountryCode == '+94'
                            ? 'Please enter a valid Sri Lankan mobile number (e.g. 77XXXXXXX)'
                            : 'Please enter a valid mobile number',
                        style: const TextStyle(fontSize: 12, color: AppColors.colorError),
                      ),
                    ),

                  const Spacer(),

                  // "Login ->" Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isInputValid && !isLoading) ? _handleSendOtp : null,
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Link: Login with Email
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/email-login'),
                      child: const Text(
                        'Login with Email',
                        style: TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
