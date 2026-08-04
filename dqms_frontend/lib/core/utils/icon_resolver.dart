import 'package:flutter/material.dart';

/// ============================================================================
/// IconResolver: Maps stored icon name strings (from DB) to Flutter IconData.
/// This enables the "plug-and-play" approach — icons are stored as strings
/// and resolved at runtime, so any new icon can be added via the admin UI.
/// ============================================================================
class IconResolver {
  IconResolver._();

  /// Returns an IconData for the given string icon name.
  /// Falls back to [Icons.widgets_rounded] if the name is unknown.
  static IconData resolve(String? iconName) {
    return _iconMap[iconName ?? ''] ?? Icons.widgets_rounded;
  }

  static const Map<String, IconData> _iconMap = {
    // Navigation & UI
    'menu_rounded':                    Icons.menu_rounded,
    'widgets_rounded':                 Icons.widgets_rounded,
    'home_rounded':                    Icons.home_rounded,
    'dashboard_rounded':               Icons.dashboard_rounded,
    'explore_rounded':                 Icons.explore_rounded,
    'layers_rounded':                  Icons.layers_rounded,
    'pages_rounded':                   Icons.pages_rounded,
    'view_module_rounded':             Icons.view_module_rounded,
    'grid_view_rounded':               Icons.grid_view_rounded,

    // Queue & Operations
    'account_tree_rounded':            Icons.account_tree_rounded,
    'desk_rounded':                    Icons.desk_rounded,
    'tv_rounded':                      Icons.tv_rounded,
    'queue_rounded':                   Icons.queue_rounded,
    'timer_rounded':                   Icons.timer_rounded,
    'schedule_rounded':                Icons.schedule_rounded,
    'pending_actions_rounded':         Icons.pending_actions_rounded,

    // People & Auth
    'badge_rounded':                   Icons.badge_rounded,
    'person_search_rounded':           Icons.person_search_rounded,
    'people_rounded':                  Icons.people_rounded,
    'person_rounded':                  Icons.person_rounded,
    'admin_panel_settings_rounded':    Icons.admin_panel_settings_rounded,
    'manage_accounts_rounded':         Icons.manage_accounts_rounded,
    'groups_rounded':                  Icons.groups_rounded,
    'supervisor_account_rounded':      Icons.supervisor_account_rounded,

    // Organization
    'business_rounded':                Icons.business_rounded,
    'corporate_fare_rounded':          Icons.corporate_fare_rounded,
    'location_on_rounded':             Icons.location_on_rounded,
    'apartment_rounded':               Icons.apartment_rounded,

    // Config & System
    'category_rounded':                Icons.category_rounded,
    'settings_suggest_rounded':        Icons.settings_suggest_rounded,
    'settings_rounded':                Icons.settings_rounded,
    'tune_rounded':                    Icons.tune_rounded,
    'build_rounded':                   Icons.build_rounded,
    'extension_rounded':               Icons.extension_rounded,

    // Notifications & Communications
    'notifications_active_rounded':    Icons.notifications_active_rounded,
    'mark_email_read_rounded':         Icons.mark_email_read_rounded,
    'sms_rounded':                     Icons.sms_rounded,
    'mail_rounded':                    Icons.mail_rounded,
    'campaign_rounded':                Icons.campaign_rounded,
    'chat_bubble_rounded':             Icons.chat_bubble_rounded,

    // Analytics & Reports
    'analytics_rounded':               Icons.analytics_rounded,
    'bar_chart_rounded':               Icons.bar_chart_rounded,
    'show_chart_rounded':              Icons.show_chart_rounded,
    'pie_chart_rounded':               Icons.pie_chart_rounded,
    'trending_up_rounded':             Icons.trending_up_rounded,
    'assessment_rounded':              Icons.assessment_rounded,

    // Logs & Debug
    'terminal_rounded':                Icons.terminal_rounded,
    'history_rounded':                 Icons.history_rounded,
    'receipt_long_rounded':            Icons.receipt_long_rounded,
    'bug_report_rounded':              Icons.bug_report_rounded,

    // Finance & Commerce
    'payments_rounded':                Icons.payments_rounded,
    'receipt_rounded':                 Icons.receipt_rounded,
    'shopping_cart_rounded':           Icons.shopping_cart_rounded,
    'monetization_on_rounded':         Icons.monetization_on_rounded,
    'account_balance_rounded':         Icons.account_balance_rounded,
    'credit_card_rounded':             Icons.credit_card_rounded,

    // Misc
    'star_rounded':                    Icons.star_rounded,
    'info_rounded':                    Icons.info_rounded,
    'help_rounded':                    Icons.help_rounded,
    'security_rounded':                Icons.security_rounded,
    'cloud_rounded':                   Icons.cloud_rounded,
    'storage_rounded':                 Icons.storage_rounded,
    'integration_instructions_rounded': Icons.integration_instructions_rounded,
  };

  /// Returns all available icon entries for the picker UI.
  static List<MapEntry<String, IconData>> get allEntries =>
      _iconMap.entries.toList();
}
