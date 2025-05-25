import 'package:flutter/material.dart';
import '../models/user_input.dart';
import '../models/resume_template.dart';
import '../widgets/custom_button.dart';
import 'result_screen.dart';

class ResumePreviewScreen extends StatelessWidget {
  final UserInput input;
  
  const ResumePreviewScreen({
    super.key,
    required this.input,
  });

  @override
  Widget build(BuildContext context) {
    final template = ResumeTemplates.getById(input.template);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview Resume"),
        backgroundColor: template.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPreviewHeader(context, "Preview Mode"),
                  const SizedBox(height: 16),
                  _buildTemplatePreview(context, template),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomButton(
                  label: "Generate Full Resume & Cover Letter",
                  icon: Icons.auto_awesome,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultScreen(input: input),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: "Back to Edit",
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

  Widget _buildTemplatePreview(BuildContext context, ResumeTemplate template) {
    // Apply different preview styles based on template
    switch (template.id) {
      case 'professional':
        return _buildProfessionalPreview(context, template);
      case 'creative':
        return _buildCreativePreview(context, template);
      case 'minimal':
        return _buildMinimalPreview(context, template);
      case 'technical':
        return _buildTechnicalPreview(context, template);
      case 'academic':
        return _buildAcademicPreview(context, template);
      case 'modern':
        return _buildModernPreview(context, template);
      case 'executive':
        return _buildExecutivePreview(context, template);
      default:
        return _buildStandardPreview(context, template);
    }
  }

  Widget _buildStandardPreview(BuildContext context, ResumeTemplate template) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              input.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              input.position,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              input.contact,
              style: const TextStyle(fontSize: 14),
            ),
            const Divider(height: 32),
            _buildSectionTitle("Resume", template.primaryColor),
            const SizedBox(height: 8),
            _buildPreviewSection("Ringkasan Profesional"),
            _buildPreviewText("Profesional berpengalaman di bidang ${input.position} dengan keahlian dalam ${input.skills}."),
            const SizedBox(height: 16),
            _buildPreviewSection("Pengalaman"),
            _buildPreviewText(input.experiences.isNotEmpty 
              ? input.experiences 
              : "• Posisi di Perusahaan (20XX-20XX)\n• Posisi di Perusahaan (20XX-20XX)"),
            const SizedBox(height: 16),
            _buildPreviewSection("Pendidikan"),
            _buildPreviewText(input.education.isNotEmpty 
              ? input.education 
              : "• Gelar, Institusi (20XX-20XX)\n• Gelar, Institusi (20XX-20XX)"),
            const SizedBox(height: 16),
            _buildPreviewSection("Keahlian"),
            _buildPreviewText(input.skills.isNotEmpty 
              ? input.skills 
              : "• Keahlian 1\n• Keahlian 2\n• Keahlian 3"),
            const Divider(height: 32),
            _buildSectionTitle("Surat Lamaran", template.primaryColor),
            const SizedBox(height: 8),
            _buildPreviewText("Kepada Yth.\nHRD ${input.company.isNotEmpty ? input.company : 'Perusahaan'}\n\nDengan hormat,\n\nSaya ${input.name}, ingin mengajukan lamaran untuk posisi ${input.position}...\n\n[Isi surat lamaran lengkap akan dibuat oleh AI]"),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalPreview(BuildContext context, ResumeTemplate template) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: template.primaryColor,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      input.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: template.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      input.position,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  input.contact,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("RESUME", template.primaryColor),
                const SizedBox(height: 8),
                _buildPreviewSection("RINGKASAN PROFESIONAL"),
                _buildPreviewText("Profesional berpengalaman di bidang ${input.position} dengan keahlian dalam ${input.skills}."),
                const SizedBox(height: 16),
                _buildPreviewSection("PENGALAMAN"),
                _buildPreviewText(input.experiences.isNotEmpty 
                  ? input.experiences 
                  : "• Posisi di Perusahaan (20XX-20XX)\n• Posisi di Perusahaan (20XX-20XX)"),
                const SizedBox(height: 16),
                _buildPreviewSection("PENDIDIKAN"),
                _buildPreviewText(input.education.isNotEmpty 
                  ? input.education 
                  : "• Gelar, Institusi (20XX-20XX)\n• Gelar, Institusi (20XX-20XX)"),
                const SizedBox(height: 16),
                _buildPreviewSection("KEAHLIAN"),
                _buildPreviewText(input.skills.isNotEmpty 
                  ? input.skills 
                  : "• Keahlian 1\n• Keahlian 2\n• Keahlian 3"),
                const Divider(height: 32),
                _buildSectionTitle("SURAT LAMARAN", template.primaryColor),
                const SizedBox(height: 8),
                _buildPreviewText("Kepada Yth.\nHRD ${input.company.isNotEmpty ? input.company : 'Perusahaan'}\n\nDengan hormat,\n\nSaya ${input.name}, ingin mengajukan lamaran untuk posisi ${input.position}...\n\n[Isi surat lamaran lengkap akan dibuat oleh AI]"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreativePreview(BuildContext context, ResumeTemplate template) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: template.accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  input.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  input.position,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  input.contact,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: template.accentColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ABOUT ME",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: template.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPreviewText("Creative professional with a passion for ${input.position}. Skilled in ${input.skills}."),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: template.accentColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "EXPERIENCE",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: template.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPreviewText(input.experiences.isNotEmpty 
                        ? input.experiences 
                        : "• Creative Role at Studio (20XX-20XX)\n• Design Position at Agency (20XX-20XX)"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: template.accentColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "COVER LETTER",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: template.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPreviewText("Dear Creative Team,\n\nI'm ${input.name}, a passionate ${input.position} looking to bring my creative vision to your team...\n\n[Full creative cover letter will be generated by AI]"),
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

  Widget _buildMinimalPreview(BuildContext context, ResumeTemplate template) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            input.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            input.contact,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildPreviewText("Profesional di bidang ${input.position} dengan pengalaman dalam ${input.skills}."),
          const SizedBox(height: 24),
          const Text(
            "EXPERIENCE",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildPreviewText(input.experiences.isNotEmpty 
            ? input.experiences 
            : "Position, Company (20XX-20XX)\nPosition, Company (20XX-20XX)"),
          const SizedBox(height: 24),
          const Text(
            "EDUCATION",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildPreviewText(input.education.isNotEmpty 
            ? input.education 
            : "Degree, Institution (20XX-20XX)"),
          const SizedBox(height: 24),
          const Text(
            "SKILLS",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildPreviewText(input.skills.isNotEmpty 
            ? input.skills 
            : "Skill 1, Skill 2, Skill 3"),
          const Divider(height: 40),
          const Text(
            "COVER LETTER",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildPreviewText("To Whom It May Concern,\n\nI am writing to apply for the ${input.position} position...\n\n[Minimal cover letter will be generated by AI]"),
        ],
      ),
    );
  }

  Widget _buildTechnicalPreview(BuildContext context, ResumeTemplate template) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: template.primaryColor, width: 2),
                top: BorderSide(color: template.primaryColor, width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      input.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: template.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      input.position,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Text(
                  input.contact,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: template.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: const Text(
                          'RESUME',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                      Container(
                        color: template.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: const Text(
                          'LETTER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreviewSection("Technical Skills"),
                      _buildPreviewText(input.skills.isNotEmpty 
                        ? input.skills 
                        : "• Programming: Language 1, Language 2\n• Tools: Tool 1, Tool 2\n• Methodologies: Agile, Scrum"),
                      const SizedBox(height: 16),
                      _buildPreviewSection("Experience"),
                      _buildPreviewText(input.experiences.isNotEmpty 
                        ? input.experiences 
                        : "• Technical Role, Company (20XX-20XX)\n• Developer, Company (20XX-20XX)"),
                      const SizedBox(height: 16),
                      _buildPreviewSection("Education"),
                      _buildPreviewText(input.education.isNotEmpty 
                        ? input.education 
                        : "• B.S. Computer Science, University (20XX-20XX)"),
                      const SizedBox(height: 24),
                      _buildPreviewText("Dear Hiring Manager,\n\nI am a ${input.position} with expertise in ${input.skills}...\n\n[Technical cover letter will be generated by AI]"),
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

  Widget _buildAcademicPreview(BuildContext context, ResumeTemplate template) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    input.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: template.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    input.position,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    input.contact,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Text(
              "EDUCATION",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: template.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildPreviewText(input.education.isNotEmpty 
              ? input.education 
              : "• Ph.D. in Field, University (20XX-20XX)\n• M.S. in Field, University (20XX-20XX)\n• B.S. in Field, University (20XX-20XX)"),
            const SizedBox(height: 16),
            Text(
              "RESEARCH EXPERIENCE",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: template.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildPreviewText(input.experiences.isNotEmpty 
              ? input.experiences 
              : "• Research Position, Institution (20XX-20XX)\n• Research Assistant, Laboratory (20XX-20XX)"),
            const SizedBox(height: 16),
            Text(
              "SKILLS & EXPERTISE",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: template.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildPreviewText(input.skills.isNotEmpty 
              ? input.skills 
              : "• Research Methods: Method 1, Method 2\n• Technical Skills: Skill 1, Skill 2\n• Languages: Language 1, Language 2"),
            const Divider(height: 32),
            Text(
              "COVER LETTER",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: template.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildPreviewText("Dear Selection Committee,\n\nI am writing to apply for the ${input.position} position at ${input.company.isNotEmpty ? input.company : 'your institution'}...\n\n[Academic cover letter will be generated by AI]"),
          ],
        ),
      ),
    );
  }

  Widget _buildModernPreview(BuildContext context, ResumeTemplate template) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: template.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  input.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: template.accentColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    input.position,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  input.contact,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: template.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "PROFILE",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: template.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPreviewText("Dynamic professional with expertise in ${input.position} and skills in ${input.skills}."),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.work, color: template.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "EXPERIENCE",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: template.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPreviewText(input.experiences.isNotEmpty 
                  ? input.experiences 
                  : "• Senior Role, Company (20XX-Present)\n• Junior Role, Company (20XX-20XX)"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.school, color: template.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "EDUCATION",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: template.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPreviewText(input.education.isNotEmpty 
                  ? input.education 
                  : "• Degree, University (20XX-20XX)"),
                const Divider(height: 32),
                Row(
                  children: [
                    Icon(Icons.mail, color: template.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "COVER LETTER",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: template.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPreviewText("Dear Hiring Team,\n\nI'm excited to apply for the ${input.position} role at ${input.company.isNotEmpty ? input.company : 'your company'}...\n\n[Modern cover letter will be generated by AI]"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutivePreview(BuildContext context, ResumeTemplate template) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: template.primaryColor,
              border: Border(
                bottom: BorderSide(
                  color: template.accentColor,
                  width: 3,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  input.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  input.position,
                  style: TextStyle(
                    fontSize: 16,
                    color: template.accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  input.contact,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "EXECUTIVE SUMMARY",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: template.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPreviewText("Accomplished executive with proven success in ${input.position} and strategic leadership in ${input.skills}."),
                const SizedBox(height: 16),
                Text(
                  "LEADERSHIP EXPERIENCE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: template.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPreviewText(input.experiences.isNotEmpty 
                  ? input.experiences 
                  : "• Chief Officer, Company (20XX-Present)\n  - Key achievement\n  - Strategic initiative\n• Director, Company (20XX-20XX)\n  - Leadership highlight\n  - Business impact"),
                const SizedBox(height: 16),
                Text(
                  "EDUCATION & CREDENTIALS",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: template.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPreviewText(input.education.isNotEmpty 
                  ? input.education 
                  : "• MBA, Business School (20XX)\n• B.S. Business Administration, University (20XX)"),
                const Divider(height: 32),
                Text(
                  "EXECUTIVE COVER LETTER",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: template.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPreviewText("Dear Board of Directors,\n\nWith a proven track record of leadership in ${input.position}, I am writing to express my interest in joining ${input.company.isNotEmpty ? input.company : 'your organization'}...\n\n[Executive cover letter will be generated by AI]"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildPreviewSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPreviewText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14),
    );
  }
}
