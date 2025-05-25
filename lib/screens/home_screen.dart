import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/premium_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/connectivity_provider.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/accessibility_wrapper.dart';
import '../widgets/advanced_animations.dart';
import '../widgets/connectivity_status.dart';
import '../utils/design_system.dart';
import 'input_screen.dart';
import 'drafts_screen.dart';
import 'templates_screen.dart';
import 'premium_screen.dart';
import 'settings_screen.dart';
import 'offline_templates_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumProvider>().isPremium;
    final themeProvider = context.watch<ThemeProvider>();
    final connectivityProvider = context.watch<ConnectivityProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: DesignSystem.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacing20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SlideInAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: AccessibleText(
                            text: l10n.appTitle,
                            isHeader: true,
                            style: DesignSystem.headingLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: DesignSystem.spacing4),
                        SlideInAnimation(
                          delay: const Duration(milliseconds: 400),
                          child: AccessibleText(
                            text: l10n.appSubtitle,
                            style: DesignSystem.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                        const SizedBox(height: DesignSystem.spacing16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              // Theme Toggle with Animation
              ScaleInAnimation(
                delay: const Duration(milliseconds: 600),
                child: AccessibleButton(
                  semanticLabel: 'Toggle theme mode',
                  semanticHint: 'Switch between light and dark theme',
                  onPressed: themeProvider.toggleTheme,
                  child: IconButton(
                    icon: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.white,
                    ),
                    onPressed: themeProvider.toggleTheme,
                  ),
                ),
              ),
              // Settings
              ScaleInAnimation(
                delay: const Duration(milliseconds: 700),
                child: AccessibleButton(
                  semanticLabel: 'Open settings',
                  semanticHint: 'Navigate to app settings',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: IconButton(
                    icon: const Icon(Icons.settings_rounded, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: DesignSystem.spacing8),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connectivity Status
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 800),
                    child: const ConnectivityStatus(),
                  ),
                  const SizedBox(height: DesignSystem.spacing20),

                  // Quick Stats Section
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 900),
                    child: _buildQuickStatsSection(context),
                  ),
                  const SizedBox(height: DesignSystem.spacing24),

                  // Main Actions Section
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 1000),
                    child: _buildMainActionsSection(context, l10n),
                  ),
                  const SizedBox(height: DesignSystem.spacing24),

                  // Features Grid
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 1100),
                    child: _buildFeaturesGrid(context, l10n),
                  ),
                  const SizedBox(height: DesignSystem.spacing24),

                  // Offline Mode Toggle
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 1200),
                    child: _buildOfflineModeSection(context, l10n, connectivityProvider),
                  ),
                  const SizedBox(height: DesignSystem.spacing24),

                  // Premium Banner
                  if (!isPremium)
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 1300),
                      child: _buildPremiumBanner(context, l10n),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccessibleText(
          text: 'Quick Overview',
          isHeader: true,
          style: DesignSystem.headingSmall.copyWith(
            color: DesignSystem.neutralGray900,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        StaggeredListAnimation(
          itemDelay: const Duration(milliseconds: 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: PremiumCard.elevated(
                    isInteractive: true,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(DesignSystem.spacing12),
                          decoration: BoxDecoration(
                            color: DesignSystem.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                          ),
                          child: Icon(
                            Icons.description_rounded,
                            size: 32,
                            color: DesignSystem.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: DesignSystem.spacing12),
                        AccessibleText(
                          text: '12',
                          style: DesignSystem.headingMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: DesignSystem.primaryBlue,
                          ),
                        ),
                        AccessibleText(
                          text: 'Resumes Created',
                          style: DesignSystem.bodySmall.copyWith(
                            color: DesignSystem.neutralGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: DesignSystem.spacing16),
                Expanded(
                  child: PremiumCard.elevated(
                    isInteractive: true,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(DesignSystem.spacing12),
                          decoration: BoxDecoration(
                            color: DesignSystem.accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                          ),
                          child: Icon(
                            Icons.style_rounded,
                            size: 32,
                            color: DesignSystem.accentOrange,
                          ),
                        ),
                        const SizedBox(height: DesignSystem.spacing12),
                        AccessibleText(
                          text: '5',
                          style: DesignSystem.headingMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: DesignSystem.accentOrange,
                          ),
                        ),
                        AccessibleText(
                          text: 'Templates Used',
                          style: DesignSystem.bodySmall.copyWith(
                            color: DesignSystem.neutralGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainActionsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccessibleText(
          text: 'Quick Actions',
          isHeader: true,
          style: DesignSystem.headingSmall.copyWith(
            color: DesignSystem.neutralGray900,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        StaggeredListAnimation(
          itemDelay: const Duration(milliseconds: 150),
          children: [
            PulseAnimation(
              child: PremiumButton.primary(
                label: l10n.createResume,
                icon: Icons.add_circle_rounded,
                isFullWidth: true,
                size: PremiumButtonSize.large,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InputScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: DesignSystem.spacing12),
            Row(
              children: [
                Expanded(
                  child: PremiumButton.outline(
                    label: l10n.myDrafts,
                    icon: Icons.folder_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DraftsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: DesignSystem.spacing12),
                Expanded(
                  child: PremiumButton.outline(
                    label: 'Templates',
                    icon: Icons.style_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, AppLocalizations l10n) {
    final features = [
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'AI Powered',
        'subtitle': 'Smart resume generation with advanced AI',
        'color': DesignSystem.primaryBlue,
      },
      {
        'icon': Icons.palette_rounded,
        'title': 'Custom Templates',
        'subtitle': 'Beautiful, professional designs',
        'color': DesignSystem.accentOrange,
      },
      {
        'icon': Icons.offline_bolt_rounded,
        'title': 'Offline Mode',
        'subtitle': 'Work anywhere, anytime',
        'color': DesignSystem.successGreen,
      },
      {
        'icon': Icons.security_rounded,
        'title': 'Secure & Private',
        'subtitle': 'Your data is always protected',
        'color': DesignSystem.neutralGray600,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccessibleText(
          text: 'Features',
          isHeader: true,
          style: DesignSystem.headingSmall.copyWith(
            color: DesignSystem.neutralGray900,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: DesignSystem.spacing16,
            mainAxisSpacing: DesignSystem.spacing16,
            childAspectRatio: 1.1,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return ScaleInAnimation(
              delay: Duration(milliseconds: 200 + (index * 100)),
              child: PremiumCard.elevated(
                isInteractive: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DesignSystem.spacing12),
                      decoration: BoxDecoration(
                        color: (feature['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        size: 28,
                        color: feature['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacing12),
                    AccessibleText(
                      text: feature['title'] as String,
                      style: DesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DesignSystem.neutralGray900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignSystem.spacing4),
                    AccessibleText(
                      text: feature['subtitle'] as String,
                      style: DesignSystem.bodySmall.copyWith(
                        color: DesignSystem.neutralGray600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOfflineModeSection(
    BuildContext context,
    AppLocalizations l10n,
    ConnectivityProvider connectivityProvider,
  ) {
    return PremiumCard.filled(
      backgroundColor: DesignSystem.neutralGray50,
      child: AccessibilityWrapper(
        semanticLabel: 'Offline mode toggle',
        semanticHint: 'Enable or disable offline mode for the app',
        child: SwitchListTile(
          title: AccessibleText(
            text: l10n.offlineMode,
            style: DesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: AccessibleText(
            text: l10n.offlineModeDescription,
            style: DesignSystem.bodySmall.copyWith(
              color: DesignSystem.neutralGray600,
            ),
          ),
          value: connectivityProvider.isOfflineMode,
          onChanged: (value) {
            connectivityProvider.setOfflineMode(value);
          },
          secondary: Container(
            padding: const EdgeInsets.all(DesignSystem.spacing8),
            decoration: BoxDecoration(
              color: connectivityProvider.isOfflineMode
                  ? DesignSystem.accentOrange.withOpacity(0.1)
                  : DesignSystem.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
            ),
            child: Icon(
              connectivityProvider.isOfflineMode
                  ? Icons.offline_bolt_rounded
                  : Icons.wifi_rounded,
              color: connectivityProvider.isOfflineMode
                  ? DesignSystem.accentOrange
                  : DesignSystem.successGreen,
            ),
          ),
          activeColor: DesignSystem.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context, AppLocalizations l10n) {
    return PremiumCard.filled(
      backgroundColor: DesignSystem.accentOrange.withOpacity(0.05),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignSystem.spacing12),
                decoration: BoxDecoration(
                  gradient: DesignSystem.accentGradient,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: DesignSystem.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AccessibleText(
                      text: 'Upgrade to Premium',
                      style: DesignSystem.headingSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: DesignSystem.accentOrange,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacing4),
                    AccessibleText(
                      text: 'Unlock all features, templates, and unlimited resumes',
                      style: DesignSystem.bodySmall.copyWith(
                        color: DesignSystem.neutralGray700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing16),
          PremiumButton.secondary(
            label: l10n.upgradePremium,
            icon: Icons.arrow_forward_rounded,
            isFullWidth: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
