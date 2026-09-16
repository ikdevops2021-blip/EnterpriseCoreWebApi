import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

class DqmsTableColumn {
  final String title;
  final FlexColumnWidth flex;
  final Alignment alignment;

  const DqmsTableColumn({
    required this.title,
    this.flex = const FlexColumnWidth(1),
    this.alignment = Alignment.centerLeft,
  });
}

/// ============================================================================
/// DQMS ENTERPRISE 3D COMPACT DATA TABLE COMPONENT
/// High-density data grid featuring 3D frosted glass header, specular top highlight,
/// smooth animated row hover lift, and left neon indicator bar.
/// ============================================================================
class DqmsDataTable<T> extends StatelessWidget {
  final List<DqmsTableColumn> columns;
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) rowBuilder;
  final Widget? emptyStateWidget;
  final bool isLoading;
  final bool isCompact;
  final void Function(T item, int index)? onRowTap;

  const DqmsDataTable({
    super.key,
    required this.columns,
    required this.items,
    required this.rowBuilder,
    this.emptyStateWidget,
    this.isLoading = false,
    this.isCompact = true,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandPrimary),
      );
    }

    if (items.isEmpty) {
      return emptyStateWidget ?? const SizedBox.shrink();
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.depth3dRaised,
      ),
      child: Column(
        children: [
          // 3D Frosted Header Bar
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? AppSpacing.md : AppSpacing.lg,
              vertical: isCompact ? 8.0 : AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgHeader,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
              ),
              border: const Border(
                top: BorderSide(color: Color(0x1AFFFFFF), width: 1),
                bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: columns.map((col) {
                return Expanded(
                  child: Align(
                    alignment: col.alignment,
                    child: Text(
                      col.title.toUpperCase(),
                      style: AppTypography.tableHeader.copyWith(
                        fontSize: isCompact ? 10.5 : 11.5,
                        letterSpacing: 0.9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Animated Table Rows List
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(
                color: AppColors.borderSubtle,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _DqmsDataTableRow(
                  isCompact: isCompact,
                  isZebra: index.isOdd,
                  onTap: onRowTap != null ? () => onRowTap!(item, index) : null,
                  child: rowBuilder(context, item, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive Row with 3D Hover Depth & Left Accent Bar
class _DqmsDataTableRow extends StatefulWidget {
  final Widget child;
  final bool isCompact;
  final bool isZebra;
  final VoidCallback? onTap;

  const _DqmsDataTableRow({
    required this.child,
    required this.isCompact,
    required this.isZebra,
    this.onTap,
  });

  @override
  State<_DqmsDataTableRow> createState() => _DqmsDataTableRowState();
}

class _DqmsDataTableRowState extends State<_DqmsDataTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = _isHovered
        ? AppColors.bgSurfaceHover
        : (widget.isZebra
            ? AppColors.bgSurface.withValues(alpha: 0.5)
            : AppColors.bgSurface);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              left: BorderSide(
                color: _isHovered ? AppColors.brandPrimary : Colors.transparent,
                width: 3.0,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? AppSpacing.md : AppSpacing.lg,
            vertical: widget.isCompact ? 7.0 : AppSpacing.md,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
