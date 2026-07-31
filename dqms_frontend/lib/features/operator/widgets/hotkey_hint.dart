import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';

/// ============================================================================
/// REUSABLE KEYBOARD SHORTCUT BADGE (HotkeyHint)
/// High-visibility key combination badge for operator action buttons
/// ============================================================================
class HotkeyHint extends StatelessWidget {
  final String keyLabel;
  final bool isPrimary;

  const HotkeyHint({
    super.key,
    required this.keyLabel,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Shortcut key $keyLabel',
      readOnly: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white.withValues(alpha: 0.25) : AppColors.bgCanvas,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isPrimary ? Colors.white.withValues(alpha: 0.5) : AppColors.borderSubtle,
          ),
        ),
        child: Text(
          keyLabel,
          style: TextStyle(
            color: isPrimary ? Colors.white : AppColors.brandPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
