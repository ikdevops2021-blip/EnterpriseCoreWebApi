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
/// DQMS ENTERPRISE DATA TABLE COMPONENT
/// Standardized table wrapper with header, row separation, & hover states
/// ============================================================================
class DqmsDataTable<T> extends StatelessWidget {
  final List<DqmsTableColumn> columns;
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) rowBuilder;
  final Widget? emptyStateWidget;
  final bool isLoading;

  const DqmsDataTable({
    super.key,
    required this.columns,
    required this.items,
    required this.rowBuilder,
    this.emptyStateWidget,
    this.isLoading = false,
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
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          // Table Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.bgHeader,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
              ),
              border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: columns.map((col) {
                return Expanded(
                  child: Align(
                    alignment: col.alignment,
                    child: Text(
                      col.title.toUpperCase(),
                      style: AppTypography.tableHeader,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Table Rows List
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(
                color: AppColors.borderSubtle,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  hoverColor: AppColors.bgSurfaceHover,
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: rowBuilder(context, item, index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
