import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/user_input.dart';
import '../models/resume_template.dart';
import '../models/offline_template.dart';
import '../providers/language_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/offline_templates_provider.dart';

class AIService {
  final String baseUrl = "https://api.openai.com/v1/chat/completions";
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? "";
  final LanguageProvider? languageProvider;
  final ConnectivityProvider? connectivityProvider;
  final OfflineTemplatesProvider? offlineTemplatesProvider;

  AIService({
    this.languageProvider,
    this.connectivityProvider,
    this.offlineTemplatesProvider,
  });

  Future<String> generateResume(UserInput input) async {
    // Check if we're in offline mode
    if (connectivityProvider != null && connectivityProvider!.isActuallyOffline) {
      return _generateOfflineResume(input);
    }
    
    final template = ResumeTemplates.getById(input.template);
    final contentLanguage = languageProvider?.contentLanguage ?? 'en';
    
    String templatePrompt = _getResumeTemplatePrompt(template.id);
    String languagePrompt = _getLanguagePrompt(contentLanguage);
    
    final prompt = '''
$languagePrompt

Buatkan resume profesional untuk:
- Nama: ${input.name}
- Posisi: ${input.position}
- Pengalaman: ${input.experiences}
- Pendidikan: ${input.education}
- Keahlian: ${input.skills}
- Kontak: ${input.contact}
${input.additional.isNotEmpty ? "- Lain-lain: ${input.additional}" : ""}

$templatePrompt

Pastikan resume terstruktur dengan baik, mudah dibaca, dan menekankan kualifikasi yang relevan dengan posisi yang dilamar.
''';

    return _sendPrompt(prompt);
  }

  Future<String> generateCoverLetter(UserInput input) async {
    // Check if we're in offline mode
    if (connectivityProvider != null && connectivityProvider!.isActuallyOffline) {
      return _generateOfflineCoverLetter(input);
    }
    
    final template = ResumeTemplates.getById(input.template);
    final contentLanguage = languageProvider?.contentLanguage ?? 'en';
    
    String templatePrompt = _getCoverLetterTemplatePrompt(template.id);
    String languagePrompt = _getLanguagePrompt(contentLanguage);
    
    final prompt = '''
$languagePrompt

Buatkan surat lamaran kerja berdasarkan data berikut:
- Nama: ${input.name}
- Posisi: ${input.position}
- Pengalaman: ${input.experiences}
- Pendidikan: ${input.education}
- Keahlian: ${input.skills}
- Kontak: ${input.contact}
${input.company.isNotEmpty ? "- Perusahaan tujuan: ${input.company}" : ""}
${input.additional.isNotEmpty ? "- Lain-lain: ${input.additional}" : ""}

$templatePrompt

Surat lamaran harus mencakup:
1. Pembuka yang menarik
2. Penjelasan mengapa kandidat tertarik dengan posisi tersebut
3. Bagaimana kualifikasi kandidat sesuai dengan posisi
4. Penutup yang profesional dengan ajakan untuk wawancara
''';

    return _sendPrompt(prompt);
  }

  Future<String> _generateOfflineResume(UserInput input) async {
    if (offlineTemplatesProvider == null) {
      return "Offline mode is active but offline templates provider is not available.";
    }
    
    try {
      // Get resume templates
      final templates = await offlineTemplatesProvider!.getTemplatesByType('resume');
      if (templates.isEmpty) {
        return "No offline resume templates available. Please connect to the internet to generate a resume.";
      }
      
      // Use the first template (or you could select based on some criteria)
      final template = templates.first;
      String content = template.content;
      
      // Replace placeholders with user input
      content = content.replaceAll('[Full Name]', input.name);
      content = content.replaceAll('[Your Name]', input.name);
      content = content.replaceAll('[Position]', input.position);
      content = content.replaceAll('[Your Position/Title]', input.position);
      content = content.replaceAll('[Contact Information]', input.contact);
      
      // Add a note that this was generated offline
      content = "GENERATED OFFLINE\n\n" + content;
      
      return content;
    } catch (e) {
      return "Error generating offline resume: $e";
    }
  }

  Future<String> _generateOfflineCoverLetter(UserInput input) async {
    if (offlineTemplatesProvider == null) {
      return "Offline mode is active but offline templates provider is not available.";
    }
    
    try {
      // Get cover letter templates
      final templates = await offlineTemplatesProvider!.getTemplatesByType('coverLetter');
      if (templates.isEmpty) {
        return "No offline cover letter templates available. Please connect to the internet to generate a cover letter.";
      }
      
      // Use the first template (or you could select based on some criteria)
      final template = templates.first;
      String content = template.content;
      
      // Replace placeholders with user input
      content = content.replaceAll('[Your Name]', input.name);
      content = content.replaceAll('[Position]', input.position);
      if (input.company.isNotEmpty) {
        content = content.replaceAll('[Company Name]', input.company);
      } else {
        content = content.replaceAll('[Company Name]', "the company");
      }
      
      // Add a note that this was generated offline
      content = "GENERATED OFFLINE\n\n" + content;
      
      return content;
    } catch (e) {
      return "Error generating offline cover letter: $e";
    }
  }

  String _getLanguagePrompt(String languageCode) {
    switch (languageCode) {
      case 'id':
        return "Hasilkan konten dalam Bahasa Indonesia.";
      case 'es':
        return "Genera el contenido en español.";
      case 'fr':
        return "Générez le contenu en français.";
      case 'de':
        return "Erstellen Sie den Inhalt auf Deutsch.";
      case 'zh':
        return "用中文生成内容。";
      case 'ja':
        return "コンテンツを日本語で生成してください。";
      case 'ko':
        return "콘텐츠를 한국어로 생성하세요.";
      case 'en':
      default:
        return "Generate the content in English.";
    }
  }

  String _getResumeTemplatePrompt(String templateId) {
    switch (templateId) {
      case 'professional':
        return '''
Format resume dengan gaya profesional dan formal. Gunakan struktur yang jelas dengan heading dan bullet points.
Struktur resume sebagai berikut:
1. Nama dan kontak di bagian atas
2. Ringkasan profesional singkat (3-4 kalimat)
3. Pengalaman kerja dengan bullet points untuk setiap posisi
4. Pendidikan dengan format yang konsisten
5. Keahlian dikelompokkan berdasarkan kategori
Gunakan bahasa formal dan hindari kata ganti orang pertama.
''';
      
      case 'creative':
        return '''
Format resume dengan gaya kreatif dan modern. Tonjolkan keunikan dan kreativitas kandidat.
Struktur resume sebagai berikut:
1. Headline menarik dengan nama dan posisi
2. Bio profesional yang menunjukkan kepribadian (5-6 kalimat)
3. Pengalaman kerja dengan fokus pada pencapaian kreatif
4. Pendidikan dengan highlight pencapaian non-akademis
5. Keahlian dengan penekanan pada soft skills dan kreativitas
Gunakan bahasa yang ekspresif dan personal.
''';
      
      case 'academic':
        return '''
Format resume dengan gaya akademis. Fokus pada pendidikan, publikasi, dan pencapaian akademis.
Struktur resume sebagai berikut:
1. Informasi kontak lengkap di bagian atas
2. Latar belakang pendidikan dengan detail lengkap
3. Pengalaman penelitian dan publikasi (jika ada)
4. Pengalaman mengajar atau profesional
5. Keahlian akademis dan teknis
6. Penghargaan dan afiliasi
Gunakan bahasa formal dan akademis.
''';
      
      case 'minimal':
        return '''
Format resume dengan gaya minimalis. Fokus pada informasi penting dengan layout yang bersih.
Struktur resume sebagai berikut:
1. Nama dan kontak dengan format minimal
2. Ringkasan singkat (2-3 kalimat)
3. Pengalaman kerja dengan deskripsi singkat dan padat
4. Pendidikan dengan format minimal
5. Keahlian dalam format daftar sederhana
Gunakan bahasa yang efisien dan hindari kalimat bertele-tele.
''';
      
      case 'modern':
        return '''
Format resume dengan gaya modern dan kontemporer. Gunakan struktur yang dinamis.
Struktur resume sebagai berikut:
1. Header dengan nama dan posisi yang menonjol
2. Tagline profesional yang menarik
3. Pengalaman kerja dengan fokus pada hasil dan pencapaian
4. Pendidikan dengan highlight relevan
5. Keahlian dengan rating atau tingkat kemahiran
Gunakan bahasa yang profesional namun kontemporer.
''';
      
      case 'executive':
        return '''
Format resume dengan gaya eksekutif yang elegan. Fokus pada kepemimpinan dan pencapaian strategis.
Struktur resume sebagai berikut:
1. Header profesional dengan nama dan posisi eksekutif
2. Ringkasan eksekutif yang kuat (4-5 kalimat)
3. Pengalaman kerja dengan fokus pada kepemimpinan dan pencapaian bisnis
4. Pendidikan dan kredensial profesional
5. Keahlian kepemimpinan dan manajemen
Gunakan bahasa yang menunjukkan otoritas dan kepemimpinan.
''';
      
      case 'technical':
        return '''
Format resume dengan gaya teknikal. Fokus pada keahlian teknis dan pencapaian.
Struktur resume sebagai berikut:
1. Header dengan nama dan spesialisasi teknis
2. Ringkasan teknis yang menunjukkan keahlian utama
3. Keahlian teknis dengan detail tingkat kemahiran
4. Pengalaman kerja dengan fokus pada proyek teknis dan teknologi
5. Pendidikan dan sertifikasi teknis
Gunakan bahasa teknis yang relevan dengan industri.
''';
      
      default: // standard
        return '''
Format resume dengan gaya standar dan profesional.
Struktur resume sebagai berikut:
1. Informasi kontak di bagian atas
2. Ringkasan profesional
3. Pengalaman kerja
4. Pendidikan
5. Keahlian
Gunakan format yang mudah dibaca dan profesional.
''';
    }
  }

  String _getCoverLetterTemplatePrompt(String templateId) {
    switch (templateId) {
      case 'professional':
        return '''
Buat surat lamaran dengan gaya profesional dan formal. Gunakan bahasa yang sopan dan terstruktur.
Struktur surat:
1. Header formal dengan alamat dan tanggal
2. Salam pembuka formal
3. Paragraf pembuka yang menyebutkan posisi
4. 2-3 paragraf yang menjelaskan kualifikasi dengan bahasa formal
5. Paragraf penutup dengan permintaan wawancara
6. Salam penutup formal
''';
      
      case 'creative':
        return '''
Buat surat lamaran dengan gaya kreatif dan personal. Tunjukkan kepribadian dan passion kandidat.
Struktur surat:
1. Pembuka yang menarik perhatian
2. Narasi personal tentang ketertarikan pada posisi dan perusahaan
3. Ceritakan pengalaman dengan gaya storytelling
4. Tunjukkan bagaimana kreativitas kandidat bisa berkontribusi
5. Penutup yang memorable dan personal
''';
      
      case 'academic':
        return '''
Buat surat lamaran dengan gaya akademis. Fokus pada kualifikasi akademis dan penelitian.
Struktur surat:
1. Header formal dengan informasi kontak lengkap
2. Salam pembuka formal
3. Paragraf pembuka yang menyebutkan posisi akademis
4. Detail latar belakang akademis dan penelitian
5. Penjelasan tentang ketertarikan pada institusi
6. Penutup formal dengan referensi ke dokumen pendukung
''';
      
      case 'minimal':
        return '''
Buat surat lamaran dengan gaya minimalis. Langsung ke inti dengan bahasa yang efisien.
Struktur surat:
1. Header sederhana
2. Pembuka langsung yang menyebutkan posisi
3. 1-2 paragraf yang menjelaskan kualifikasi utama
4. Penutup singkat dengan ajakan untuk kontak
''';
      
      case 'modern':
        return '''
Buat surat lamaran dengan gaya modern dan dinamis. Tunjukkan relevansi dengan tren industri saat ini.
Struktur surat:
1. Header kontemporer
2. Pembuka yang menunjukkan pemahaman tentang perusahaan
3. Penjelasan bagaimana kandidat dapat memberikan nilai tambah
4. Referensi ke tren industri dan bagaimana kandidat mengikutinya
5. Penutup yang proaktif
''';
      
      case 'executive':
        return '''
Buat surat lamaran dengan gaya eksekutif yang elegan. Fokus pada kepemimpinan dan visi strategis.
Struktur surat:
1. Header profesional
2. Pembuka yang menunjukkan pemahaman mendalam tentang perusahaan
3. Penjelasan tentang pencapaian kepemimpinan dan visi
4. Bagaimana kandidat dapat membawa perubahan positif
5. Penutup yang menunjukkan inisiatif untuk diskusi lebih lanjut
''';
      
      case 'technical':
        return '''
Buat surat lamaran dengan gaya teknikal. Fokus pada keahlian teknis dan pengalaman proyek.
Struktur surat:
1. Header dengan spesialisasi teknis
2. Pembuka yang menunjukkan pemahaman tentang kebutuhan teknis perusahaan
3. Detail pengalaman teknis dan proyek relevan
4. Penjelasan tentang pendekatan teknis dan metodologi
5. Penutup dengan referensi ke portfolio atau demonstrasi teknis
''';
      
      default: // standard
        return '''
Buat surat lamaran dengan gaya standar dan profesional.
Struktur surat:
1. Header dengan informasi kontak
2. Salam pembuka
3. Paragraf pembuka yang menyebutkan posisi
4. 1-2 paragraf yang menjelaskan kualifikasi
5. Paragraf penutup dengan permintaan wawancara
6. Salam penutup
''';
    }
  }

  Future<String> _sendPrompt(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey"
        },
        body: json.encode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "max_tokens": 1000,
          "temperature": 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to generate content: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating content: $e');
      throw Exception('Network error: $e');
    }
  }
}
