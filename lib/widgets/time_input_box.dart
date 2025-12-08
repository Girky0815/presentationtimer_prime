import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeInputBox extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String label;
  final double fontSize;
  final double padding;

  const TimeInputBox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.fontSize = 20,
    this.padding = 8,
  });

  @override
  State<TimeInputBox> createState() => _TimeInputBoxState();
}

class _TimeInputBoxState extends State<TimeInputBox> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.value.toString().padLeft(2, '0'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TimeInputBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != int.tryParse(_controller.text)) {
      _controller.text = widget.value.toString().padLeft(2, '0');
      // Try to keep cursor but it's tricky with formatting. Resetting to end is safer.
      _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          width: widget.fontSize * 2.5,
          padding: EdgeInsets.all(widget.padding),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Google Sans Flex',
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontVariations: const [FontVariation('ROND', 100)],
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            onChanged: (val) {
              if (val.isEmpty) return;
              widget.onChanged(int.parse(val));
            },
            onTapOutside: (_) {
              // Re-format on blur
              _controller.text = widget.value.toString().padLeft(2, '0');
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(widget.label,
            style:
                TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
