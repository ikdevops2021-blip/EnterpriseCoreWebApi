import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

/// ============================================================================
/// DQMS ENTERPRISE COMPACT SELECTION & OPTION CONTROLS
/// High-density Checkboxes, Radios, Switches, and Segmented Option Buttons.
/// Space-efficient, touch-friendly, and visually aligned with Stitch design tokens.
/// ============================================================================

/// Compact Checkbox with clickable row and optional description
class DqmsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String label;
  final String? subtitle;
  final Color? activeColor;
  final bool enabled;
  final bool isCompact;

  const DqmsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.subtitle,
    this.activeColor,
    this.enabled = true,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.brandPrimary;

    return InkWell(
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      borderRadius: AppRadius.borderSm,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 3.0 : 6.0,
          horizontal: isCompact ? 4.0 : 8.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: isCompact ? 20 : 24,
              height: isCompact ? 20 : 24,
              child: Transform.scale(
                scale: isCompact ? 0.85 : 1.0,
                child: Checkbox(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                  activeColor: effectiveActiveColor,
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: const BorderSide(color: AppColors.borderHighlight, width: 1.2),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled ? AppColors.textMain : AppColors.textDisabled,
                      fontSize: isCompact ? 12.0 : 13.0,
                      fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: isCompact ? 10.0 : 11.0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact Radio Button with clickable row
class DqmsRadio<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String label;
  final String? subtitle;
  final Color? activeColor;
  final bool enabled;
  final bool isCompact;

  const DqmsRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.subtitle,
    this.activeColor,
    this.enabled = true,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final effectiveActiveColor = activeColor ?? AppColors.brandPrimary;

    return InkWell(
      onTap: enabled && onChanged != null ? () => onChanged!(value) : null,
      borderRadius: AppRadius.borderSm,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 3.0 : 6.0,
          horizontal: isCompact ? 4.0 : 8.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: isCompact ? 20 : 24,
              height: isCompact ? 20 : 24,
              child: Transform.scale(
                scale: isCompact ? 0.85 : 1.0,
                child: Radio<T>(
                  value: value,
                  // ignore: deprecated_member_use
                  groupValue: groupValue,
                  // ignore: deprecated_member_use
                  onChanged: enabled ? onChanged : null,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return effectiveActiveColor;
                    }
                    return AppColors.borderHighlight;
                  }),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled ? AppColors.textMain : AppColors.textDisabled,
                      fontSize: isCompact ? 12.0 : 13.0,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: isCompact ? 10.0 : 11.0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact Toggle Switch with inline status badge and optional label
class DqmsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String activeText;
  final String inactiveText;
  final bool showStatusText;
  final bool enabled;
  final bool isCompact;

  const DqmsSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.activeText = 'Active',
    this.inactiveText = 'Inactive',
    this.showStatusText = true,
    this.enabled = true,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            style: AppTypography.kpiLabel.copyWith(
              color: AppColors.textMuted,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: isCompact ? 3.5 : AppSpacing.xs),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: isCompact ? 28 : 34,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Switch(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                  activeThumbColor: AppColors.statusActive,
                  activeTrackColor: AppColors.statusActive.withValues(alpha: 0.4),
                  inactiveThumbColor: AppColors.textMuted,
                  inactiveTrackColor: AppColors.bgCanvas,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            if (showStatusText) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: value
                      ? AppColors.statusActive.withValues(alpha: 0.15)
                      : AppColors.textMuted.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  value ? activeText : inactiveText,
                  style: TextStyle(
                    color: value ? AppColors.statusActive : AppColors.textMuted,
                    fontSize: isCompact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Segmented Option Item Model
class DqmsOptionItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const DqmsOptionItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Compact Segmented Option Buttons (pill option group)
class DqmsSegmentedOptions<T> extends StatelessWidget {
  final List<DqmsOptionItem<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final String? label;
  final bool isCompact;

  const DqmsSegmentedOptions({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.label,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = isCompact ? 28.0 : 34.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            style: AppTypography.kpiLabel.copyWith(
              color: AppColors.textMuted,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: isCompact ? 3.5 : AppSpacing.xs),
        ],
        Container(
          height: buttonHeight,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.bgCanvas,
            borderRadius: AppRadius.borderSm,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isSelected = opt.value == selectedValue;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: InkWell(
                  onTap: () => onSelected(opt.value),
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 10 : 14,
                      vertical: isCompact ? 3 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.brandPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.brandPrimary.withValues(alpha: 0.35),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (opt.icon != null) ...[
                          Icon(
                            opt.icon,
                            size: isCompact ? 13 : 15,
                            color: isSelected ? Colors.white : AppColors.textSubtle,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          opt.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textMuted,
                            fontSize: isCompact ? 11.5 : 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
