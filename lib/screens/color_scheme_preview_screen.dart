import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/timer_state.dart';
import '../widgets/expressive_section.dart';

class ColorSchemePreviewScreen extends StatelessWidget {
  const ColorSchemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = context.watch<TimerState>();

    // Helper to build color data tuple
    (String, Color, Color) c(String name, Color color, Color onColor) =>
        (name, color, onColor);

    final coreColors = [
      c("Primary", colorScheme.primary, colorScheme.onPrimary),
      c("On Primary", colorScheme.onPrimary, colorScheme.primary),
      c("Primary Container", colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer),
      c("On Primary Container", colorScheme.onPrimaryContainer,
          colorScheme.primaryContainer),
      c("Secondary", colorScheme.secondary, colorScheme.onSecondary),
      c("On Secondary", colorScheme.onSecondary, colorScheme.secondary),
      c("Secondary Container", colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer),
      c("On Secondary Container", colorScheme.onSecondaryContainer,
          colorScheme.secondaryContainer),
      c("Tertiary", colorScheme.tertiary, colorScheme.onTertiary),
      c("On Tertiary", colorScheme.onTertiary, colorScheme.tertiary),
      c("Tertiary Container", colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer),
      c("On Tertiary Container", colorScheme.onTertiaryContainer,
          colorScheme.tertiaryContainer),
      c("Error", colorScheme.error, colorScheme.onError),
      c("On Error", colorScheme.onError, colorScheme.error),
      c("Error Container", colorScheme.errorContainer,
          colorScheme.onErrorContainer),
      c("On Error Container", colorScheme.onErrorContainer,
          colorScheme.errorContainer),
    ];

    final surfaceColors = [
      c("Surface", colorScheme.surface, colorScheme.onSurface),
      c("On Surface", colorScheme.onSurface, colorScheme.surface),
      c("Surface Variant", colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant),
      c("On Surface Variant", colorScheme.onSurfaceVariant,
          colorScheme.surfaceContainerHighest),
      c("Inverse Surface", colorScheme.inverseSurface,
          colorScheme.onInverseSurface),
      c("On Inverse Surface", colorScheme.onInverseSurface,
          colorScheme.inverseSurface),
      c("Inverse Primary", colorScheme.inversePrimary, colorScheme.onPrimary),
    ];

    final containerColors = [
      c("Surface Container Lowest", colorScheme.surfaceContainerLowest,
          colorScheme.onSurface),
      c("Surface Container Low", colorScheme.surfaceContainerLow,
          colorScheme.onSurface),
      c("Surface Container", colorScheme.surfaceContainer,
          colorScheme.onSurface),
      c("Surface Container High", colorScheme.surfaceContainerHigh,
          colorScheme.onSurface),
      c("Surface Container Highest", colorScheme.surfaceContainerHighest,
          colorScheme.onSurface),
      c("Surface Bright", colorScheme.surfaceBright, colorScheme.onSurface),
      c("Surface Dim", colorScheme.surfaceDim, colorScheme.onSurface),
    ];

    final utilityColors = [
      c("Outline", colorScheme.outline, colorScheme.surface),
      c("Outline Variant", colorScheme.outlineVariant, colorScheme.onSurface),
      c("Scrim", colorScheme.scrim, Colors.white),
      c("Shadow", colorScheme.shadow, Colors.white),
      c("Surface Tint", colorScheme.surfaceTint, colorScheme.onPrimary),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHigh,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Custom Header
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
                        "カラーパレット一覧",
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
                      _buildDynamicColorSection(context, state),
                      const SizedBox(height: 24),
                      _buildSection(context, "コアカラー", coreColors),
                      const SizedBox(height: 24),
                      _buildSection(context, "サーフェスカラー", surfaceColors),
                      const SizedBox(height: 24),
                      _buildSection(context, "コンテナカラー", containerColors),
                      const SizedBox(height: 24),
                      _buildSection(context, "ユーティリティカラー", utilityColors),
                      const SizedBox(height: 24),
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

  Widget _buildDynamicColorSection(BuildContext context, TimerState state) {
    final colorScheme = Theme.of(context).colorScheme;

    final WidgetStateProperty<Icon?> thumbIcon =
        WidgetStateProperty.resolveWith<Icon?>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text("設定",
              style: TextStyle(
                  color: colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        ExpressiveSection(
          children: [
            SwitchListTile(
              title: Text("ダイナミックカラー(beta)",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
              subtitle: Text(
                  "OSのテーマカラーに合わせてアプリのカラーパレットを変更します\nOSのテーマカラーを変更した場合は、アプリを再起動すると適用されます。",
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
              value: state.useDynamicColor,
              onChanged: (value) {
                state.toggleDynamicColor(value);
              },
              secondary: Icon(Icons.palette_outlined,
                  color: colorScheme.onSurfaceVariant),
              thumbIcon: thumbIcon,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<(String, Color, Color)> colors) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(title,
              style: TextStyle(
                  color: colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        ExpressiveSection(
          children: colors.map((c) => _buildColorRow(context, c)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorRow(
      BuildContext context, (String, Color, Color) colorInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = colorInfo.$1;
    final color = colorInfo.$2;
    // Remove alpha (first 2 chars) and keep 6 chars
    final hexCode =
        '#${color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Google Sans Flex',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                    fontVariations: const [FontVariation('ROND', 100)],
                  ),
                ),
                Text(
                  hexCode,
                  style: TextStyle(
                    fontFamily: 'Google Sans Flex',
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                    fontVariations: const [FontVariation('ROND', 100)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
