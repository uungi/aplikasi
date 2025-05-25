import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/premium_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/connectivity_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/connectivity_status.dart';
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
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          // Toggle dark/light mode
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: l10n.toggleTheme,
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Connectivity status indicator
          const ConnectivityStatus(),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo or image
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description,
                            size: 80,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.appTitle,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.appSubtitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Offline mode toggle
                  SwitchListTile(
                    title: Text(l10n.offlineMode),
                    subtitle: Text(l10n.offlineModeDescription),
                    value: connectivityProvider.isOfflineMode,
                    onChanged: (value) {
                      connectivityProvider.setOfflineMode(value);
                    },
                    secondary: Icon(
                      connectivityProvider.isOfflineMode
                          ? Icons.offline_bolt
                          : Icons.wifi,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Main action buttons
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomButton(
                          label: l10n.createResume,
                          icon: Icons.add_circle,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const InputScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          label: l10n.myDrafts,
                          icon: Icons.folder,
                          isPrimary: false,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DraftsScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                label: l10n.customTemplates,
                                icon: Icons.style,
                                isPrimary: false,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomButton(
                                label: l10n.offlineTemplates,
                                icon: Icons.offline_bolt,
                                isPrimary: false,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const OfflineTemplatesScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Premium banner
                  if (!isPremium)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: CustomButton(
                        label: l10n.upgradePremium,
                        icon: Icons.workspace_premium,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PremiumScreen()),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
