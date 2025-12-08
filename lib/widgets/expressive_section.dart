import 'package:flutter/material.dart';

class ExpressiveSection extends StatelessWidget {
  final List<Widget> children;

  const ExpressiveSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final count = children.length;

    return Column(
      children: [
        for (int i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(height: 0.1),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colorScheme.surfaceBright,
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(i == 0 ? 20.0 : 4.0),
                bottom: Radius.circular(i == count - 1 ? 20.0 : 4.0),
              ),
            ),
            child: children[i],
          ),
        ],
      ],
    );
  }
}
