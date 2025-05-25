import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityWrapper extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isButton;
  final bool isHeader;
  final bool isTextField;
  final VoidCallback? onTap;
  final bool excludeSemantics;
  final bool isLiveRegion;
  final String? value;

  const AccessibilityWrapper({
    super.key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.isButton = false,
    this.isHeader = false,
    this.isTextField = false,
    this.onTap,
    this.excludeSemantics = false,
    this.isLiveRegion = false,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      value: value,
      button: isButton,
      header: isHeader,
      textField: isTextField,
      onTap: onTap,
      liveRegion: isLiveRegion,
      child: child,
    );
  }
}

class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? semanticHint;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityWrapper(
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      isButton: true,
      onTap: onPressed,
      child: child,
    );
  }
}

class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isHeader;
  final String? semanticLabel;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AccessibleText({
    super.key,
    required this.text,
    this.style,
    this.isHeader = false,
    this.semanticLabel,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityWrapper(
      semanticLabel: semanticLabel ?? text,
      isHeader: isHeader,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
