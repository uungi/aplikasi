import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/custom_template.dart';
import '../models/user_input.dart';
import '../widgets/custom_button.dart';
import 'input_screen.dart';

class TemplatePreviewScreen extends StatefulWidget {
  final CustomTemplate template;
  
  const TemplatePreviewScreen({
    super.key,
    required this.template,
  });

  @override
  State<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends State<TemplatePreviewScreen> {
  // Sample data for preview
  late UserInput _sampleInput;
  
  @override
  void initState() {
    super.initState();
    _sampleInput = UserInput(
      name: "John Doe",
      position: "Senior Software Developer",
      experiences: "• Senior Developer at Tech Corp (2020-Present)\n• Software Engineer at Innovate Inc (2017-2020)\n• Junior Developer at StartUp Co (2015-2017)",
      education: "• Master of Computer Science, University (2013-2015)\n• Bachelor of Information Technology, College (2009-2013)",
      skills: "• Programming: JavaScript, Python, Java, Flutter\n• Tools: Git, Docker, AWS\n• Soft Skills: Team Leadership, Problem Solving",
      contact: "john.doe@example.com | (123) 456-7890 | linkedin.com/in/johndoe",
      company: "Dream Tech Company",
      additional: "Passionate about creating efficient and user-friendly applications. Experienced in leading development teams and implementing agile methodologies.",
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.previewTemplate),
        backgroundColor: widget.template.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPreviewHeader(context, l10n.previewMode),
                  const SizedBox(height: 16),
                  _buildTemplatePreview(context),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomButton(
                  label: l10n.useTemplate,
                  icon: Icons.check_circle,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InputScreen(
                          customTemplate: widget.template,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: l10n.backToEdit,
                  icon: Icons.edit,
                  isPrimary: false,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade700),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatePreview(BuildContext context) {
    final template = widget.template;
    final layout = template.layout;
    
    // Apply template-specific styling based on layout
    return Card(
      elevation: layout['section']?['elevation']?.toDouble() ?? 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          layout['section']?['borderRadius']?.toDouble() ?? 4.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(template),
          
          // Body
          Padding(
            padding: EdgeInsets.all(
              layout['body']?['padding']?.toDouble() ?? 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sections
                ...template.sections.map((section) {
                  return _buildSection(template, section);
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(CustomTemplate template) {
    final headerLayout = template.layout['header'] ?? {};
    final headerColor = _getColorFromTemplate(headerLayout['color'], template);
    final alignment = _getAlignment(headerLayout['alignment']);
    final padding = headerLayout['padding']?.toDouble() ?? 16.0;
    final borderRadius = headerLayout['borderRadius']?.toDouble() ?? 0.0;
    
    // Border
    BoxBorder? border;
    if (headerLayout['border'] != null) {
      final borderData = headerLayout['border'];
      if (borderData['bottom'] == true) {
        border = Border(
          bottom: BorderSide(
            color: _getColorFromTemplate(borderData['color'], template),
            width: borderData['width']?.toDouble() ?? 1.0,
          ),
        );
      } else if (borderData['all'] == true) {
        border = Border.all(
          color: _getColorFromTemplate(borderData['color'], template),
          width: borderData['width']?.toDouble() ?? 1.0,
        );
      }
    }
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: borderRadius > 0
            ? BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              )
            : null,
        border: border,
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            _sampleInput.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: headerColor == Colors.transparent
                  ? Colors.black
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _sampleInput.position,
            style: TextStyle(
              fontSize: 16,
              color: headerColor == Colors.transparent
                  ? Colors.grey.shade700
                  : Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _sampleInput.contact,
            style: TextStyle(
              fontSize: 14,
              color: headerColor == Colors.transparent
                  ? Colors.grey.shade600
                  : Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(CustomTemplate template, String sectionName) {
    final sectionLayout = template.layout['section'] ?? {};
    final titleLayout = template.layout['title'] ?? {};
    final textLayout = template.layout['text'] ?? {};
    
    final padding = sectionLayout['padding']?.toDouble() ?? 16.0;
    final margin = sectionLayout['margin']?.toDouble() ?? 0.0;
    final borderRadius = sectionLayout['borderRadius']?.toDouble() ?? 0.0;
    final elevation = sectionLayout['elevation']?.toDouble() ?? 0.0;
    
    // Border
    BoxBorder? border;
    if (sectionLayout['border'] != null) {
      final borderData = sectionLayout['border'];
      if (borderData['bottom'] == true) {
        border = Border(
          bottom: BorderSide(
            color: _getColorFromTemplate(borderData['color'], template),
            width: borderData['width']?.toDouble() ?? 1.0,
          ),
        );
      } else if (borderData['all'] == true) {
        border = Border.all(
          color: _getColorFromTemplate(borderData['color'], template),
          width: borderData['width']?.toDouble() ?? 1.0,
        );
      }
    }
    
    // Section content based on section name
    String title = sectionName.toUpperCase();
    String content = '';
    
    switch (sectionName.toLowerCase()) {
      case 'header':
        return const SizedBox.shrink(); // Header is already built separately
      case 'summary':
        content = _sampleInput.additional;
        break;
      case 'experience':
        content = _sampleInput.experiences;
        break;
      case 'education':
        content = _sampleInput.education;
        break;
      case 'skills':
        content = _sampleInput.skills;
        break;
      case 'contact':
        content = _sampleInput.contact;
        break;
      default:
        content = 'Sample content for $sectionName section';
    }
    
    // Section container
    Widget sectionWidget;
    if (sectionLayout['type'] == 'card') {
      sectionWidget = Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: border != null
              ? BorderSide(
                  color: _getColorFromTemplate(
                    sectionLayout['border']['color'],
                    template,
                  ),
                  width: sectionLayout['border']['width']?.toDouble() ?? 1.0,
                )
              : BorderSide.none,
        ),
        margin: EdgeInsets.all(margin),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: titleLayout['size']?.toDouble() ?? 18.0,
                  fontWeight: _getFontWeight(titleLayout['weight']),
                  color: _getColorFromTemplate(titleLayout['color'], template),
                ),
              ),
              SizedBox(height: titleLayout['spacing']?.toDouble() ?? 8.0),
              Text(
                content,
                style: TextStyle(
                  fontSize: textLayout['size']?.toDouble() ?? 14.0,
                  fontWeight: _getFontWeight(textLayout['weight']),
                  color: _getColorFromTemplate(textLayout['color'], template),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Default box type
      sectionWidget = Container(
        margin: EdgeInsets.all(margin),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleLayout['size']?.toDouble() ?? 18.0,
                fontWeight: _getFontWeight(titleLayout['weight']),
                color: _getColorFromTemplate(titleLayout['color'], template),
              ),
            ),
            SizedBox(height: titleLayout['spacing']?.toDouble() ?? 8.0),
            Text(
              content,
              style: TextStyle(
                fontSize: textLayout['size']?.toDouble() ?? 14.0,
                fontWeight: _getFontWeight(textLayout['weight']),
                color: _getColorFromTemplate(textLayout['color'], template),
              ),
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: template.layout['body']?['spacing']?.toDouble() ?? 16.0,
      ),
      child: sectionWidget,
    );
  }

  Color _getColorFromTemplate(String? colorName, CustomTemplate template) {
    switch (colorName) {
      case 'primary':
        return template.primaryColor;
      case 'accent':
        return template.accentColor;
      case 'text':
        return Colors.black87;
      case 'divider':
        return Colors.grey.shade300;
      case 'white':
        return Colors.white;
      case 'transparent':
        return Colors.transparent;
      default:
        return Colors.black87;
    }
  }

  CrossAxisAlignment _getAlignment(String? alignment) {
    switch (alignment) {
      case 'center':
        return CrossAxisAlignment.center;
      case 'right':
        return CrossAxisAlignment.end;
      case 'left':
      default:
        return CrossAxisAlignment.start;
    }
  }

  FontWeight _getFontWeight(String? weight) {
    switch (weight) {
      case 'bold':
        return FontWeight.bold;
      case 'medium':
        return FontWeight.w500;
      case 'light':
        return FontWeight.w300;
      case 'normal':
      default:
        return FontWeight.normal;
    }
  }
}
