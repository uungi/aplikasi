import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../models/custom_template.dart';
import '../providers/templates_provider.dart';
import '../widgets/custom_button.dart';
import 'template_preview_screen.dart';
import '../utils/validators.dart';
import '../utils/input_sanitizer.dart';
import '../utils/app_logger.dart';

class TemplateEditorScreen extends StatefulWidget {
  final CustomTemplate? template;
  
  const TemplateEditorScreen({
    super.key,
    this.template,
  });

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late Color _primaryColor;
  late Color _accentColor;
  late String _templateType;
  late Map<String, dynamic> _layout;
  late List<String> _sections;
  late String _fontFamily;
  late double _fontSize;
  
  bool _isEditing = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    _isEditing = widget.template != null;
    
    if (_isEditing) {
      // Initialize with existing template data
      _nameController.text = widget.template!.name;
      _descriptionController.text = widget.template!.description;
      _primaryColor = widget.template!.primaryColor;
      _accentColor = widget.template!.accentColor;
      _layout = Map.from(widget.template!.layout);
      _sections = List.from(widget.template!.sections);
      _fontFamily = widget.template!.fontFamily;
      _fontSize = widget.template!.fontSize;
      _templateType = _getTemplateTypeFromLayout(_layout);
    } else {
      // Initialize with default values
      _primaryColor = const Color(0xFF4A6572);
      _accentColor = const Color(0xFFFF8A65);
      _templateType = 'standard';
      _layout = CustomTemplate.getDefaultLayout(_templateType);
      _sections = CustomTemplate.getDefaultSections();
      _fontFamily = 'Roboto';
      _fontSize = 14.0;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  String _getTemplateTypeFromLayout(Map<String, dynamic> layout) {
    // Try to determine template type from layout
    if (layout['header']?['color'] == 'primary') {
      return 'modern';
    } else if (layout['header']?['color'] == 'transparent') {
      return 'minimal';
    } else if (layout['header']?['border']?['bottom'] == true) {
      return 'professional';
    } else if (layout['header']?['color'] == 'accent') {
      return 'creative';
    } else {
      return 'standard';
    }
  }
  
  void _updateTemplateType(String type) {
    setState(() {
      _templateType = type;
      _layout = CustomTemplate.getDefaultLayout(type);
    });
  }
  
  void _showColorPicker(BuildContext context, bool isPrimary) {
    final l10n = AppLocalizations.of(context)!;
    final color = isPrimary ? _primaryColor : _accentColor;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPrimary ? l10n.primaryColor : l10n.accentColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: color,
            onColorChanged: (newColor) {
              setState(() {
                if (isPrimary) {
                  _primaryColor = newColor;
                } else {
                  _accentColor = newColor;
                }
              });
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsv,
            pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.saveChanges),
          ),
        ],
      ),
    );
  }
  
  void _addSection() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final textController = TextEditingController();
        
        return AlertDialog(
          title: Text(l10n.addSection),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(
              labelText: l10n.sections,
              hintText: 'awards, projects, references, etc.',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final sectionName = textController.text.trim();
                final validationError = Validators.validateSectionName(sectionName);
                
                if (validationError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(validationError),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                final sanitizedSection = InputSanitizer.sanitizeText(sectionName).toLowerCase();
                
                if (!_sections.contains(sanitizedSection)) {
                  setState(() {
                    _sections.add(sanitizedSection);
                  });
                  AppLogger.userAction('section_added', {'section': sanitizedSection});
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Section already exists'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Text(l10n.addSection),
            ),
          ],
        );
      },
    );
  }
  
  void _removeSection(int index) {
    setState(() {
      _sections.removeAt(index);
    });
  }
  
  void _moveSection(int index, bool up) {
    if (up && index > 0) {
      setState(() {
        final section = _sections.removeAt(index);
        _sections.insert(index - 1, section);
      });
    } else if (!up && index < _sections.length - 1) {
      setState(() {
        final section = _sections.removeAt(index);
        _sections.insert(index + 1, section);
      });
    }
  }
  
  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final sanitizedName = InputSanitizer.sanitizeText(_nameController.text);
      final sanitizedDescription = InputSanitizer.sanitizeText(_descriptionController.text);
      
      AppLogger.userAction('template_save_started', {
        'is_editing': _isEditing,
        'template_type': _templateType,
      });
      
      final templatesProvider = Provider.of<TemplatesProvider>(context, listen: false);
      
      if (_isEditing) {
        // Update existing template
        final updatedTemplate = widget.template!.copyWith(
          name: sanitizedName,
          description: sanitizedDescription,
          primaryColor: _primaryColor,
          accentColor: _accentColor,
          layout: _layout,
          sections: _sections,
          fontFamily: _fontFamily,
          fontSize: _fontSize,
        );
        
        await templatesProvider.updateTemplate(updatedTemplate);
        AppLogger.userAction('template_updated', {'template_id': updatedTemplate.id});
      } else {
        // Create new template
        final template = CustomTemplate(
          name: sanitizedName,
          description: sanitizedDescription,
          primaryColor: _primaryColor,
          accentColor: _accentColor,
          layout: _layout,
          sections: _sections,
          fontFamily: _fontFamily,
          fontSize: _fontSize,
        );
        
        await templatesProvider.saveTemplate(template);
        AppLogger.userAction('template_created', {'template_id': template.id});
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.templateSaved)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      AppLogger.error('Failed to save template', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _previewTemplate() {
    if (!_formKey.currentState!.validate()) return;
    
    // Create a temporary template for preview
    final template = CustomTemplate(
      name: _nameController.text,
      description: _descriptionController.text,
      primaryColor: _primaryColor,
      accentColor: _accentColor,
      layout: _layout,
      sections: _sections,
      fontFamily: _fontFamily,
      fontSize: _fontSize,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TemplatePreviewScreen(template: template),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editTemplate : l10n.createTemplate),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: _previewTemplate,
            tooltip: l10n.previewTemplate,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Basic Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.personalInfo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: l10n.templateName,
                              border: const OutlineInputBorder(),
                            ),
                            validator: Validators.validateTemplateName,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: l10n.templateDescription,
                              border: const OutlineInputBorder(),
                            ),
                            validator: Validators.validateTemplateDescription,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Template Type
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.templateType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _templateType,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'standard',
                                child: Text(l10n.standard),
                              ),
                              DropdownMenuItem(
                                value: 'modern',
                                child: Text(l10n.modern),
                              ),
                              DropdownMenuItem(
                                value: 'minimal',
                                child: Text(l10n.minimal),
                              ),
                              DropdownMenuItem(
                                value: 'professional',
                                child: Text(l10n.professional),
                              ),
                              DropdownMenuItem(
                                value: 'creative',
                                child: Text(l10n.creative),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                _updateTemplateType(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Colors
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.theme,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showColorPicker(context, true),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        l10n.primaryColor,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showColorPicker(context, false),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _accentColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        l10n.accentColor,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sections
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.sections,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addSection,
                                tooltip: l10n.addSection,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._sections.asMap().entries.map((entry) {
                            final index = entry.key;
                            final section = entry.value;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  section.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                leading: Icon(
                                  _getSectionIcon(section),
                                  color: _primaryColor,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_upward),
                                      onPressed: index > 0 ? () => _moveSection(index, true) : null,
                                      tooltip: l10n.moveUp,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_downward),
                                      onPressed: index < _sections.length - 1 ? () => _moveSection(index, false) : null,
                                      tooltip: l10n.moveDown,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeSection(index),
                                      tooltip: l10n.removeSection,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Save Button
                  CustomButton(
                    label: l10n.saveTemplate,
                    icon: Icons.save,
                    onPressed: _saveTemplate,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: l10n.previewTemplate,
                    icon: Icons.visibility,
                    isPrimary: false,
                    onPressed: _previewTemplate,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
  
  IconData _getSectionIcon(String section) {
    switch (section.toLowerCase()) {
      case 'header':
        return Icons.person;
      case 'summary':
        return Icons.summarize;
      case 'experience':
        return Icons.work;
      case 'education':
        return Icons.school;
      case 'skills':
        return Icons.psychology;
      case 'contact':
        return Icons.contact_phone;
      case 'projects':
        return Icons.build;
      case 'awards':
        return Icons.emoji_events;
      case 'references':
        return Icons.people;
      case 'languages':
        return Icons.language;
      case 'certifications':
        return Icons.card_membership;
      case 'interests':
        return Icons.interests;
      default:
        return Icons.article;
    }
  }
}
