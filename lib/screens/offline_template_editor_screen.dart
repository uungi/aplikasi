import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/offline_template.dart';
import '../providers/offline_templates_provider.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';
import '../utils/input_sanitizer.dart';
import '../utils/app_logger.dart';

class OfflineTemplateEditorScreen extends StatefulWidget {
  final OfflineTemplate template;
  final bool isNew;
  
  const OfflineTemplateEditorScreen({
    super.key,
    required this.template,
    this.isNew = false,
  });

  @override
  State<OfflineTemplateEditorScreen> createState() => _OfflineTemplateEditorScreenState();
}

class _OfflineTemplateEditorScreenState extends State<OfflineTemplateEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template.name);
    _contentController = TextEditingController(text: widget.template.content);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final l10n = AppLocalizations.of(context)!;
    final offlineTemplatesProvider = Provider.of<OfflineTemplatesProvider>(context, listen: false);
    
    try {
      final sanitizedName = InputSanitizer.sanitizeText(_nameController.text);
      final sanitizedContent = InputSanitizer.sanitizeText(_contentController.text);
      
      AppLogger.userAction('offline_template_save_started', {
        'is_new': widget.isNew,
        'template_type': widget.template.type,
      });
      
      final updatedTemplate = widget.template.copyWith(
        name: sanitizedName,
        content: sanitizedContent,
        updatedAt: DateTime.now(),
      );
      
      if (widget.isNew) {
        await offlineTemplatesProvider.saveTemplate(updatedTemplate);
        AppLogger.userAction('offline_template_created', {'template_id': updatedTemplate.id});
      } else {
        await offlineTemplatesProvider.updateTemplate(updatedTemplate);
        AppLogger.userAction('offline_template_updated', {'template_id': updatedTemplate.id});
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.templateSaved)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      AppLogger.error('Failed to save offline template', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? l10n.createTemplate : l10n.editTemplate),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveTemplate,
            tooltip: l10n.saveTemplate,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Template name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.templateName,
                        border: const OutlineInputBorder(),
                      ),
                      validator: Validators.validateTemplateName,
                    ),
                    const SizedBox(height: 16),
                    
                    // Template type (read-only)
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.templateType,
                        border: const OutlineInputBorder(),
                      ),
                      child: Text(
                        widget.template.type == 'resume'
                            ? l10n.resumeTemplate
                            : l10n.coverLetterTemplate,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Template content
                    Text(
                      l10n.templateContent,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: l10n.enterTemplateContent,
                          border: const OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        expands: true,
                        validator: Validators.validateTemplateContent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Help text
                    Text(
                      l10n.templateHelpText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Save button
                    CustomButton(
                      label: l10n.saveTemplate,
                      icon: Icons.save,
                      onPressed: _isLoading ? null : _saveTemplate,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
