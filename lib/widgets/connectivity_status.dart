import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectivityStatus extends StatelessWidget {
  const ConnectivityStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    
    if (connectivityProvider.isOfflineMode) {
      return Container(
        color: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.offline_bolt, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              l10n.offlineModeActive,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      );
    } else if (!connectivityProvider.hasInternetConnection) {
      return Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              l10n.noInternetConnection,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink(); // No indicator when online
  }
}
