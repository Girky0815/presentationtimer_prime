// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'state/timer_state.dart';
import 'theme/color_schemes.dart';
import 'theme/typography.dart';
import 'screens/timer_screen.dart';

/// アプリケーションのルートウィジェット。
///
/// - ダイナミックカラーの適用
/// - テーマ設定 (ライト/ダーク)
/// - ローカリゼーション設定 (日本語)
/// - ルーティング設定
/// を行います。
class PresentationTimerApp extends StatelessWidget {
  const PresentationTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final timerState = context.watch<TimerState>();

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (timerState.useDynamicColor &&
            lightDynamic != null &&
            darkDynamic != null) {
          // Use fromSeed to ensure all surface variants are generated correctly
          // harmonized() alone might not fill all surface container roles on some Android versions
          lightScheme = ColorScheme.fromSeed(
            seedColor: lightDynamic.primary,
            brightness: Brightness.light,
          );
          darkScheme = ColorScheme.fromSeed(
            seedColor: darkDynamic.primary,
            brightness: Brightness.dark,
          );
        } else {
          lightScheme = lightColorScheme;
          darkScheme = darkColorScheme;
        }

        return MaterialApp(
          title: 'Presentation Timer',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ja'), // Japanese
          ],
          locale: const Locale('ja'),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            scaffoldBackgroundColor: lightScheme.surfaceContainerHigh,
            cardTheme: CardThemeData(color: lightScheme.surfaceBright),
            dialogTheme:
                DialogThemeData(backgroundColor: lightScheme.surfaceBright),
            textTheme: _buildSmartTextTheme(
              ThemeData(brightness: Brightness.light).textTheme,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            scaffoldBackgroundColor: darkScheme.surfaceContainerHigh,
            cardTheme: CardThemeData(color: darkScheme.surfaceBright),
            dialogTheme:
                DialogThemeData(backgroundColor: darkScheme.surfaceBright),
            textTheme: _buildSmartTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ),
          ),
          themeMode: timerState.themeMode,
          home: const TimerScreen(),
        );
      },
    );
  }

  TextTheme _buildSmartTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: getSmartTextStyle(baseStyle: base.displayLarge),
      displayMedium: getSmartTextStyle(baseStyle: base.displayMedium),
      displaySmall: getSmartTextStyle(baseStyle: base.displaySmall),
      headlineLarge: getSmartTextStyle(baseStyle: base.headlineLarge),
      headlineMedium: getSmartTextStyle(baseStyle: base.headlineMedium),
      headlineSmall: getSmartTextStyle(baseStyle: base.headlineSmall),
      titleLarge: getSmartTextStyle(baseStyle: base.titleLarge),
      titleMedium: getSmartTextStyle(baseStyle: base.titleMedium),
      titleSmall: getSmartTextStyle(baseStyle: base.titleSmall),
      bodyLarge: getSmartTextStyle(baseStyle: base.bodyLarge),
      bodyMedium: getSmartTextStyle(baseStyle: base.bodyMedium),
      bodySmall: getSmartTextStyle(baseStyle: base.bodySmall),
      labelLarge: getSmartTextStyle(baseStyle: base.labelLarge),
      labelMedium: getSmartTextStyle(baseStyle: base.labelMedium),
      labelSmall: getSmartTextStyle(baseStyle: base.labelSmall),
    );
  }
}
