import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await FCMService.initFCM();
  } catch (e) {
    debugPrint('[Firebase Core] Note: Firebase options not configured yet or missing config file: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: const SweezenApp(),
    ),
  );
}


class SweezenApp extends StatelessWidget {
  const SweezenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Sweezen Foundation',
          debugShowCheckedModeBanner: false,
          theme: appState.isHighContrast ? AppTheme.highContrastTheme : AppTheme.darkTheme,
          builder: (context, childWidget) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(appState.textScaleFactor),
              ),
              child: childWidget!,
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
