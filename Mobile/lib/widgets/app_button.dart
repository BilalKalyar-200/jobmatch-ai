import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.secondary = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool secondary;
  final bool danger;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final child = widget.loading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(widget.label);

    final scale = _pressed ? 0.98 : 1.0;

    Widget button;
    if (widget.danger) {
      button = ElevatedButton(
        onPressed: widget.loading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.red600),
        child: child,
      );
    } else if (widget.secondary) {
      button = OutlinedButton(
        onPressed: widget.loading ? null : widget.onPressed,
        child: child,
      );
    } else {
      button = ElevatedButton(
        onPressed: widget.loading ? null : widget.onPressed,
        child: child,
      );
    }

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 120),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: button,
      ),
    );
  }
}
