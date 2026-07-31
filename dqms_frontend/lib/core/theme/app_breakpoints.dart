import 'package:flutter/material.dart';

/// ============================================================================
/// DQMS RESPONSIVE BREAKPOINT UTILITIES
/// Media queries and layout breakpoint builders for Desktop, Tablet, & Mobile
/// ============================================================================
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobileMax = 599.0;
  static const double tabletMin = 600.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletMin;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletMin && width <= tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopMin;
}

/// Helper Responsive Layout Widget
class DqmsResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const DqmsResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.desktopMin) {
          return desktop;
        } else if (constraints.maxWidth >= AppBreakpoints.tabletMin) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
