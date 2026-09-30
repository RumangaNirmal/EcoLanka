// lib/config/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../views/common/splash_screen.dart';
import '../views/common/language_selection_screen.dart' as lang;
import '../views/common/onboarding_screen.dart' as onboarding;
import '../views/common/welcome_screen.dart';

import '../views/auth/phone_number_screen.dart';
import '../views/auth/otp_verification_screen.dart';
import '../views/auth/email_login_screen.dart';
import '../views/auth/profile_setup_screen.dart';

import '../views/home/home_screen.dart';

// Root navigator key
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',

  overridePlatformDefaultLocation: true,

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/language',
      builder: (context, state) => const lang.LanguageSelectionScreen(),
    ),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const onboarding.OnboardingScreen(),
    ),

    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),

    GoRoute(
      path: '/phone-number',
      builder: (context, state) => const PhoneNumberScreen(),
    ),

    GoRoute(
      path: '/email-login',
      builder: (context, state) => const EmailLoginScreen(),
    ),

    GoRoute(
      path: '/otp-verification',
      builder: (context, state) {
        final extra = state.extra;
        final String phoneNumber = extra is String ? extra : '+94 77 123 4567';
        return OTPVerificationScreen(phoneNumber: phoneNumber);
      },
    ),

    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
