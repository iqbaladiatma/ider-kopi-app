import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

enum ButtonVariant { primary, outlined, danger, ghost }

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.padding,
    this.size = ButtonSize.normal,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsets? padding;
  final ButtonSize size;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

enum ButtonSize { small, normal, large }

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  EdgeInsets get _effectivePadding {
    if (widget.padding != null) return widget.padding!;
    return switch (widget.size) {
      ButtonSize.small =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ButtonSize.normal =>
        const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      ButtonSize.large =>
        const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    };
  }

  double get _fontSize => switch (widget.size) {
        ButtonSize.small => 13,
        ButtonSize.normal => 15,
        ButtonSize.large => 17,
      };

  double get _iconSize => switch (widget.size) {
        ButtonSize.small => 16,
        ButtonSize.normal => 19,
        ButtonSize.large => 22,
      };

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null && !widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: _buildButton(isDisabled),
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.variant == ButtonVariant.outlined
                    ? AppColors.primary
                    : Colors.white,
              ),
            ),
          )
        else if (widget.icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(widget.icon, size: _iconSize),
          ),
        if (widget.isLoading) const SizedBox(width: 10),
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: _fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(bool isDisabled) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return Container(
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow:
                (isDisabled || widget.isLoading) ? null : AppTheme.buttonShadow,
            gradient: isDisabled
                ? null
                : const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: Material(
            color: isDisabled
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: isDisabled || widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(14),
              splashColor: Colors.white.withValues(alpha: 0.2),
              child: Padding(
                padding: _effectivePadding,
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: isDisabled
                        ? Colors.white.withValues(alpha: 0.65)
                        : Colors.white,
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: isDisabled
                          ? Colors.white.withValues(alpha: 0.65)
                          : Colors.white,
                    ),
                    child: _buildButtonContent(),
                  ),
                ),
              ),
            ),
          ),
        );

      case ButtonVariant.outlined:
        return SizedBox(
          width: widget.fullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isDisabled || widget.isLoading ? null : widget.onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: isDisabled
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.primary,
                width: 2,
              ),
              disabledForegroundColor: AppColors.primary.withValues(alpha: 0.4),
              padding: _effectivePadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: _fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            child: _buildButtonContent(),
          ),
        );

      case ButtonVariant.danger:
        return Container(
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: isDisabled || widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.error.withValues(alpha: 0.35),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.65),
              elevation: 0,
              padding: _effectivePadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: _fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            child: _buildButtonContent(),
          ),
        );

      case ButtonVariant.ghost:
        return SizedBox(
          width: widget.fullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isDisabled || widget.isLoading ? null : widget.onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: _effectivePadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: _fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            child: _buildButtonContent(),
          ),
        );
    }
  }
}
