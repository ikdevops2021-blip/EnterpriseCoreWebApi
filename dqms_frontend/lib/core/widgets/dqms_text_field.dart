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
  final bool enabled;
  final bool isCompact;
  final double? height;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;

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
    this.enabled = true,
    this.isCompact = true,
    this.height,
    this.contentPadding,
    this.style,
  });

  @override
  State<DqmsTextField> createState() => _DqmsTextFieldState();
}

class _DqmsTextFieldState extends State<DqmsTextField> {
  late TextEditingController _effectiveController;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DqmsTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (widget.controller != null) {
        _effectiveController = widget.controller!;
      } else {
        _effectiveController = TextEditingController(text: widget.initialValue);
      }
    } else if (widget.controller == null && 
               widget.initialValue != oldWidget.initialValue && 
               widget.initialValue != _effectiveController.text) {
      _effectiveController.text = widget.initialValue ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHint = widget.hint ?? widget.hintText;
    final isSingleLine = widget.maxLines == 1;
    final double fieldHeight = widget.isCompact
        ? (widget.height ?? AppSpacing.formFieldHeight)
        : (widget.height ?? 40.0);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    Widget inputContainer = Container(
      height: isSingleLine ? fieldHeight : null,
      constraints: !isSingleLine ? BoxConstraints(minHeight: fieldHeight) : null,
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: isSingleLine ? 0 : 8,
      ),
      decoration: BoxDecoration(
        color: widget.enabled ? AppColors.bgCanvas : AppColors.bgCanvas.withValues(alpha: 0.5),
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: hasError
              ? AppColors.statusDeactive
              : (_isFocused ? AppColors.borderFocus : AppColors.borderSubtle),
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.2),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: isSingleLine ? 3.5 : 0.0,
          ),
          child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              widget.prefixIcon!,
              const SizedBox(width: 6),
            ],
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: _effectiveController,
                obscureText: widget.obscureText,
                maxLines: widget.maxLines,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                enabled: widget.enabled,
                textAlignVertical: TextAlignVertical.center,
                style: (widget.style ?? AppTypography.bodyMedium).copyWith(
                  color: widget.enabled ? AppColors.textMain : AppColors.textDisabled,
                  fontSize: widget.isCompact ? 12.0 : 13.5,
                ),
                decoration: InputDecoration(
                  isCollapsed: isSingleLine,
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: effectiveHint,
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSubtle,
                    fontSize: widget.isCompact ? 12.0 : 13.5,
                  ),
                ),
              ),
            ),
            if (widget.suffixIcon != null) ...[
              const SizedBox(width: 6),
              widget.suffixIcon!,
            ],
          ],
        ),
      ),
    ),
  );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: AppTypography.kpiLabel.copyWith(
              color: AppColors.textMuted,
              fontSize: widget.isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: widget.isCompact ? 3.0 : AppSpacing.xs),
        ],
        Semantics(
          label: widget.label.isNotEmpty ? widget.label : effectiveHint,
          hint: effectiveHint,
          textField: true,
          child: inputContainer,
        ),
        if (hasError) ...[
          const SizedBox(height: 2),
          Text(
            widget.errorText!,
            style: const TextStyle(
              color: AppColors.statusDeactive,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
