import 'package:flutter/material.dart';
import '../utils/flutter_version_validator.dart';

class FlutterVersionWarning extends StatefulWidget {
  const FlutterVersionWarning({super.key});

  @override
  State<FlutterVersionWarning> createState() => _FlutterVersionWarningState();
}

class _FlutterVersionWarningState extends State<FlutterVersionWarning> {
  CompatibilityCheck? _compatibilityCheck;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCompatibility();
  }

  Future<void> _checkCompatibility() async {
    final check = await FlutterVersionValidator.checkCompatibility();
    if (mounted) {
      setState(() {
        _compatibilityCheck = check;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    final check = _compatibilityCheck;
    if (check == null || check.buildSafe) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: check.validation.securityRisk ? Colors.red.shade50 : Colors.orange.shade50,
        border: Border.all(
          color: check.validation.securityRisk ? Colors.red : Colors.orange,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                check.validation.securityRisk ? Icons.security : Icons.warning,
                color: check.validation.securityRisk ? Colors.red : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  check.validation.securityRisk 
                    ? '🚨 SECURITY WARNING' 
                    : '⚠️ COMPATIBILITY WARNING',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: check.validation.securityRisk ? Colors.red : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            check.validation.message,
            style: TextStyle(
              fontSize: 14,
              color: check.validation.securityRisk ? Colors.red.shade700 : Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            check.validation.recommendation,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (check.validation.securityRisk) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔒 IMMEDIATE ACTIONS REQUIRED:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1. Stop using this Flutter version immediately\n'
                    '2. Download official Flutter from flutter.dev\n'
                    '3. Scan your system for malware\n'
                    '4. Verify all downloads with checksums',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
