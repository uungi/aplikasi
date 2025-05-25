import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/resume_draft.dart';
import '../providers/drafts_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/custom_button.dart';
import 'input_screen.dart';
import 'result_screen.dart';
import 'draft_detail_screen.dart';

class DraftsScreen extends StatefulWidget {
  const DraftsScreen({super.key});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  @override
  void initState() {
    super.initState();
    // Load drafts when screen is opened
    Future.microtask(() => 
      Provider.of<DraftsProvider>(context, listen: false).loadDrafts()
    );
  }

  @override
  Widget build(BuildContext context) {
    final draftsProvider = Provider.of<DraftsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
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
        title: Text(l10n.savedDrafts),
        actions: [
          if (draftsProvider.drafts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _confirmClearAll(context),
              tooltip: l10n.clearAll,
            ),
        ],
      ),
      body: draftsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : draftsProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(draftsProvider.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => draftsProvider.loadDrafts(),
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                )
              : draftsProvider.drafts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noDrafts,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            label: l10n.newDraft,
                            icon: Icons.add,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const InputScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: draftsProvider.drafts.length,
                      itemBuilder: (context, index) {
                        final draft = draftsProvider.drafts[index];
                        return _buildDraftCard(context, draft);
                      },
                    ),
    );
  }

  Widget _buildDraftCard(BuildContext context, ResumeDraft draft) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Provider.of<LanguageProvider>(context).appLocale.languageCode;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _viewDraft(context, draft),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      draft.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          _viewDraft(context, draft);
                          break;
                        case 'edit':
                          _editDraft(context, draft);
                          break;
                        case 'rename':
                          _renameDraft(context, draft);
                          break;
                        case 'delete':
                          _confirmDeleteDraft(context, draft);
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
                            Text(l10n.viewDraft),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.editDraft),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            const Icon(Icons.drive_file_rename_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.renameDraft),
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
                              l10n.deleteDraft,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${draft.input.position} • ${draft.input.name}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.createdAt.replaceAll(
                      '{date}',
                      timeago.format(draft.createdAt, locale: locale),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    l10n.updatedAt.replaceAll(
                      '{date}',
                      timeago.format(draft.updatedAt, locale: locale),
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
      ),
    );
  }

  void _viewDraft(BuildContext context, ResumeDraft draft) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DraftDetailScreen(draft: draft),
      ),
    );
  }

  void _editDraft(BuildContext context, ResumeDraft draft) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InputScreen(draftInput: draft.input, draftId: draft.id),
      ),
    );
  }

  void _renameDraft(BuildContext context, ResumeDraft draft) {
    final l10n = AppLocalizations.of(context)!;
    final textController = TextEditingController(text: draft.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameDraft),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: l10n.draftName,
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
                final updatedDraft = draft.copyWith(
                  name: textController.text.trim(),
                );
                Provider.of<DraftsProvider>(context, listen: false)
                    .updateDraft(updatedDraft);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.saveChanges),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDraft(BuildContext context, ResumeDraft draft) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDraft),
        content: Text(l10n.confirmDeleteDraft),
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
              Provider.of<DraftsProvider>(context, listen: false)
                  .deleteDraft(draft.id);
              Navigator.pop(context);
            },
            child: Text(l10n.deleteDraft),
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
              Provider.of<DraftsProvider>(context, listen: false)
                  .deleteAllDrafts();
              Navigator.pop(context);
            },
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );
  }
}
