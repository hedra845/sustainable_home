import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../navigation/main_navigation.dart';
import 'model.dart';
import 'notifications_service.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/survey_screen.dart';

class SustainabilityHubApp extends StatefulWidget {
  const SustainabilityHubApp({
    super.key,
    this.supabaseEnabled = false,
    this.hasSeenOnboarding = false,
  });

  final bool supabaseEnabled;
  final bool hasSeenOnboarding;

  @override
  State<SustainabilityHubApp> createState() => SustainabilityHubAppState();
}

class SustainabilityHubAppState extends State<SustainabilityHubApp> {
  late final SustainabilityModel model;

  @override
  void initState() {
    super.initState();
    model = SustainabilityModel(
      supabaseEnabled: widget.supabaseEnabled,
      initialHasSeenOnboarding: widget.hasSeenOnboarding,
    );
    // Request Notifications Permission on Startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationsService.requestPermissions();
    });
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) {
        return MaterialApp(
          title: 'My Sustainable Home',
          debugShowCheckedModeBanner: false,
          locale: model.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: model.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              primary: const Color(0xFF16A34A),
              secondary: const Color(0xFF22C55E),
              tertiary: const Color(0xFF4ADE80),
              surface: Colors.white,
            ),
            textTheme: GoogleFonts.cairoTextTheme(),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            cardTheme: CardTheme(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            dividerTheme: const DividerThemeData(space: 1, thickness: 1),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
            navigationBarTheme: const NavigationBarThemeData(
              height: 70,
              indicatorShape: StadiumBorder(),
            ),
            tabBarTheme: const TabBarTheme(dividerColor: Colors.transparent),
            listTileTheme: ListTileThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            checkboxTheme: CheckboxThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.dark,
              primary: const Color(0xFF22C55E),
              secondary: const Color(0xFF4ADE80),
              tertiary: const Color(0xFF86EFAC),
            ),
            textTheme: GoogleFonts.cairoTextTheme(),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            cardTheme: CardTheme(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            dividerTheme: const DividerThemeData(space: 1, thickness: 1),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
            navigationBarTheme: const NavigationBarThemeData(
              height: 70,
              indicatorShape: StadiumBorder(),
            ),
            tabBarTheme: const TabBarTheme(dividerColor: Colors.transparent),
            listTileTheme: ListTileThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            checkboxTheme: CheckboxThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          builder: (context, child) {
            return SustainabilityProvider(
              model: model,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const AppShell(),
        );
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _splashDone = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start splash timer
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() => _splashDone = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);

    if (!_splashDone) return const SplashScreen();
    if (!model.hasSeenOnboarding) return const OnboardingScreen();
    if (!model.isAuthenticated) return const LoginScreen();
    if (!model.hasCompletedSurvey) return const SurveyScreen();
    return const MainNavigation();
  }
}
