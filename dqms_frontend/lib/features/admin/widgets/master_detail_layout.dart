import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_breakpoints.dart';
import 'package:dqms_frontend/core/widgets/dqms_drawer.dart';

/// ============================================================================
/// RESPONSIVE MASTER-DETAIL LAYOUT CONTAINER
/// Enforces side-by-side split on Desktop, slide-over Drawer on Tablet,
/// and full-screen modal push on Mobile.
/// ============================================================================
class MasterDetailLayout extends StatelessWidget {
  final Widget masterWidget;
  final Widget? detailWidget;
  final String detailTitle;
  final VoidCallback? onCloseDetail;

  const MasterDetailLayout({
    super.key,
    required this.masterWidget,
    this.detailWidget,
    this.detailTitle = 'Item Inspector',
    this.onCloseDetail,
  });

  @override
  Widget build(BuildContext context) {
    return DqmsResponsiveLayout(
      desktop: _buildDesktopSplit(context),
      tablet: _buildTabletAdaptive(context),
      mobile: _buildMobileStack(context),
    );
  }

  /// Desktop Layout: Side-by-side Split View
  Widget _buildDesktopSplit(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Master Table / List View
        Expanded(
          flex: detailWidget != null ? 7 : 12,
          child: masterWidget,
        ),

        // Detail Inspector Panel
        if (detailWidget != null) ...[
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detail Panel Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.bgHeader,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.brandPrimary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            detailTitle,
                            style: const TextStyle(
                              color: AppColors.textMain,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                          onPressed: onCloseDetail,
                          tooltip: 'Close Inspector',
                        ),
                      ],
                    ),
                  ),

                  // Detail Body Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(child: detailWidget!),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Tablet Layout: Master View + Slide-Over Drawer
  Widget _buildTabletAdaptive(BuildContext context) {
    return Stack(
      children: [
        masterWidget,
        if (detailWidget != null)
          DqmsDrawer(
            title: detailTitle,
            child: SingleChildScrollView(child: detailWidget!),
          ),
      ],
    );
  }

  /// Mobile Layout: Stack with Full-Screen Modal overlay when selected
  Widget _buildMobileStack(BuildContext context) {
    if (detailWidget != null) {
      return Scaffold(
        backgroundColor: AppColors.bgCanvas,
        appBar: AppBar(
          backgroundColor: AppColors.bgHeader,
          title: Text(detailTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onCloseDetail,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(child: detailWidget!),
        ),
      );
    }
    return masterWidget;
  }
}
