import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/premium_provider.dart';
import '../services/advanced_admob_service.dart';
import '../utils/design_system.dart';

class SmartAdBanner extends StatefulWidget {
  final String placement;
  final EdgeInsets? margin;
  final bool showOnlyForFreeUsers;
  
  const SmartAdBanner({
    super.key,
    required this.placement,
    this.margin,
    this.showOnlyForFreeUsers = true,
  });

  @override
  State<SmartAdBanner> createState() => _SmartAdBannerState();
}

class _SmartAdBannerState extends State<SmartAdBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumProvider>().isPremium;
    
    // Don't show ads for premium users
    if (widget.showOnlyForFreeUsers && isPremium) {
      return const SizedBox.shrink();
    }

    final adWidget = AdvancedAdMobService.getBannerAdWidget();
    
    if (adWidget == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Ad Label
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: DesignSystem.neutralGray100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'Advertisement',
                  style: DesignSystem.caption.copyWith(
                    color: DesignSystem.neutralGray600,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Ad Content
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: adWidget,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
