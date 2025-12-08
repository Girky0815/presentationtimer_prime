import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/bell_config.dart';
import 'time_input_box.dart';

class BellEditDialog extends StatefulWidget {
  final BellConfig? initialBell;
  final Function(int min, int sec, int count) onSave;
  final VoidCallback? onDelete;

  const BellEditDialog({
    super.key,
    this.initialBell,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<BellEditDialog> createState() => _BellEditDialogState();
}

class _BellEditDialogState extends State<BellEditDialog> {
  late int min;
  late int sec;
  late int count;

  @override
  void initState() {
    super.initState();
    if (widget.initialBell != null) {
      min = widget.initialBell!.min;
      sec = widget.initialBell!.sec;
      count = widget.initialBell!.count;
    } else {
      // Default values for new bell (e.g. 5 min)
      min = 5;
      sec = 0;
      count = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.initialBell != null;

    return Dialog(
      backgroundColor: colorScheme.surfaceBright,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEditing ? "ベル設定" : "ベル追加",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold)),
                    Text("タイミングと回数を設定",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 24),

            // Time Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text("鳴動タイミング (経過時間)",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TimeInputBox(
                        value: min,
                        onChanged: (v) => setState(() => min = v),
                        label: "分",
                        fontSize: 32,
                        padding: 12,
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Transform.translate(
                              offset: const Offset(0, -4),
                              child: Text(":",
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      TimeInputBox(
                        value: sec,
                        onChanged: (v) => setState(() => sec = v),
                        label: "秒",
                        fontSize: 32,
                        padding: 12,
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Count Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("鳴動回数",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text("ベルを鳴らす回数を設定",
                            style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => setState(
                              () => count = (count > 1 ? count - 1 : 1)),
                          icon: const Icon(Icons.remove),
                        ),
                        SizedBox(
                            width: 32,
                            child: Center(
                                child: Text("$count",
                                    style: TextStyle(
                                        fontFamily: 'Google Sans Flex',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                        fontVariations: const [
                                          FontVariation('ROND', 100)
                                        ])))),
                        IconButton.filledTonal(
                          onPressed: () => setState(() => count = count + 1),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                if (isEditing) ...[
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        if (widget.onDelete != null) widget.onDelete!();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("削除"),
                      style: TextButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () {
                      widget.onSave(min, sec, count);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("OK"),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
