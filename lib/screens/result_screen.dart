import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/user_input.dart';
import '../models/resume_draft.dart';
import '../models/resume_template.dart';
import '../models/custom_template.dart';
import '../services/ai_service.dart';
import '../utils/admob_helper.dart';
import '../providers/premium_provider.dart';
import '../providers/language_provider.dart';
import '../providers/drafts_provider.dart';
import '../providers/templates_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/offline_templates_provider.dart';
import '../widgets/custom_button.dart';
import 'premium_screen.dart';
import 'edit_content_screen.dart';

class ResultScreen extends StatefulWidget {
  final UserInput input;
  final String? draftId;
  
  const ResultScreen({
    super.key,
    required this.input,
    this.draftId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  String? resume;
  String? coverLetter;
  bool loading = true;
  String? error;
  InterstitialAd? _interstitialAd;
  late TabController _tabController;
  bool _autoSaveDraft = true;
  
  // Template properties
  late Color _primaryColor;
  late Color _accentColor;
  bool _isCustomTemplate = false;
  CustomTemplate? _customTemplate;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInterstitialAd();
    _initializeTemplate();
    _generate();
  }
  
  void _initializeTemplate() {
    final templatesProvider = Provider.of<TemplatesProvider>(context, listen: false);
    
    // Check if template is a custom template
    if (ResumeTemplates.all.any((t) => t.id == widget.input.template)) {
      // Built-in template
      final template = ResumeTemplates.getById(widget.input.template);
      _primaryColor = template.primaryColor;
      _accentColor = template.accentColor;
      _isCustomTemplate = false;
    } else {
      // Try to find custom template
      final customTemplate = templatesProvider.templates.firstWhere(
        (t) => t.id == widget.input.template,
        orElse: () => CustomTemplate(
          name: "Custom",
          description: "Custom template",
          primaryColor: const Color(0xFF4A6572),
          accentColor: const Color(0xFFFF8A65),
          layout: CustomTemplate.getDefaultLayout('standard'),
          sections: CustomTemplate.getDefaultSections(),
        ),
      );
      
      _customTemplate = customTemplate;
      _primaryColor = customTemplate.primaryColor;
      _accentColor = customTemplate.accentColor;
      _isCustomTemplate = true;
    }
  }
  
  @override
  void dispose() {
    _interstitialAd?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInterstitialAd() async {
    _interstitialAd = await AdmobHelper.loadInterstitialAd();
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to show: $error');
        },
      );
      _interstitialAd!.show();
    }
  }

  Future<void> _generate() async {
    setState(() { loading = true; });
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
    final offlineTemplatesProvider = Provider.of<OfflineTemplatesProvider>(context, listen: false);
    
    final ai = AIService(
      languageProvider: languageProvider,
      connectivityProvider: connectivityProvider,
      offlineTemplatesProvider: offlineTemplatesProvider,
    );
    
    try {
      // Generate both resume and cover letter in parallel
      final results = await Future.wait([
        ai.generateResume(widget.input),
        ai.generateCoverLetter(widget.input),
      ]);
      
      setState(() {
        resume = results[0];
        coverLetter = results[1];
        loading = false;
      });
      
      // Auto-save draft if enabled
      if (_autoSaveDraft) {
        _saveGeneratedContentToDraft();
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }
  
  Future<void> _saveGeneratedContentToDraft() async {
    if (resume == null || coverLetter == null) return;
    
    final draftsProvider = Provider.of<DraftsProvider>(context, listen: false);
    
    try {
      if (widget.draftId != null) {
        // Update existing draft
        final draft = await draftsProvider.getDraft(widget.draftId!);
        if (draft != null) {
          final updatedDraft = draft.copyWith(
            input: widget.input,
            resumeContent: resume,
            coverLetterContent: coverLetter,
          );
          await draftsProvider.updateDraft(updatedDraft);
        }
      } else {
        // Create new draft
        final draftName = '${widget.input.position} - ${widget.input.name}';
        await draftsProvider.saveDraft(
          name: draftName,
          input: widget.input,
          resumeContent: resume,
          coverLetterContent: coverLetter,
        );
      }
    } catch (e) {
      debugPrint('Error saving draft: $e');
      // Don't show error to user for auto-save
    }
  }
  
  Future<void> _retryGenerate() async {
    setState(() {
      error = null;
    });
    await _generate();
  }

  Future<void> _downloadPDF(BuildContext context) async {
    final isPremium = context.read<PremiumProvider>().isPremium;
    if (!isPremium) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }
    
    final doc = pw.Document();
    
    // Add fonts
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    final fontItalic = await PdfGoogleFonts.nunitoItalic();
    
    // Convert template colors to PDF colors
    final primaryColor = PdfColor.fromInt(_primaryColor.value);
    final accentColor = PdfColor.fromInt(_accentColor.value);
    
    // Create PDF based on template
    if (_isCustomTemplate && _customTemplate != null) {
      // Custom template PDF
      final layout = _customTemplate!.layout;
      
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) {
            // Header based on custom template
            final headerLayout = layout['header'] ?? {};
            final padding = headerLayout['padding']?.toDouble() ?? 16.0;
            
            return pw.Container(
              padding: pw.EdgeInsets.all(padding),
              decoration: pw.BoxDecoration(
                border: headerLayout['border']?['bottom'] == true
                    ? pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 2))
                    : null,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    widget.input.name,
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 24,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    widget.input.position,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 16,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    widget.input.contact,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
          build: (context) => [
            pw.SizedBox(height: 10),
            pw.Text(
              'RESUME',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              resume ?? '',
              style: pw.TextStyle(font: font),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              'COVER LETTER',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              coverLetter ?? '',
              style: pw.TextStyle(font: font),
            ),
          ],
        ),
      );
    } else {
      // Built-in template PDF
      final templateId = widget.input.template;
      
      switch (templateId) {
        case 'professional':
          doc.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(40),
              header: (context) => pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 8),
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 2))
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      widget.input.name,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 24,
                        color: primaryColor,
                      ),
                    ),
                    pw.Text(
                      widget.input.contact,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              build: (context) => [
                pw.SizedBox(height: 10),
                pw.Text(
                  'RESUME',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  resume ?? '',
                  style: pw.TextStyle(font: font),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'COVER LETTER',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  coverLetter ?? '',
                  style: pw.TextStyle(font: font),
                ),
              ],
            ),
          );
          break;
          
        // Other template cases remain the same
        default: // standard and others
          doc.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(32),
              header: (context) => pw.Center(
                child: pw.Text(
                  'Generated with AI Resume Generator',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              build: (context) => [
                pw.Text(
                  'Resume',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 20,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  resume ?? '',
                  style: pw.TextStyle(font: font),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'Cover Letter',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 20,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  coverLetter ?? '',
                  style: pw.TextStyle(font: font),
                ),
              ],
            ),
          );
      }
    }
    
    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: "${widget.input.name} - Resume & Cover Letter",
    );
  }
  
  Future<void> _sharePlainText() async {
    final l10n = AppLocalizations.of(context)!;
    final text = "${l10n.resume}:\n\n$resume\n\n" +
                 "${l10n.coverLetter}:\n\n$coverLetter\n\n" +
                 "Generated with AI Resume Generator";
    
    await Share.share(text);
  }
  
  void _editContent(String type) {
    final l10n = AppLocalizations.of(context)!;
    final content = type == 'resume' ? resume : coverLetter;
    if (content == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditContentScreen(
          initialContent: content,
          title: type == 'resume' ? l10n.editResume : l10n.editCoverLetter,
          onSave: (newContent) {
            setState(() {
              if (type == 'resume') {
                resume = newContent;
              } else {
                coverLetter = newContent;
              }
            });
            
            // Update draft if editing from a draft
            if (widget.draftId != null) {
              _saveGeneratedContentToDraft();
            }
          },
        ),
      ),
    );
  }
  
  Future<void> _saveDraft() async {
    if (resume == null || coverLetter == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    final draftsProvider = Provider.of<DraftsProvider>(context, listen: false);
    
    // Show dialog to enter draft name
    final textController = TextEditingController(
      text: '${widget.input.position} - ${widget.input.name}'
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
        if (widget.draftId != null) {
          // Update existing draft
          final draft = await draftsProvider.getDraft(widget.draftId!);
          if (draft != null) {
            final updatedDraft = draft.copyWith(
              name: result,
              input: widget.input,
              resumeContent: resume,
              coverLetterContent: coverLetter,
            );
            await draftsProvider.updateDraft(updatedDraft);
          }
        } else {
          // Create new draft
          await draftsProvider.saveDraft(
            name: result,
            input: widget.input,
            resumeContent: resume,
            coverLetterContent: coverLetter,
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

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumProvider>().isPremium;
    final connectivityProvider = context.watch<ConnectivityProvider>();
    final l10n = AppLocalizations.of(context)!;
    final watermark = l10n.watermarkMessage;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.generateResume),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!loading && error == null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveDraft,
              tooltip: l10n.saveDraft,
            ),
        ],
        bottom: loading || error != null ? null : TabBar(
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
          // Offline mode indicator
          if (connectivityProvider.isActuallyOffline)
            Container(
              color: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    connectivityProvider.isOfflineMode
                        ? Icons.offline_bolt
                        : Icons.wifi_off,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    connectivityProvider.isOfflineMode
                        ? l10n.offlineModeActive
                        : l10n.noInternetConnection,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          
          // Main content
          Expanded(
            child: loading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(l10n.generating),
                    ],
                  ),
                )
              : error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.generationError.replaceAll('{error}', error!),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            label: l10n.tryAgain,
                            icon: Icons.refresh,
                            onPressed: _retryGenerate,
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Resume Tab
                            _buildTemplateContent(
                              'resume',
                              resume ?? "",
                              isPremium,
                              watermark,
                            ),
                            
                            // Cover Letter Tab
                            _buildTemplateContent(
                              'coverLetter',
                              coverLetter ?? "",
                              isPremium,
                              watermark,
                            ),
                          ],
                        ),
                      ),
                      
                      // Auto-save option
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _autoSaveDraft,
                              onChanged: (value) {
                                setState(() {
                                  _autoSaveDraft = value ?? true;
                                });
                              },
                            ),
                            Text(l10n.autoSave),
                            const Spacer(),
                            TextButton.icon(
                              icon: const Icon(Icons.save),
                              label: Text(l10n.saveDraft),
                              onPressed: _saveDraft,
                            ),
                          ],
                        ),
                      ),
                      
                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            if (!isPremium)
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
                            if (isPremium) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      label: l10n.downloadPDF,
                                      icon: Icons.picture_as_pdf,
                                      onPressed: () => _downloadPDF(context),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomButton(
                                      label: l10n.shareText,
                                      icon: Icons.share,
                                      isPrimary: false,
                                      onPressed: _sharePlainText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
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
    
    if (_isCustomTemplate && _customTemplate != null) {
      // Custom template styling
      final layout = _customTemplate!.layout;
      final sectionLayout = layout['section'] ?? {};
      final titleLayout = layout['title'] ?? {};
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: sectionLayout['elevation']?.toDouble() ?? 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              sectionLayout['borderRadius']?.toDouble() ?? 4.0,
            ),
          ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleLayout['size']?.toDouble() ?? 18.0,
                        color: _primaryColor,
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
    } else {
      // Built-in template styling
      final templateId = widget.input.template;
      
      switch (templateId) {
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
                            color: _primaryColor,
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
                              color: _primaryColor,
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
  }
}
