import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

/// ============================================================================
/// DQMS ENTERPRISE INPUT FIELD COMPONENT
/// Standardized text field with focus state, label, hint, and error states
/// ============================================================================
class DqmsTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? hintText;
  final String? initialValue;
  final String? errorText;
  final bool obscureText;
  final int maxLines;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const DqmsTextField({
    super.key,
    this.controller,
    this.label = '',
    this.hint,
    this.hintText,
    this.initialValue,
    this.errorText,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<DqmsTextField> createState() => _DqmsTextFieldState();
}

class _DqmsTextFieldState extends State<DqmsTextField> {
  late TextEditingController _effectiveController;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(DqmsTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller && widget.controller != null) {
      _effectiveController = widget.controller!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHint = widget.hint ?? widget.hintText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: AppTypography.kpiLabel.copyWith(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Semantics(
          label: widget.label.isNotEmpty ? widget.label : effectiveHint,
          hint: effectiveHint,
          textField: true,
          child: TextField(
            controller: _effectiveController,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textMain),
            decoration: InputDecoration(
              hintText: effectiveHint,
              errorText: widget.errorText,
              hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSubtle),
              filled: true,
              fillColor: AppColors.bgCanvas,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderSm,
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderSm,
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderSm,
                borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderSm,
                borderSide: const BorderSide(color: AppColors.statusDeactive),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
