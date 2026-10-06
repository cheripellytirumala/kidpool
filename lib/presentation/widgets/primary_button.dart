import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Button styles from the Figma component set (🎨 Design System · Button).
///
/// "Pill button. Lime = primary action (one per screen). Dark = strong
/// secondary. Light = tertiary. Outline = low emphasis."
enum AppButtonStyle { lime, dark, light, outline }

/// Size=L → 60px tall, 32px horizontal padding, Label/L.
/// Size=M → 48px tall, 24px horizontal padding, Label/M.
enum AppButtonSize { l, m }

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final AppButtonSize size;

  /// Buttons are FILL width in the design; set false to hug the label.
  final bool expand;

  /// Escape hatches kept for one-off overrides.
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = AppButtonStyle.lime,
    this.size = AppButtonSize.l,
    this.expand = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  double get _height => widget.size == AppButtonSize.l ? 60 : 48;

  double get _paddingX => widget.size == AppButtonSize.l ? 32 : 24;

  TextStyle get _labelStyle => widget.size == AppButtonSize.l
      ? AppTextStyles.labelL
      : AppTextStyles.labelM;

  // State=Hover in Figma is the pressed treatment on touch.
  Color get _background {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    switch (widget.style) {
      case AppButtonStyle.lime:
        return _pressed ? AppColors.ink : AppColors.lime;
      case AppButtonStyle.dark:
        return _pressed ? AppColors.lime : AppColors.ink;
      case AppButtonStyle.light:
        return _pressed ? AppColors.bgSurfaceStrong : AppColors.bgSurface;
      case AppButtonStyle.outline:
        return _pressed ? AppColors.ink : Colors.transparent;
    }
  }

  Color get _foreground {
    if (widget.textColor != null) return widget.textColor!;
    switch (widget.style) {
      case AppButtonStyle.lime:
        return _pressed ? AppColors.textAccent : AppColors.textOnLime;
      case AppButtonStyle.dark:
        return _pressed ? AppColors.textPrimary : AppColors.textOnDark;
      case AppButtonStyle.light:
        return AppColors.textPrimary;
      case AppButtonStyle.outline:
        return _pressed ? AppColors.textOnDark : AppColors.textPrimary;
    }
  }

  // Only the lime button carries Glow/Lime.
  List<BoxShadow>? get _shadow {
    if (widget.style != AppButtonStyle.lime || _pressed) return null;
    return _enabled ? AppShadows.glowLime : AppShadows.glowLimeMuted;
  }

  BoxBorder? get _border => widget.style == AppButtonStyle.outline
      ? Border.all(color: AppColors.borderStrong, width: 1.5)
      : null;

  @override
  Widget build(BuildContext context) {
    final button = Opacity(
      opacity: _enabled ? 1 : 0.5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: _height,
        padding: EdgeInsets.symmetric(horizontal: _paddingX),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _background,
          borderRadius: AppRadius.pill,
          border: _border,
          boxShadow: _shadow,
        ),
        child: Text(
          widget.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _labelStyle.copyWith(color: _foreground),
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      behavior: HitTestBehavior.opaque,
      child: widget.expand
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}
