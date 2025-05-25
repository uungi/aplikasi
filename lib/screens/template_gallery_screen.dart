import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/resume_template.dart';
import '../providers/premium_provider.dart';
import '../widgets/template_showcase.dart';
import '../widgets/template_category_filter.dart';
import '../screens/input_screen.dart';
import '../screens/premium_screen.dart';

class TemplateGalleryScreen extends StatefulWidget {
  const TemplateGalleryScreen({super.key});

  @override
  State<TemplateGalleryScreen> createState() => _TemplateGalleryScreenState();
}

class _TemplateGalleryScreenState extends State<TemplateGalleryScreen>
    with TickerProviderStateMixin {
  ResumeTemplate? _selectedTemplate;
  List<ResumeTemplate> _filteredTemplates = ResumeTemplates.all;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = context.watch<PremiumProvider>().isPremium;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Animated App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: AnimatedBuilder(
                animation: _headerSlideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_headerSlideAnimation.value, 0),
                    child: const Text(
                      'Template Gallery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                      Colors.purple.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          'assets/images/pattern.png',
                          repeat: ImageRepeat.repeat,
                          errorBuilder: (context, error, stackTrace) {
                            return Container();
                          },
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 60,
                      left: 16,
                      right: 16,
                      child: AnimatedBuilder(
                        animation: _headerAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _headerAnimationController.value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${ResumeTemplates.all.length} Professional Templates',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${ResumeTemplates.all.where((t) => t.isPremium).length} Premium Templates',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TemplateCategoryFilter(
                onFilterChanged: (templates) {
                  setState(() {
                    _filteredTemplates = templates;
                  });
                },
              ),
            ),
          ),

          // Template Showcase
          SliverFillRemaining(
            child: TemplateShowcase(
              onTemplateSelected: (template) {
                setState(() {
                  _selectedTemplate = template;
                });
              },
              selectedTemplate: _selectedTemplate,
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: _selectedTemplate != null
          ? AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton.extended(
                onPressed: () {
                  if (_selectedTemplate!.isPremium && !isPremium) {
                    _showPremiumDialog(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InputScreen(
                          selectedTemplate: _selectedTemplate!,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text('Use ${_selectedTemplate!.name}'),
                backgroundColor: _selectedTemplate!.primaryColor,
                foregroundColor: Colors.white,
              ),
            )
          : null,
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Premium Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Template "${_selectedTemplate!.name}" adalah template premium.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Upgrade ke Premium untuk akses:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Semua template premium\n• Download PDF\n• Tanpa watermark\n• Edit konten'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
            child: const Text('Upgrade Premium'),
          ),
        ],
      ),
    );
  }
}
