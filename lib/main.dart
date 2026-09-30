// Main entry point for the ReShare application.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_router.dart';
import 'config/theme.dart';
import 'controllers/item_controller.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/language_provider.dart';

import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase Connected: \${Firebase.app().options.projectId}');
  } catch (error) {
    debugPrint('Firebase initialization note: \$error');
  }

  // Create language provider
  final languageProvider = LanguageProvider();

  // Load previously selected language
  await languageProvider.loadSavedLanguage();

  runApp(
    MultiProvider(
      providers: [
        // Authentication Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        // User state
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),

        // Item state
        ChangeNotifierProvider(
          create: (_) => ItemController(),
        ),

        // Language state
        ChangeNotifierProvider.value(
          value: languageProvider,
        ),
      ],
      child: const EcoLankaApp(),
    ),
  );
}

/// Root widget of the application.
class EcoLankaApp extends StatelessWidget {
  const EcoLankaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp.router(
          title: 'ReShare',
          debugShowCheckedModeBanner: false,

          // Global theme
          theme: AppTheme.lightTheme,

          // Current selected language
          locale: languageProvider.appLocale,

          // Supported languages
          supportedLocales: AppLocalizations.supportedLocales,

          // Localization delegates
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // GoRouter
          routerConfig: appRouter,

          // Mobile-width layout on web
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: Scaffold(
                backgroundColor: const Color(0xFF1F2937),
                body: Center(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 420,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: child!,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
