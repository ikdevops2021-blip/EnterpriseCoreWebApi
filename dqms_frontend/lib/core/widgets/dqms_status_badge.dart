import 'package:flutter/material.dart';
import '../enums/dqms_enums.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

/// ============================================================================
/// DQMS ENTERPRISE 3D SCI-FI STATUS BADGE
/// Features 3D embossed pill styling, neon rim glow, and live breathing
/// pulse animation for active, calling, or alert states.
/// ============================================================================
class DqmsStatusBadge extends StatefulWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isPulsing;

  const DqmsStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.isPulsing = false,
  });

  /// Factory constructor for Active / Deactive status
  factory DqmsStatusBadge.activeState(bool isActive) {
    return DqmsStatusBadge(
      label: isActive ? 'Active' : 'Deactive',
      color: isActive ? AppColors.statusActive : AppColors.statusDeactive,
      icon: isActive ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
      isPulsing: isActive,
    );
  }

  /// Factory constructor for Token Status enum (Category 18)
  factory DqmsStatusBadge.fromTokenStatus(e_TokenStatus status) {
    switch (status) {
      case e_TokenStatus.queued:
        return const DqmsStatusBadge(label: 'Queued', color: AppColors.textSubtle, icon: Icons.inbox_rounded);
      case e_TokenStatus.waiting:
        return const DqmsStatusBadge(label: 'Waiting', color: AppColors.statusWarning, icon: Icons.hourglass_empty_rounded, isPulsing: true);
      case e_TokenStatus.calling:
        return const DqmsStatusBadge(label: 'Calling', color: AppColors.brandPrimary, icon: Icons.campaign_rounded, isPulsing: true);
      case e_TokenStatus.active:
        return const DqmsStatusBadge(label: 'Active Serving', color: AppColors.statusActive, icon: Icons.play_arrow_rounded, isPulsing: true);
      case e_TokenStatus.hold:
        return const DqmsStatusBadge(label: 'On Hold', color: AppColors.statusSpecial, icon: Icons.pause_rounded);
      case e_TokenStatus.canceled:
        return const DqmsStatusBadge(label: 'Canceled', color: AppColors.statusDeactive, icon: Icons.close_rounded);
      case e_TokenStatus.completed:
        return const DqmsStatusBadge(label: 'Completed', color: AppColors.statusActive, icon: Icons.check_circle_rounded);
      case e_TokenStatus.forwarded:
        return const DqmsStatusBadge(label: 'Forwarded', color: AppColors.brandAccent, icon: Icons.forward_rounded);
    }
  }

  /// Factory constructor for Priority Tier enum (Category 19)
  factory DqmsStatusBadge.fromPriorityTier(int priorityValue) {
    if (priorityValue == e_PriorityTier.vip.value) {
      return const DqmsStatusBadge(label: 'VIP', color: AppColors.statusSpecial, icon: Icons.star_rounded, isPulsing: true);
    } else if (priorityValue == e_PriorityTier.emergency.value) {
      return const DqmsStatusBadge(label: 'Emergency', color: AppColors.statusDeactive, icon: Icons.warning_rounded, isPulsing: true);
    } else if (priorityValue == e_PriorityTier.seniorCitizen.value) {
      return const DqmsStatusBadge(label: 'Senior', color: AppColors.brandAccent, icon: Icons.elderly_rounded);
    } else if (priorityValue == e_PriorityTier.disabled.value) {
      return const DqmsStatusBadge(label: 'Disability', color: AppColors.statusWarning, icon: Icons.accessible_rounded);
    } else {
      return const DqmsStatusBadge(label: 'Standard', color: AppColors.textSubtle);
    }
  }

  @override
  State<DqmsStatusBadge> createState() => _DqmsStatusBadgeState();
}

class _DqmsStatusBadgeState extends State<DqmsStatusBadge> with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isPulsing) {
      _initPulse();
    }
  }

  void _initPulse() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant DqmsStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing != oldWidget.isPulsing) {
      if (widget.isPulsing) {
        if (_pulseController == null) {
          _initPulse();
        } else {
          _pulseController!.repeat(reverse: true);
        }
      } else {
        _pulseController?.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: ${widget.label}',
      readOnly: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.16),
          borderRadius: AppRadius.borderXs,
          border: Border.all(
            color: widget.color.withValues(alpha: 0.45),
            width: 1.0,
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0x15FFFFFF),
              offset: Offset(-0.5, -0.5),
              blurRadius: 0.5,
            ),
            BoxShadow(
              color: widget.color.withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Live Breathing Pulse Dot
              if (widget.isPulsing && _pulseAnimation != null)
                AnimatedBuilder(
                  animation: _pulseAnimation!,
                  builder: (context, child) {
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: _pulseAnimation!.value),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: _pulseAnimation!.value * 0.7),
                            blurRadius: 4 * _pulseAnimation!.value,
                            spreadRadius: 1 * _pulseAnimation!.value,
                          ),
                        ],
                      ),
                    );
                  },
                )
              else if (widget.icon != null) ...[
                Icon(widget.icon, size: 11, color: widget.color),
                const SizedBox(width: 4),
              ],
              Text(
                widget.label,
                style: AppTypography.tableHeader.copyWith(
                  color: widget.color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
