import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/advanced_admob_service.dart';
import '../widgets/premium_button.dart';
import '../utils/design_system.dart';

class RewardedAdButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function(bool success) onRewardEarned;
  final String placement;
  final Color? backgroundColor;
  
  const RewardedAdButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onRewardEarned,
    required this.placement,
    this.backgroundColor,
  });

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _showRewardedAd() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final success = await AdvancedAdMobService.showRewardedAd(
        placement: widget.placement,
        onUserEarnedReward: (reward) {
          // Haptic feedback
          HapticFeedback.lightImpact();
          
          // Show success message
          _showRewardDialog(reward.amount.toInt());
          
          // Call callback
          widget.onRewardEarned(true);
        },
      );
      
      if (!success) {
        _showErrorDialog();
        widget.onRewardEarned(false);
      }
    } catch (e) {
      _showErrorDialog();
      widget.onRewardEarned(false);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRewardDialog(int rewardAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignSystem.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: DesignSystem.successGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reward Earned!',
              style: DesignSystem.headingSmall.copyWith(
                color: DesignSystem.successGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You earned $rewardAmount coins for watching the ad!',
              style: DesignSystem.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton.primary(
              label: 'Awesome!',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignSystem.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_rounded,
                size: 48,
                color: DesignSystem.errorRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ad Not Available',
              style: DesignSystem.headingSmall.copyWith(
                color: DesignSystem.errorRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sorry, no ads are available right now. Please try again later.',
              style: DesignSystem.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton.outline(
              label: 'OK',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.backgroundColor ?? DesignSystem.accentOrange,
                  (widget.backgroundColor ?? DesignSystem.accentOrange).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (widget.backgroundColor ?? DesignSystem.accentOrange).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _showRewardedAd,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: DesignSystem.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: DesignSystem.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Icon(
                          Icons.play_circle_filled_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
