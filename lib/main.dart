import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/home/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Flutter SystemChrome so the Android status bar is visible at the very top:
  // - Pure black background (#000000)
  // - White system indicators (time, signal, Wi-Fi, battery % and icon)
  // - Android bottom navigation area visible and properly handled
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Remove immersive fullscreen mode; ensure standard status bar is visible
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  await FirebaseService.initialize();

  runApp(
    const ProviderScope(
      child: DailyWorkApp(),
    ),
  );
}

class DailyWorkApp extends ConsumerStatefulWidget {
  const DailyWorkApp({super.key});

  @override
  ConsumerState<DailyWorkApp> createState() => _DailyWorkAppState();
}

class _DailyWorkAppState extends ConsumerState<DailyWorkApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applySystemUIOverlay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _applySystemUIOverlay();
    }
  }

  void _applySystemUIOverlay() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final isGuestSignedIn = ref.watch(isGuestSignedInProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: MaterialApp(
        title: 'Daily Work Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: authState.when(
          data: (user) {
            if (user != null || isGuestSignedIn) {
              return const MainScaffold();
            }
            return LoginScreen(
              onLoginSuccess: () {
                ref.read(isGuestSignedInProvider.notifier).state = true;
              },
            );
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => LoginScreen(
            onLoginSuccess: () {
              ref.read(isGuestSignedInProvider.notifier).state = true;
            },
          ),
        ),
      ),
    );
  }
}
