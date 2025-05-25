import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../utils/input_sanitizer.dart';
import '../utils/app_logger.dart';

class ValidatedTextFormField extends StatefulWidget {
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool required;
  final String fieldType;
  final TextEditingController? controller;

  const ValidatedTextFormField({
    super.key,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.fieldType = 'text',
    this.controller,
  });

  @override
  State<ValidatedTextFormField> createState() => _ValidatedTextFormFieldState();
}

class _ValidatedTextFormFieldState extends State<ValidatedTextFormField> {
  late TextEditingController _controller;
  bool _hasBeenFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  String? _getValidator(String? value) {
    // Use custom validator if provided
    if (widget.validator != null) {
      return widget.validator!(value);
    }

    // Use built-in validators based on field type
    switch (widget.fieldType.toLowerCase()) {
      case 'name':
        return Validators.validateName(value);
      case 'email':
        return Validators.validateEmail(value);
      case 'phone':
        return Validators.validatePhone(value);
      case 'position':
        return Validators.validatePosition(value);
      case 'contact':
        return Validators.validateContact(value);
      case 'apikey':
        return Validators.validateApiKey(value);
      case 'templatename':
        return Validators.validateTemplateName(value);
      case 'templatedescription':
        return Validators.validateTemplateDescription(value);
      case 'templatecontent':
        return Validators.validateTemplateContent(value);
      case 'sectionname':
        return Validators.validateSectionName(value);
      case 'feedback':
        return Validators.validateFeedback(value);
      case 'contentlength':
        return Validators.validateContentLength(value);
      default:
        if (widget.required) {
          return Validators.validateRequired(value, widget.labelText ?? 'Field');
        }
        return null;
    }
  }

  void _onChanged(String value) {
    // Log suspicious content
    if (InputSanitizer.containsSuspiciousContent(value)) {
      AppLogger.security('suspicious_input_detected', {
        'field_type': widget.fieldType,
        'field_label': widget.labelText,
        'content_length': value.length,
      });
    }

    // Call the provided onChanged callback
    widget.onChanged?.call(value);
  }

  void _onSaved(String? value) {
    if (value != null) {
      final sanitizedValue = InputSanitizer.sanitizeText(value);
      widget.onSaved?.call(sanitizedValue);
      
      AppLogger.debug('Field saved', {
        'field_type': widget.fieldType,
        'original_length': value.length,
        'sanitized_length': sanitizedValue.length,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus && !_hasBeenFocused) {
          _hasBeenFocused = true;
          AppLogger.userAction('field_focused', {
            'field_type': widget.fieldType,
            'field_label': widget.labelText,
          });
        }
      },
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: widget.suffixIcon != null
              ? IconButton(
                  icon: Icon(widget.suffixIcon),
                  onPressed: widget.onSuffixIconPressed,
                )
              : null,
          counterText: widget.maxLength != null ? null : '',
        ),
        obscureText: widget.obscureText,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        enabled: widget.enabled,
        validator: _getValidator,
        onSaved: _onSaved,
        onChanged: _onChanged,
      ),
    );
  }
}

// Specialized form fields for common use cases
class NameFormField extends StatelessWidget {
  final String? initialValue;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final bool enabled;
  final TextEditingController? controller;

  const NameFormField({
    super.key,
    this.initialValue,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextFormField(
      initialValue: initialValue,
      labelText: 'Full Name',
      hintText: 'Enter your full name',
      prefixIcon: Icons.person,
      fieldType: 'name',
      required: true,
      onSaved: onSaved,
      onChanged: onChanged,
      enabled: enabled,
      controller: controller,
    );
  }
}

class EmailFormField extends StatelessWidget {
  final String? initialValue;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool required;
  final TextEditingController? controller;

  const EmailFormField({
    super.key,
    this.initialValue,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextFormField(
      initialValue: initialValue,
      labelText: 'Email',
      hintText: 'Enter your email address',
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      fieldType: 'email',
      required: required,
      onSaved: onSaved,
      onChanged: onChanged,
      enabled: enabled,
      controller: controller,
    );
  }
}

class PhoneFormField extends StatelessWidget {
  final String? initialValue;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool required;
  final TextEditingController? controller;

  const PhoneFormField({
    super.key,
    this.initialValue,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextFormField(
      initialValue: initialValue,
      labelText: 'Phone Number',
      hintText: 'Enter your phone number',
      prefixIcon: Icons.phone,
      keyboardType: TextInputType.phone,
      fieldType: 'phone',
      required: required,
      onSaved: onSaved,
      onChanged: onChanged,
      enabled: enabled,
      controller: controller,
    );
  }
}

class PositionFormField extends StatelessWidget {
  final String? initialValue;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final bool enabled;
  final TextEditingController? controller;

  const PositionFormField({
    super.key,
    this.initialValue,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextFormField(
      initialValue: initialValue,
      labelText: 'Position',
      hintText: 'Enter the position you are applying for',
      prefixIcon: Icons.work,
      fieldType: 'position',
      required: true,
      onSaved: onSaved,
      onChanged: onChanged,
      enabled: enabled,
      controller: controller,
    );
  }
}
