import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/premium_provider.dart';
import '../utils/validators.dart';
import '../utils/input_sanitizer.dart';
import '../utils/app_logger.dart';
import '../widgets/custom_button.dart';
import 'api_key_setup_screen.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _feedbackController = TextEditingController();
  final _feedbackFormKey = GlobalKey<FormState>();
  bool _isSubmittingFeedback = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_feedbackFormKey.currentState!.validate()) return;

    setState(() {
      _isSubmittingFeedback = true;
    });

    try {
      final sanitizedFeedback = InputSanitizer.sanitizeText(_feedbackController.text);
      
      AppLogger.userAction('feedback_submitted', {
        'feedback_length': sanitizedFeedback.length,
      });

      // Here you would typically send the feedback to your backend
      // For now, we'll just simulate a delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.feedbackSubmitted ?? 'Feedback submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _feedbackController.clear();
      }
    } catch (e) {
      AppLogger.error('Failed to submit feedback', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingFeedback = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final premiumProvider = context.watch<PremiumProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appSettings ?? 'App Settings',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Theme Setting
                  ListTile(
                    leading: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                    title: Text(l10n.theme),
                    subtitle: Text(
                      themeProvider.isDarkMode ? l10n.darkMode : l10n.lightMode,
                    ),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        AppLogger.userAction('theme_changed', {'dark_mode': value});
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Language Setting
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.language),
                    subtitle: Text(_getLanguageName(languageProvider.currentLanguage)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showLanguageDialog(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // AI Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aiSettings ?? 'AI Settings',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // API Key Management
                  ListTile(
                    leading: const Icon(Icons.key),
                    title: Text(l10n.apiKeyManagement ?? 'API Key Management'),
                    subtitle: Text(l10n.manageOpenaiKey ?? 'Manage your OpenAI API key'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      AppLogger.userAction('api_key_settings_opened');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ApiKeySetupScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Premium Section
          if (!premiumProvider.isPremium) ...[
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.workspace_premium, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          l10n.premium ?? 'Premium',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.premiumDescription ?? 'Unlock all templates and features',
                      style: TextStyle(color: Colors.amber.shade700),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: l10n.upgradePremium,
                      icon: Icons.upgrade,
                      onPressed: () {
                        AppLogger.userAction('premium_upgrade_from_settings');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PremiumScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Feedback Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.feedback ?? 'Feedback',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _feedbackFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _feedbackController,
                          decoration: InputDecoration(
                            labelText: l10n.yourFeedback ?? 'Your Feedback',
                            hintText: l10n.feedbackHint ?? 'Tell us what you think...',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.feedback),
                          ),
                          maxLines: 4,
                          validator: Validators.validateFeedback,
                          enabled: !_isSubmittingFeedback,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            label: _isSubmittingFeedback 
                              ? (l10n.submitting ?? 'Submitting...')
                              : (l10n.submitFeedback ?? 'Submit Feedback'),
                            icon: _isSubmittingFeedback ? null : Icons.send,
                            onPressed: _isSubmittingFeedback ? null : _submitFeedback,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // About Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.about ?? 'About',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: Text(l10n.appVersion ?? 'App Version'),
                    subtitle: const Text('1.0.0'),
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: Text(l10n.privacyPolicy ?? 'Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      AppLogger.userAction('privacy_policy_opened');
                      // Open privacy policy
                    },
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(l10n.termsOfService ?? 'Terms of Service'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      AppLogger.userAction('terms_of_service_opened');
                      // Open terms of service
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = context.read<LanguageProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage ?? 'Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: languageProvider.currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  AppLogger.userAction('language_changed', {'language': value});
                  languageProvider.setLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es',
              groupValue: languageProvider.currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  AppLogger.userAction('language_changed', {'language': value});
                  languageProvider.setLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Bahasa Indonesia'),
              value: 'id',
              groupValue: languageProvider.currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  AppLogger.userAction('language_changed', {'language': value});
                  languageProvider.setLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
