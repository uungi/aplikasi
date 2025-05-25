import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/api_key_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';

class ApiKeySetupScreen extends StatefulWidget {
  final bool isRequired;
  
  const ApiKeySetupScreen({
    super.key,
    this.isRequired = false,
  });

  @override
  State<ApiKeySetupScreen> createState() => _ApiKeySetupScreenState();
}

class _ApiKeySetupScreenState extends State<ApiKeySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  String? _currentApiKey;

  @override
  void initState() {
    super.initState();
    _loadCurrentApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentApiKey() async {
    try {
      final hasKey = await ApiKeyService.hasApiKey();
      if (hasKey) {
        final apiKey = await ApiKeyService.getApiKey();
        setState(() {
          _currentApiKey = ApiKeyService.getMaskedApiKey(apiKey);
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveApiKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiKeyService.setApiKey(_apiKeyController.text.trim());
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.apiKeySaved ?? 'API Key saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        if (widget.isRequired) {
          Navigator.of(context).pop(true);
        } else {
          await _loadCurrentApiKey();
          _apiKeyController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeApiKey() async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeApiKey ?? 'Remove API Key'),
        content: Text(l10n.removeApiKeyConfirmation ?? 'Are you sure you want to remove the API key?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.remove ?? 'Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiKeyService.clearApiKey();
        setState(() {
          _currentApiKey = null;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.apiKeyRemoved ?? 'API Key removed successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.apiKeySetup ?? 'API Key Setup'),
        automaticallyImplyLeading: !widget.isRequired,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Information card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              l10n.apiKeyInfo ?? 'API Key Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.apiKeyDescription ?? 
                          'To use AI features, you need to provide your OpenAI API key. '
                          'Your API key is stored securely on your device and is never shared.',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            // Open OpenAI API key page
                          },
                          child: Text(
                            'Get your API key from OpenAI →',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Current API key status
                if (_currentApiKey != null) ...[
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.currentApiKey ?? 'Current API Key',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                Text(
                                  _currentApiKey!,
                                  style: TextStyle(color: Colors.green.shade700),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade700),
                            onPressed: _removeApiKey,
                            tooltip: l10n.removeApiKey ?? 'Remove API Key',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // API key input
                Text(
                  _currentApiKey != null 
                    ? (l10n.updateApiKey ?? 'Update API Key')
                    : (l10n.enterApiKey ?? 'Enter API Key'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                TextFormField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: l10n.openaiApiKey ?? 'OpenAI API Key',
                    hintText: 'sk-...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.key),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: Validators.validateApiKey,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: _isLoading 
                      ? (l10n.saving ?? 'Saving...')
                      : (_currentApiKey != null 
                          ? (l10n.updateApiKey ?? 'Update API Key')
                          : (l10n.saveApiKey ?? 'Save API Key')),
                    icon: _isLoading ? null : Icons.save,
                    onPressed: _isLoading ? null : _saveApiKey,
                  ),
                ),
                
                if (widget.isRequired) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.apiKeyRequired ?? 'API Key is required to continue',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                const Spacer(),
                
                // Security notice
                Card(
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.securityNotice ?? 
                            'Your API key is encrypted and stored securely on your device. '
                            'It is never transmitted to our servers.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
