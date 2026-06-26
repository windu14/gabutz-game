import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/features/home/presentation/home_screen.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // InAppWebView requires initialization on Android
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ScreenUtil init for responsive design across different mobile screens
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Standard iPhone 14 / modern Android dimension
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Retro Math Shooter',
          theme: AppTheme.monochromeTheme,
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        );
      },
    );
  }
}
