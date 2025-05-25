import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/design_system.dart';

class PremiumInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool required;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autofocus;

  const PremiumInputField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.required = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
  });

  @override
  State<PremiumInputField> createState() => _PremiumInputFieldState();
}

class _PremiumInputFieldState extends State<PremiumInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late Animation<Color?> _borderColorAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _errorText;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignSystem.animationMedium,
      vsync: this,
    );
    
    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _borderColorAnimation = ColorTween(
      begin: DesignSystem.neutralGray300,
      end: DesignSystem.primaryBlue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(_handleFocusChange);
    
    if (widget.controller != null) {
      widget.controller!.addListener(_handleTextChange);
      _hasContent = widget.controller!.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    widget.controller?.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
      HapticFeedback.selectionClick();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTextChange() {
    final hasContent = widget.controller?.text.isNotEmpty ?? false;
    if (hasContent != _hasContent) {
      setState(() {
        _hasContent = hasContent;
      });
    }
  }

  void _validateInput(String? value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      if (error != _errorText) {
        setState(() {
          _errorText = error;
        });
      }
    }
  }

  Color get _borderColor {
    if (_errorText != null) {
      return DesignSystem.errorRed;
    }
    return _borderColorAnimation.value ?? DesignSystem.neutralGray300;
  }

  Color get _labelColor {
    if (_errorText != null) {
      return DesignSystem.errorRed;
    }
    if (_isFocused) {
      return DesignSystem.primaryBlue;
    }
    return DesignSystem.neutralGray600;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            if (widget.label.isNotEmpty) ...[
              RichText(
                text: TextSpan(
                  text: widget.label,
                  style: DesignSystem.bodySmall.copyWith(
                    color: _labelColor,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    if (widget.required)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: DesignSystem.errorRed,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: DesignSystem.spacing8),
            ],
            
            // Input Field
            AnimatedContainer(
              duration: DesignSystem.animationMedium,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                border: Border.all(
                  color: _borderColor,
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: DesignSystem.primaryBlue.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                textCapitalization: widget.textCapitalization,
                inputFormatters: widget.inputFormatters,
                onTap: widget.onTap,
                onChanged: (value) {
                  _validateInput(value);
                  widget.onChanged?.call(value);
                },
                onFieldSubmitted: widget.onSubmitted,
                validator: widget.validator,
                style: DesignSystem.bodyMedium.copyWith(
                  color: widget.enabled
                      ? DesignSystem.neutralGray900
                      : DesignSystem.neutralGray500,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: DesignSystem.bodyMedium.copyWith(
                    color: DesignSystem.neutralGray400,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _isFocused
                              ? DesignSystem.primaryBlue
                              : DesignSystem.neutralGray500,
                          size: 20,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? IconButton(
                          icon: Icon(
                            widget.suffixIcon,
                            color: _isFocused
                                ? DesignSystem.primaryBlue
                                : DesignSystem.neutralGray500,
                            size: 20,
                          ),
                          onPressed: widget.onSuffixTap,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: widget.prefixIcon != null ? 12 : 16,
                    vertical: 16,
                  ),
                  counterText: '',
                ),
              ),
            ),
            
            // Helper Text or Error
            if (widget.helperText != null || _errorText != null) ...[
              const SizedBox(height: DesignSystem.spacing8),
              Padding(
                padding: const EdgeInsets.only(left: DesignSystem.spacing4),
                child: Text(
                  _errorText ?? widget.helperText!,
                  style: DesignSystem.caption.copyWith(
                    color: _errorText != null
                        ? DesignSystem.errorRed
                        : DesignSystem.neutralGray600,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
