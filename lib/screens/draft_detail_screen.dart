import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/resume_draft.dart';
import '../models/resume_template.dart';
import '../providers/premium_provider.dart';
import '../widgets/custom_button.dart';
import 'edit_content_screen.dart';
import 'premium_screen.dart';
import 'input_screen.dart';
import 'result_screen.dart';

class DraftDetailScreen extends StatefulWidget {
  final ResumeDraft draft;
  
  const DraftDetailScreen({
    super.key,
    required this.draft,
  });

  @override
  State<DraftDetailScreen> createState() => _DraftDetailScreenState();
}

class _DraftDetailScreenState extends State<DraftDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ResumeTemplate _template;
  
  @override
  void initState() {
    super.initState();
    _template = ResumeTemplates.getById(widget.draft.input.template);
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumProvider>().isPremium;
    final l10n = AppLocalizations.of(context)!;
    final watermark = l10n.watermarkMessage;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.draft.name),
        backgroundColor: _template.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.resume),
            Tab(text: l10n.coverLetter),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Resume Tab
                _buildTemplateContent(
                  'resume',
                  widget.draft.resumeContent ?? "",
                  isPremium,
                  watermark,
                ),
                
                // Cover Letter Tab
                _buildTemplateContent(
                  'coverLetter',
                  widget.draft.coverLetterContent ?? "",
                  isPremium,
                  watermark,
                ),
              ],
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: l10n.editDraft,
                        icon: Icons.edit,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InputScreen(
                                draftInput: widget.draft.input,
                                draftId: widget.draft.id,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: l10n.generateResume,
                        icon: Icons.refresh,
                        isPrimary: false,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultScreen(
                                input: widget.draft.input,
                                draftId: widget.draft.id,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                if (!isPremium) ...[
                  const SizedBox(height: 12),
                  CustomButton(
                    label: l10n.upgradePremium,
                    icon: Icons.workspace_premium,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PremiumScreen()),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTemplateContent(
    String type,
    String content,
    bool isPremium,
    String watermark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final displayContent = content + (!isPremium ? watermark : "");
    final title = type == 'resume' ? l10n.resume : l10n.coverLetter;
    
    if (content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              type == 'resume' 
                  ? 'No resume content available' 
                  : 'No cover letter content available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(
                      input: widget.draft.input,
                      draftId: widget.draft.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.generateResume),
            ),
          ],
        ),
      );
    }
    
    // Apply template-specific styling
    switch (_template.id) {
      case 'professional':
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _template.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: _template.primaryColor,
                          ),
                        ),
                        if (isPremium)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editContent(type),
                            tooltip: l10n.editContent,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    displayContent,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        );
        
      // Other template cases remain the same
      default: // standard and others
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (isPremium)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editContent(type),
                          tooltip: l10n.editContent,
                        ),
                    ],
                  ),
                  const Divider(),
                  SelectableText(
                    displayContent,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
  
  void _editContent(String type) {
    final l10n = AppLocalizations.of(context)!;
    final content = type == 'resume' 
        ? widget.draft.resumeContent 
        : widget.draft.coverLetterContent;
    
    if (content == null || content.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditContentScreen(
          initialContent: content,
          title: type == 'resume' ? l10n.editResume : l10n.editCoverLetter,
          onSave: (newContent) {
            // This would need to update the draft in the database
            // For now, we'll just show a message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Editing not implemented in preview')),
            );
          },
        ),
      ),
    );
  }
}
