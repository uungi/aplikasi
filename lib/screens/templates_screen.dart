import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/custom_template.dart';
import '../providers/templates_provider.dart';
import '../providers/language_provider.dart';
import '../providers/premium_provider.dart';
import '../widgets/custom_button.dart';
import 'template_editor_screen.dart';
import 'premium_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  @override
  void initState() {
    super.initState();
    // Load templates when screen is opened
    Future.microtask(() => 
      Provider.of<TemplatesProvider>(context, listen: false).loadTemplates()
    );
  }

  @override
  Widget build(BuildContext context) {
    final templatesProvider = Provider.of<TemplatesProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isPremium = Provider.of<PremiumProvider>(context).isPremium;
    final l10n = AppLocalizations.of(context)!;
    
    // Set locale for timeago
    switch (languageProvider.appLocale.languageCode) {
      case 'id':
        timeago.setLocaleMessages('id', timeago.IdMessages());
        break;
      case 'es':
        timeago.setLocaleMessages('es', timeago.EsMessages());
        break;
      default:
        timeago.setLocaleMessages('en', timeago.EnMessages());
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customTemplates),
        actions: [
          if (templatesProvider.templates.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _confirmClearAll(context),
              tooltip: l10n.clearAll,
            ),
        ],
      ),
      body: templatesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : templatesProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(templatesProvider.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => templatesProvider.loadTemplates(),
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                )
              : templatesProvider.templates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.style_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noTemplates,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            label: l10n.createTemplate,
                            icon: Icons.add,
                            onPressed: () {
                              if (!isPremium) {
                                _showPremiumDialog(context);
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TemplateEditorScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: templatesProvider.templates.length,
                            itemBuilder: (context, index) {
                              final template = templatesProvider.templates[index];
                              return _buildTemplateCard(context, template);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CustomButton(
                            label: l10n.createTemplate,
                            icon: Icons.add,
                            onPressed: () {
                              if (!isPremium) {
                                _showPremiumDialog(context);
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TemplateEditorScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, CustomTemplate template) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Provider.of<LanguageProvider>(context).appLocale.languageCode;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _viewTemplate(context, template),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template header with primary color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: template.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          _viewTemplate(context, template);
                          break;
                        case 'edit':
                          _editTemplate(context, template);
                          break;
                        case 'delete':
                          _confirmDeleteTemplate(context, template);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            const Icon(Icons.visibility, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.previewTemplate),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.editTemplate),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              l10n.deleteTemplate,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Template content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildColorPreview(template.primaryColor, l10n.primaryColor),
                      const SizedBox(width: 16),
                      _buildColorPreview(template.accentColor, l10n.accentColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.createdAt.replaceAll(
                          '{date}',
                          timeago.format(template.createdAt, locale: locale),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        l10n.updatedAt.replaceAll(
                          '{date}',
                          timeago.format(template.updatedAt, locale: locale),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Template actions
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: Text(l10n.previewTemplate),
                    onPressed: () => _viewTemplate(context, template),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.editTemplate),
                    onPressed: () => _editTemplate(context, template),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _viewTemplate(BuildContext context, CustomTemplate template) {
    // Navigate to template preview screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TemplatePreviewScreen(template: template),
      ),
    );
  }

  void _editTemplate(BuildContext context, CustomTemplate template) {
    // Navigate to template editor screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TemplateEditorScreen(template: template),
      ),
    );
  }

  void _confirmDeleteTemplate(BuildContext context, CustomTemplate template) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTemplate),
        content: Text(l10n.confirmDeleteTemplate),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Provider.of<TemplatesProvider>(context, listen: false)
                  .deleteTemplate(template.id);
              Navigator.pop(context);
            },
            child: Text(l10n.deleteTemplate),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAll),
        content: Text(l10n.confirmClearAll),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Provider.of<TemplatesProvider>(context, listen: false)
                  .deleteAllTemplates();
              Navigator.pop(context);
            },
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );
  }
  
  void _showPremiumDialog(BuildContext context) {
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
}
