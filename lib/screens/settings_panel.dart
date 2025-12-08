import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../state/timer_state.dart';
import '../widgets/expressive_section.dart';
import '../widgets/time_input_box.dart';
import 'color_scheme_preview_screen.dart';

/// 設定画面パネル。
///
/// 以下の設定項目を提供します。
/// - 外観設定（テーマ切り替え、ダイナミックカラー）
/// - タイマー設定（デフォルトの発表時間）
/// - アプリ情報（バージョン、ライセンス、カラーパレット確認）
class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  PackageInfo? _packageInfo;

  final WidgetStateProperty<Icon?> _thumbIcon =
      WidgetStateProperty.resolveWith<Icon?>((states) {
    if (states.contains(WidgetState.selected)) {
      return const Icon(Icons.check);
    }
    return const Icon(Icons.close);
  });

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _buildThemeButton(
    BuildContext context, {
    required ThemeMode mode,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: isSelected ? colorScheme.primary : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimerState>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHigh,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // カスタムヘッダー（戻るボタンとタイトル）
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceDim,
                          shape: const CircleBorder(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "設定",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                    children: [
                      // 「外観」セクション
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Text("外観",
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      ExpressiveSection(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      state.themeMode == ThemeMode.system
                                          ? Icons.brightness_auto
                                          : state.themeMode == ThemeMode.light
                                              ? Icons.light_mode
                                              : Icons.dark_mode,
                                      size: 20,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text("テーマ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface)),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color: colorScheme.outlineVariant),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildThemeButton(
                                              context,
                                              mode: ThemeMode.system,
                                              icon: Icons.brightness_auto,
                                              label: "システム",
                                              isSelected: state.themeMode ==
                                                  ThemeMode.system,
                                              onTap: () => state.setThemeMode(
                                                  ThemeMode.system),
                                            ),
                                            Container(
                                                width: 1,
                                                height: 32,
                                                color:
                                                    colorScheme.outlineVariant),
                                            _buildThemeButton(
                                              context,
                                              mode: ThemeMode.light,
                                              icon: Icons.light_mode,
                                              label: "ライト",
                                              isSelected: state.themeMode ==
                                                  ThemeMode.light,
                                              onTap: () => state.setThemeMode(
                                                  ThemeMode.light),
                                            ),
                                            Container(
                                                width: 1,
                                                height: 32,
                                                color:
                                                    colorScheme.outlineVariant),
                                            _buildThemeButton(
                                              context,
                                              mode: ThemeMode.dark,
                                              icon: Icons.dark_mode,
                                              label: "ダーク",
                                              isSelected: state.themeMode ==
                                                  ThemeMode.dark,
                                              onTap: () => state
                                                  .setThemeMode(ThemeMode.dark),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              SwitchListTile(
                                title: const Text("ダイナミックカラー(beta)",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: const Text("OSのアクセントカラーを使用"),
                                value: state.useDynamicColor,
                                onChanged: (v) => state.toggleDynamicColor(v),
                                thumbIcon: _thumbIcon,
                                secondary: const Icon(Icons.palette_outlined),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeInOut,
                                alignment: Alignment.topCenter,
                                child: state.useDynamicColor
                                    ? Column(
                                        children: [
                                          const SizedBox(height: 4),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: colorScheme.surfaceBright,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline,
                                                    size: 18,
                                                    color: colorScheme.primary),
                                                const SizedBox(width: 12),
                                                Flexible(
                                                  child: Text(
                                                    "OSのアクセントカラーを変更した場合、\n反映するにはアプリの再起動が必要です。",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: colorScheme
                                                            .primary),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 「タイマー設定」セクション
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Text("タイマー設定",
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      ExpressiveSection(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("発表時間",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface)),
                                        Text("プレゼンの持ち時間",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: colorScheme
                                                    .onSurfaceVariant)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      children: [
                                        TimeInputBox(
                                          value: state.durationMin,
                                          onChanged: (v) =>
                                              state.updateDuration(
                                                  v, state.durationSec),
                                          label: "分",
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8),
                                              child: Text(":",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: colorScheme
                                                          .onSurface)),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text("",
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                        TimeInputBox(
                                          value: state.durationSec,
                                          onChanged: (v) =>
                                              state.updateDuration(
                                                  state.durationMin, v),
                                          label: "秒",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceBright,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "メイン画面のベルカードを押すと、ベルの設定を変更できます。",
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 「概要」セクション
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Text("概要",
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      ExpressiveSection(
                        children: [
                          ListTile(
                            leading: Icon(Icons.palette_outlined,
                                color: colorScheme.primary),
                            title: Text("カラーパレット一覧",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface)),
                            subtitle: Text("(デバッグ用･おまけ)カラーパレットを表示",
                                style: TextStyle(color: colorScheme.onSurface)),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 16, color: colorScheme.onSurfaceVariant),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ColorSchemePreviewScreen(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.info_outline,
                                color: colorScheme.primary),
                            title: Text("プレゼンタイマー Prime (仮)",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface)),
                            subtitle: _packageInfo != null
                                ? Text(
                                    "バージョン ${_packageInfo!.version} (ビルド ${_packageInfo!.buildNumber})",
                                    style: TextStyle(
                                        color: colorScheme.onSurfaceVariant))
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
