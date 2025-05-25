import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/design_system.dart';

enum PremiumButtonType { primary, secondary, outline, ghost, danger }
enum PremiumButtonSize { small, medium, large }

class PremiumButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final PremiumButtonType type;
  final PremiumButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? customChild;

  const PremiumButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.type = PremiumButtonType.primary,
    this.size = PremiumButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customChild,
  });

  factory PremiumButton.primary({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    PremiumButtonSize size = PremiumButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return PremiumButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      type: PremiumButtonType.primary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  factory PremiumButton.secondary({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    PremiumButtonSize size = PremiumButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return PremiumButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      type: PremiumButtonType.secondary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  factory PremiumButton.outline({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    PremiumButtonSize size = PremiumButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return PremiumButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      type: PremiumButtonType.outline,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignSystem.animationFast,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _resetButton();
  }

  void _handleTapCancel() {
    _resetButton();
  }

  void _resetButton() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  double get _buttonHeight {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return 40;
      case PremiumButtonSize.medium:
        return 48;
      case PremiumButtonSize.large:
        return 56;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return 14;
      case PremiumButtonSize.medium:
        return 16;
      case PremiumButtonSize.large:
        return 18;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case PremiumButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case PremiumButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  Color get _backgroundColor {
    if (widget.isLoading || widget.onPressed == null) {
      return _getBaseColor().withOpacity(0.5);
    }
    return _getBaseColor();
  }

  Color _getBaseColor() {
    switch (widget.type) {
      case PremiumButtonType.primary:
        return DesignSystem.primaryBlue;
      case PremiumButtonType.secondary:
        return DesignSystem.accentOrange;
      case PremiumButtonType.outline:
        return Colors.transparent;
      case PremiumButtonType.ghost:
        return Colors.transparent;
      case PremiumButtonType.danger:
        return DesignSystem.errorRed;
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case PremiumButtonType.primary:
      case PremiumButtonType.secondary:
      case PremiumButtonType.danger:
        return Colors.white;
      case PremiumButtonType.outline:
        return DesignSystem.primaryBlue;
      case PremiumButtonType.ghost:
        return DesignSystem.neutralGray700;
    }
  }

  Border? get _border {
    switch (widget.type) {
      case PremiumButtonType.outline:
        return Border.all(
          color: widget.onPressed == null
              ? DesignSystem.neutralGray300
              : DesignSystem.primaryBlue,
          width: 2,
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? get _boxShadow {
    if (widget.type == PremiumButtonType.primary ||
        widget.type == PremiumButtonType.secondary ||
        widget.type == PremiumButtonType.danger) {
      return [
        BoxShadow(
          color: _getBaseColor().withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.isLoading ? null : widget.onPressed,
              child: AnimatedContainer(
                duration: DesignSystem.animationMedium,
                width: widget.isFullWidth ? double.infinity : null,
                height: _buttonHeight,
                padding: _padding,
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                  border: _border,
                  boxShadow: widget.onPressed != null ? _boxShadow : null,
                ),
                child: widget.customChild ?? _buildButtonContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: _fontSize,
            height: _fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_textColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: _textColor,
            size: _fontSize + 2,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              color: _textColor,
              fontFamily: DesignSystem.fontFamily,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
