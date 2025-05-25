import 'package:flutter/material.dart';
import '../utils/design_system.dart';

enum PremiumCardType { elevated, filled, outlined }

class PremiumCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final PremiumCardType type;
  final bool isInteractive;
  final double? width;
  final double? height;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.type = PremiumCardType.elevated,
    this.isInteractive = false,
    this.width,
    this.height,
  });

  factory PremiumCard.elevated({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    bool isInteractive = false,
    double? width,
    double? height,
  }) {
    return PremiumCard(
      type: PremiumCardType.elevated,
      onTap: onTap,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      isInteractive: isInteractive,
      width: width,
      height: height,
      child: child,
    );
  }

  factory PremiumCard.filled({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    bool isInteractive = false,
    double? width,
    double? height,
  }) {
    return PremiumCard(
      type: PremiumCardType.filled,
      onTap: onTap,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      isInteractive: isInteractive,
      width: width,
      height: height,
      child: child,
    );
  }

  factory PremiumCard.outlined({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    bool isInteractive = false,
    double? width,
    double? height,
  }) {
    return PremiumCard(
      type: PremiumCardType.outlined,
      onTap: onTap,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      isInteractive: isInteractive,
      width: width,
      height: height,
      child: child,
    );
  }

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignSystem.animationMedium,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: _getBaseElevation(),
      end: _getBaseElevation() + 4,
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

  double _getBaseElevation() {
    switch (widget.type) {
      case PremiumCardType.elevated:
        return 2;
      case PremiumCardType.filled:
        return 0;
      case PremiumCardType.outlined:
        return 0;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }
    
    switch (widget.type) {
      case PremiumCardType.elevated:
        return Theme.of(context).cardColor;
      case PremiumCardType.filled:
        return DesignSystem.neutralGray50;
      case PremiumCardType.outlined:
        return Colors.transparent;
    }
  }

  Border? _getBorder() {
    switch (widget.type) {
      case PremiumCardType.outlined:
        return Border.all(
          color: DesignSystem.neutralGray200,
          width: 1,
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? _getBoxShadow() {
    switch (widget.type) {
      case PremiumCardType.elevated:
        return _isHovered || _isPressed
            ? DesignSystem.shadowMedium
            : DesignSystem.shadowSmall;
      default:
        return null;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.isInteractive) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _resetState();
  }

  void _handleTapCancel() {
    _resetState();
  }

  void _resetState() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      if (!_isHovered) {
        _animationController.reverse();
      }
    }
  }

  void _handleHover(bool isHovered) {
    if (widget.onTap != null || widget.isInteractive) {
      setState(() => _isHovered = isHovered);
      if (isHovered && !_isPressed) {
        _animationController.forward();
      } else if (!isHovered && !_isPressed) {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            child: MouseRegion(
              onEnter: (_) => _handleHover(true),
              onExit: (_) => _handleHover(false),
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: DesignSystem.animationMedium,
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                    border: _getBorder(),
                    boxShadow: _getBoxShadow(),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                      onTap: widget.onTap,
                      child: Padding(
                        padding: widget.padding ?? const EdgeInsets.all(DesignSystem.spacing16),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
