import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
import 'providers/premium_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/drafts_provider.dart';
import 'providers/templates_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/offline_templates_provider.dart';

// Screens
import 'screens/home_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize MobileAds
  await MobileAds.instance.initialize();
  
  // Load premium status
  final prefs = await SharedPreferences.getInstance();
  final isPremium = prefs.getBool('is_premium') ?? false;
  
  // Load theme preference
  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  
  // Load language preference
  final String languageCode = prefs.getString('language_code') ?? 'en';
  
  // Set app orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode)),
        ChangeNotifierProvider(create: (_) => LanguageProvider(languageCode)),
        ChangeNotifierProvider(create: (_) => DraftsProvider()),
        ChangeNotifierProvider(create: (_) => TemplatesProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => OfflineTemplatesProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return MaterialApp(
      title: 'AI Resume Generator',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('id', ''), // Indonesian
        Locale('es', ''), // Spanish
      ],
      locale: Locale(languageProvider.languageCode),
      home: HomeScreen(),
    );
  }
}
