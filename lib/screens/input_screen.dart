import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/user_input.dart';
import '../models/resume_template.dart';
import '../models/custom_template.dart';
import '../providers/premium_provider.dart';
import '../providers/drafts_provider.dart';
import '../providers/templates_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/template_preview_card.dart';
import 'result_screen.dart';
import 'premium_screen.dart';
import 'resume_preview_screen.dart';
import 'templates_screen.dart';

class InputScreen extends StatefulWidget {
  final UserInput? draftInput;
  final String? draftId;
  final CustomTemplate? customTemplate;
  
  const InputScreen({
    super.key,
    this.draftInput,
    this.draftId,
    this.customTemplate,
  });

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserInput _input;
  
  String _selectedTemplate = 'standard';
  String? _selectedCustomTemplateId;
  final _scrollController = ScrollController();
  bool _isEditingDraft = false;
  bool _isUsingCustomTemplate = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize input from draft if provided
    if (widget.draftInput != null) {
      _input = widget.draftInput!;
      _selectedTemplate = _input.template;
      _isEditingDraft = true;
      
      // Check if template is a custom template ID
      if (!ResumeTemplates.all.any((t) => t.id == _selectedTemplate)) {
        _selectedCustomTemplateId = _selectedTemplate;
        _isUsingCustomTemplate = true;
      }
    } else {
      _input = UserInput(
        name: "", position: "", experiences: "", education: "", skills: "", contact: ""
      );
      
      // If custom template is provided, use it
      if (widget.customTemplate != null) {
        _selectedCustomTemplateId = widget.customTemplate!.id;
        _selectedTemplate = widget.customTemplate!.id;
        _isUsingCustomTemplate = true;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectTemplate(String templateId) {
    final isPremiumUser = context.read<PremiumProvider>().isPremium;
    final template = ResumeTemplates.getById(templateId);
    
    if (template.isPremium && !isPremiumUser) {
      _showPremiumDialog();
      return;
    }
    
    setState(() {
      _selectedTemplate = templateId;
      _selectedCustomTemplateId = null;
      _isUsingCustomTemplate = false;
      _input.template = templateId;
    });
  }
  
  void _selectCustomTemplate(String templateId) {
    setState(() {
      _selectedTemplate = templateId;
      _selectedCustomTemplateId = templateId;
      _isUsingCustomTemplate = true;
      _input.template = templateId;
    });
  }
  
  void _showPremiumDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.premiumTemplate),
        content: Text(l10n.premiumTemplateMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
            child: Text(l10n.upgradePremium),
          ),
        ],
      ),
    );
  }

  void _previewResume() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _input.template = _selectedTemplate;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResumePreviewScreen(input: _input),
        ),
      );
    }
  }
  
  void _generateResume() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _input.template = _selectedTemplate;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            input: _input,
            draftId: widget.draftId,
          ),
        ),
      );
    }
  }
  
  Future<void> _saveDraft() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _input.template = _selectedTemplate;
      
      final l10n = AppLocalizations.of(context)!;
      final draftsProvider = Provider.of<DraftsProvider>(context, listen: false);
      
      // Show dialog to enter draft name
      final textController = TextEditingController(
        text: _isEditingDraft ? widget.draftInput?.name ?? '' : '${_input.position} - ${_input.name}'
      );
      
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.saveDraft),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(
              labelText: l10n.draftName,
              hintText: l10n.enterDraftName,
              border: const OutlineInputBorder(),
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
                if (textController.text.trim().isNotEmpty) {
                  Navigator.pop(context, textController.text.trim());
                }
              },
              child: Text(l10n.saveDraft),
            ),
          ],
        ),
      );
      
      if (result != null && result.isNotEmpty) {
        try {
          if (_isEditingDraft && widget.draftId != null) {
            // Update existing draft
            final draft = await draftsProvider.getDraft(widget.draftId!);
            if (draft != null) {
              final updatedDraft = draft.copyWith(
                name: result,
                input: _input,
              );
              await draftsProvider.updateDraft(updatedDraft);
            }
          } else {
            // Create new draft
            await draftsProvider.saveDraft(
              name: result,
              input: _input,
            );
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.draftSaved)),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremiumUser = context.watch<PremiumProvider>().isPremium;
    final templatesProvider = context.watch<TemplatesProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditingDraft ? l10n.editDraft : l10n.fillDataTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDraft,
            tooltip: l10n.saveDraft,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Text(
                l10n.fillDataTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Template selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.selectTemplate,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (!isPremiumUser)
                            TextButton.icon(
                              icon: const Icon(Icons.workspace_premium, size: 16),
                              label: Text(l10n.unlockAll),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Built-in templates
                      SizedBox(
                        height: 260,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: ResumeTemplates.all.length,
                          itemBuilder: (context, index) {
                            final template = ResumeTemplates.all[index];
                            return TemplatePreviewCard(
                              template: template,
                              isSelected: _selectedTemplate == template.id && !_isUsingCustomTemplate,
                              onSelect: () => _selectTemplate(template.id),
                            );
                          },
                        ),
                      ),
                      
                      // Custom templates section
                      if (templatesProvider.templates.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.customTemplates,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.style, size: 16),
                              label: Text(l10n.customizeTemplate),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 260,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: templatesProvider.templates.length,
                            itemBuilder: (context, index) {
                              final template = templatesProvider.templates[index];
                              return _buildCustomTemplateCard(
                                template,
                                isSelected: _selectedCustomTemplateId == template.id,
                                onSelect: () => _selectCustomTemplate(template.id),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: Text(l10n.createTemplate),
                          onPressed: () {
                            if (!isPremiumUser) {
                              _showPremiumDialog();
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Personal Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _input.name,
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (v) => v!.isEmpty ? l10n.requiredField : null,
                        onSaved: (v) => _input.name = v!,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _input.position,
                        decoration: InputDecoration(
                          labelText: l10n.position,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.work),
                        ),
                        validator: (v) => v!.isEmpty ? l10n.requiredField : null,
                        onSaved: (v) => _input.position = v!,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _input.contact,
                        decoration: InputDecoration(
                          labelText: l10n.contact,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.contact_phone),
                        ),
                        validator: (v) => v!.isEmpty ? l10n.requiredField : null,
                        onSaved: (v) => _input.contact = v!,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Experience & Education
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.experienceEducation,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _input.experiences,
                        decoration: InputDecoration(
                          labelText: l10n.workExperience,
                          hintText: l10n.workExperienceHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.business_center),
                        ),
                        maxLines: 3,
                        onSaved: (v) => _input.experiences = v ?? "",
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _input.education,
                        decoration: InputDecoration(
                          labelText: l10n.education,
                          hintText: l10n.educationHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.school),
                        ),
                        maxLines: 2,
                        onSaved: (v) => _input.education = v ?? "",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Skills & Additional Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.skillsAdditional,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _input.skills,
                        decoration: InputDecoration(
                          labelText: l10n.skills,
                          hintText: l10n.skillsHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.psychology),
                        ),
                        onSaved: (v) => _input.skills = v ?? "",
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _input.company,
                        decoration: InputDecoration(
                          labelText: l10n.targetCompany,
                          hintText: l10n.targetCompanyHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.business),
                        ),
                        onSaved: (v) => _input.company = v ?? "",
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _input.additional,
                        decoration: InputDecoration(
                          labelText: l10n.additionalInfo,
                          hintText: l10n.additionalInfoHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.info),
                        ),
                        maxLines: 2,
                        onSaved: (v) => _input.additional = v ?? "",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              CustomButton(
                label: l10n.previewResume,
                icon: Icons.visibility,
                onPressed: _previewResume,
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: l10n.generateResume,
                icon: Icons.auto_awesome,
                isPrimary: false,
                onPressed: _generateResume,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomTemplateCard(
    CustomTemplate template, {
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? template.primaryColor 
              : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: template.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template preview header
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: template.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Center(
              child: Text(
                template.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Template preview body
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom Template',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: template.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: template.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: template.accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Selected indicator
          if (isSelected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: template.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
