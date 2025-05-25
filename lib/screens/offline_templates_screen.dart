import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../models/offline_template.dart';
import '../providers/offline_templates_provider.dart';
import '../widgets/custom_button.dart';
import 'offline_template_editor_screen.dart';

class OfflineTemplatesScreen extends StatelessWidget {
  const OfflineTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offlineTemplatesProvider = Provider.of<OfflineTemplatesProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.offlineTemplates),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _createNewTemplate(context);
            },
            tooltip: l10n.createTemplate,
          ),
        ],
      ),
      body: offlineTemplatesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : offlineTemplatesProvider.templates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.offline_bolt,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noOfflineTemplates,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        label: l10n.createTemplate,
                        icon: Icons.add,
                        onPressed: () => _createNewTemplate(context),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: offlineTemplatesProvider.templates.length,
                  itemBuilder: (context, index) {
                    final template = offlineTemplatesProvider.templates[index];
                    return _buildTemplateCard(context, template);
                  },
                ),
    );
  }
  
  Widget _buildTemplateCard(BuildContext context, OfflineTemplate template) {
    final l10n = AppLocalizations.of(context)!;
    final offlineTemplatesProvider = Provider.of<OfflineTemplatesProvider>(context, listen: false);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(template.name),
        subtitle: Text(
          template.type == 'resume' ? l10n.resumeTemplate : l10n.coverLetterTemplate,
        ),
        leading: Icon(
          template.type == 'resume' ? Icons.description : Icons.mail,
          color: Theme.of(context).primaryColor,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OfflineTemplateEditorScreen(template: template),
                  ),
                );
              },
              tooltip: l10n.editTemplate,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _confirmDeleteTemplate(context, template);
              },
              tooltip: l10n.deleteTemplate,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OfflineTemplateEditorScreen(template: template),
            ),
          );
        },
      ),
    );
  }
  
  void _createNewTemplate(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createTemplate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.resumeTemplate),
              leading: const Icon(Icons.description),
              onTap: () {
                Navigator.pop(context);
                _createTemplateOfType(context, 'resume');
              },
            ),
            ListTile(
              title: Text(l10n.coverLetterTemplate),
              leading: const Icon(Icons.mail),
              onTap: () {
                Navigator.pop(context);
                _createTemplateOfType(context, 'coverLetter');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
  
  void _createTemplateOfType(BuildContext context, String type) {
    final now = DateTime.now();
    final template = OfflineTemplate(
      id: const Uuid().v4(),
      name: type == 'resume' ? 'New Resume Template' : 'New Cover Letter Template',
      type: type,
      content: type == 'resume'
          ? '# RESUME TEMPLATE\n\nEnter your resume template content here.'
          : '# COVER LETTER TEMPLATE\n\nEnter your cover letter template content here.',
      createdAt: now,
      updatedAt: now,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OfflineTemplateEditorScreen(template: template, isNew: true),
      ),
    );
  }
  
  void _confirmDeleteTemplate(BuildContext context, OfflineTemplate template) {
    final l10n = AppLocalizations.of(context)!;
    final offlineTemplatesProvider = Provider.of<OfflineTemplatesProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTemplate),
        content: Text(l10n.deleteTemplateConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              offlineTemplatesProvider.deleteTemplate(template.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.templateDeleted)),
              );
            },
            child: Text(l10n.delete),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
