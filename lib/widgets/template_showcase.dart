import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/resume_template.dart';
import '../providers/premium_provider.dart';
import '../widgets/template_preview_card.dart';
import '../screens/premium_screen.dart';

class TemplateShowcase extends StatefulWidget {
  final Function(ResumeTemplate) onTemplateSelected;
  final ResumeTemplate? selectedTemplate;

  const TemplateShowcase({
    super.key,
    required this.onTemplateSelected,
    this.selectedTemplate,
  });

  @override
  State<TemplateShowcase> createState() => _TemplateShowcaseState();
}

class _TemplateShowcaseState extends State<TemplateShowcase>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumProvider>().isPremium;
    final allTemplates = ResumeTemplates.all;
    
    final freeTemplates = allTemplates.where((t) => !t.isPremium).toList();
    final premiumTemplates = allTemplates.where((t) => t.isPremium).toList();
    final popularTemplates = [
      ResumeTemplates.professional,
      ResumeTemplates.luxury,
      ResumeTemplates.techStartup,
      ResumeTemplates.creative,
      ResumeTemplates.finance,
      ResumeTemplates.designer,
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).primaryColor,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Popular'),
                Tab(text: 'Free'),
                Tab(text: 'Premium'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTemplateGrid(popularTemplates, 'popular'),
                _buildTemplateGrid(freeTemplates, 'free'),
                _buildTemplateGrid(premiumTemplates, 'premium'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateGrid(List<ResumeTemplate> templates, String category) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = widget.selectedTemplate?.id == template.id;
        
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue = Curves.easeOutBack.transform(
              (_animationController.value - delay).clamp(0.0, 1.0),
            );
            
            return Transform.scale(
              scale: animationValue,
              child: _buildTemplateCard(template, isSelected, category),
            );
          },
        );
      },
    );
  }

  Widget _buildTemplateCard(ResumeTemplate template, bool isSelected, String category) {
    final isPremiumUser = context.watch<PremiumProvider>().isPremium;
    final isLocked = template.isPremium && !isPremiumUser;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          _showPremiumDialog(context);
        } else {
          widget.onTemplateSelected(template);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? template.primaryColor 
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: template.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              // Template Preview
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            template.primaryColor,
                            template.primaryColor.withOpacity(0.8),
                            template.accentColor.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: _buildTemplatePreview(template),
                    ),
                    
                    // Lock overlay
                    if (isLocked)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: template.accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Selection indicator
                    if (isSelected)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check,
                            color: template.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    
                    // Category badge
                    if (category == 'popular')
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '🔥 HOT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Template Info
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        template.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: template.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatePreview(ResumeTemplate template) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 3,
                  width: 60,
                  color: template.accentColor,
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2,
                  width: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 2),
                Container(
                  height: 2,
                  width: 50,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Content sections
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 2,
                      width: 30,
                      color: template.primaryColor,
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: 1,
                      width: 50,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 1),
                    Container(
                      height: 1,
                      width: 45,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
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
            Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Premium Template'),
          ],
        ),
        content: const Text(
          'Template ini hanya tersedia untuk pengguna Premium. Upgrade sekarang untuk mengakses semua template premium!',
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
