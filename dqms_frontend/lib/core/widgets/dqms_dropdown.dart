import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

/// ============================================================================
/// DQMS ENTERPRISE COMPACT DROPDOWN CONTROLS
/// Highly dense, space-efficient, pixel-aligned dropdown controls.
/// Guaranteed to match DqmsTextField in height, borders, and baseline typography.
/// ============================================================================

class DqmsDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final Widget? prefixIcon;
  final bool enabled;
  final bool isCompact;
  final double? height;
  final double? width;

  const DqmsDropdown({
    super.key,
    this.label = '',
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.prefixIcon,
    this.enabled = true,
    this.isCompact = true,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final double fieldHeight = isCompact
        ? (height ?? AppSpacing.formFieldHeight)
        : (height ?? 40.0);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: AppTypography.kpiLabel.copyWith(
                color: AppColors.textMuted,
                fontSize: isCompact ? 11 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: isCompact ? 3.0 : AppSpacing.xs),
          ],
          Container(
            height: fieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: enabled ? AppColors.bgCanvas : AppColors.bgCanvas.withValues(alpha: 0.5),
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: value,
                      isDense: true,
                      isExpanded: true,
                      dropdownColor: AppColors.bgSurface,
                      borderRadius: AppRadius.borderSm,
                      hint: hint != null
                          ? Text(
                              hint!,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSubtle,
                                fontSize: isCompact ? 12.0 : 13.0,
                              ),
                            )
                          : null,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.textSubtle,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: enabled ? AppColors.textMain : AppColors.textDisabled,
                        fontSize: isCompact ? 12.0 : 13.5,
                      ),
                      items: items,
                      onChanged: enabled ? onChanged : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// DQMS COMPACT SEARCHABLE DROPDOWN
/// Integrates dropdown_search with clean external labels and dark obsidian styling
/// ============================================================================
class DqmsSearchableDropdown<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemAsString;
  final bool Function(T, String)? filterFn;
  final bool Function(T, T)? compareFn;
  final Widget Function(BuildContext, T?)? dropdownBuilder;
  final Widget Function(BuildContext, T, bool)? itemBuilder;
  final Widget? Function(T)? leadingBuilder;
  final String? hint;
  final bool enabled;
  final bool isCompact;
  final double? height;
  final bool? showSearchBox;
  final String searchHint;
  final double? width;

  const DqmsSearchableDropdown({
    super.key,
    this.label = '',
    required this.items,
    this.selectedItem,
    this.onChanged,
    this.itemAsString,
    this.filterFn,
    this.compareFn,
    this.dropdownBuilder,
    this.itemBuilder,
    this.leadingBuilder,
    this.hint,
    this.enabled = true,
    this.isCompact = true,
    this.height,
    this.showSearchBox,
    this.searchHint = 'Search...',
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bool enableSearch = showSearchBox ?? (items.length > 5);
    final double fieldHeight = isCompact
        ? (height ?? AppSpacing.formFieldHeight)
        : (height ?? 40.0);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: AppTypography.kpiLabel.copyWith(
                color: AppColors.textMuted,
                fontSize: isCompact ? 11 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: isCompact ? 3.0 : AppSpacing.xs),
          ],
          Container(
            height: fieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: enabled ? AppColors.bgCanvas : AppColors.bgCanvas.withValues(alpha: 0.5),
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Center(
              child: DropdownSearch<T>(
                items: items,
                selectedItem: selectedItem,
                enabled: enabled,
                itemAsString: itemAsString,
                filterFn: filterFn,
                compareFn: compareFn,
                onChanged: onChanged,
                dropdownButtonProps: DropdownButtonProps(
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.textSubtle,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  splashRadius: 12,
                ),
                dropdownBuilder: dropdownBuilder ??
                    (ctx, item) {
                      if (item == null) {
                        return Text(
                          hint ?? '— Select —',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: isCompact ? 12.0 : 13.0,
                          ),
                        );
                      }
                      final leading = leadingBuilder?.call(item);
                      final text = itemAsString != null ? itemAsString!(item) : item.toString();
                      return Row(
                        children: [
                          if (leading != null && leading is! SizedBox) ...[leading, const SizedBox(width: 6)],
                          Expanded(
                            child: Text(
                              text,
                              style: TextStyle(
                                color: AppColors.textMain,
                                fontSize: isCompact ? 12.0 : 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  textAlignVertical: TextAlignVertical.center,
                  dropdownSearchDecoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: enableSearch,
                  searchFieldProps: TextFieldProps(
                    style: TextStyle(color: AppColors.textMain, fontSize: isCompact ? 12.0 : 13.0),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: searchHint,
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      filled: true,
                      fillColor: AppColors.bgCanvas,
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSubtle, size: 16),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                    ),
                  ),
                  containerBuilder: (ctx, child) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: AppRadius.borderSm,
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: child,
                  ),
                  itemBuilder: itemBuilder ??
                      (ctx, item, isSelected) {
                        final leading = leadingBuilder?.call(item);
                        final text = itemAsString != null ? itemAsString!(item) : item.toString();
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 10 : 12,
                            vertical: isCompact ? 6.5 : 9,
                          ),
                          color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.15) : null,
                          child: Row(
                            children: [
                              if (leading != null && leading is! SizedBox) ...[leading, const SizedBox(width: 8)],
                              Expanded(
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.brandPrimary : AppColors.textMain,
                                    fontSize: isCompact ? 12.0 : 13.0,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_rounded, size: 14, color: AppColors.brandPrimary),
                            ],
                          ),
                        );
                      },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
