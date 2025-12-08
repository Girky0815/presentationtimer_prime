import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'state/timer_state.dart';

/// アプリケーションのエントリーポイント。
///
/// [TimerState] プロバイダーを初期化し、[PresentationTimerApp] を起動します。
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TimerState(),
      child: const PresentationTimerApp(),
    ),
  );
}
