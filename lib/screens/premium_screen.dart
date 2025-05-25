import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/premium_provider.dart';
import '../services/purchase_service.dart';
import '../widgets/custom_button.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  late PurchaseService _purchaseService;
  
  @override
  void initState() {
    super.initState();
    _purchaseService = PurchaseService(
      onPurchaseUpdated: (isPremium) {
        if (isPremium) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Premium berhasil diaktifkan!"))
          );
        }
      },
    );
  }
  
  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
  
  Future<void> _buyPremium() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final success = await _purchaseService.buyPremium();
      
      if (!success) {
        setState(() {
          _errorMessage = "Gagal melakukan pembelian. Silakan coba lagi.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }
  
  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final success = await _purchaseService.restorePurchases();
      
      if (!success) {
        setState(() {
          _errorMessage = "Gagal memulihkan pembelian. Silakan coba lagi.";
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }
  
  // For development/testing only
  Future<void> _simulatePurchase() async {
    setState(() {
      _isLoading = true;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    await context.read<PremiumProvider>().setPremium(true);
    
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Premium berhasil diaktifkan (simulasi)!"))
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumProvider>().isPremium;
    
    return Scaffold(
      appBar: AppBar(title: const Text("Premium")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        size: 64,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Premium Features",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _PremiumFeatureItem(
                        icon: Icons.remove_circle,
                        text: "Tanpa watermark",
                      ),
                      const SizedBox(height: 12),
                      const _PremiumFeatureItem(
                        icon: Icons.picture_as_pdf,
                        text: "Download PDF",
                      ),
                      const SizedBox(height: 12),
                      const _PremiumFeatureItem(
                        icon: Icons.style,
                        text: "Akses semua template",
                      ),
                      const SizedBox(height: 12),
                      const _PremiumFeatureItem(
                        icon: Icons.edit_note,
                        text: "Edit hasil generate",
                      ),
                      const SizedBox(height: 12),
                      const _PremiumFeatureItem(
                        icon: Icons.favorite,
                        text: "Support pengembangan aplikasi",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              if (!isPremium) ...[
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        label: "Beli Premium (Rp 49.000)",
                        icon: Icons.shopping_cart,
                        onPressed: _buyPremium,
                      ),
                const SizedBox(height: 12),
                CustomButton(
                  label: "Pulihkan Pembelian",
                  icon: Icons.restore,
                  isPrimary: false,
                  onPressed: _restorePurchases,
                ),
                
                // For development only - remove in production
                if (true) // Set to false in production
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.developer_mode),
                      label: const Text("Simulasi Pembelian (DEV)"),
                      onPressed: _simulatePurchase,
                    ),
                  ),
              ],
              
              if (isPremium)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 48,
                          color: Colors.green,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Status: Premium Aktif!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Terima kasih sudah support ❤️",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
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
}

class _PremiumFeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _PremiumFeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
