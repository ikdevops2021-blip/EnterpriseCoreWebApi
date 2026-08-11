import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// ============================================================================
/// IconResolver
/// Maps stored icon-name strings (from DB / JSON) to Flutter icon widgets.
///
/// Convention:
///   - Plain name   (e.g. "dashboard_rounded")   -> Material Icons
///   - "fa:" prefix (e.g. "fa:hospital")          -> Font Awesome Icons
///
/// Use [resolve] to get a [ResolvedIcon], then call [ResolvedIcon.build] to
/// create the widget. This avoids FaIconData/IconData type mismatches.
/// ============================================================================
enum IconType { material, fontAwesome }

/// Wrapper that encapsulates a resolved icon regardless of its source library.
/// Call [build] to get a properly-typed [Widget] (Icon or FaIcon).
class ResolvedIcon {
  final IconType type;
  final IconData? _materialData;
  final FaIconData? _faData;

  const ResolvedIcon._material(IconData data)
      : type = IconType.material, _materialData = data, _faData = null;
  const ResolvedIcon._fa(FaIconData data)
      : type = IconType.fontAwesome, _materialData = null, _faData = data;

  /// Builds the correct widget (Icon or FaIcon) for this resolved icon.
  Widget build({double size = 16, Color? color}) {
    if (type == IconType.fontAwesome && _faData != null) {
      return FaIcon(_faData, size: size * 0.85, color: color);
    }
    return Icon(_materialData, size: size, color: color);
  }

  /// Get raw IconData (material only — returns null for FA).
  IconData? get materialData => _materialData;

  /// Get raw FaIconData (FA only — returns null for material).
  FaIconData? get faData => _faData;

  bool get isFontAwesome => type == IconType.fontAwesome;
  bool get isMaterial => type == IconType.material;
}

class IconResolver {
  IconResolver._();

  // --------------------------------------------------------------------------
  // Public API
  // --------------------------------------------------------------------------

  /// Resolve any stored key to a [ResolvedIcon].
  static ResolvedIcon resolve(String? iconName) {
    final key = iconName ?? '';
    if (key.startsWith('fa:')) {
      final faKey = key.substring(3);
      final data = _faMap[faKey];
      return ResolvedIcon._fa(data ?? FontAwesomeIcons.icons);
    }
    final data = _materialMap[key];
    return ResolvedIcon._material(data ?? Icons.widgets_rounded);
  }

  /// Returns all Material icon key-names.
  static List<String> get materialKeys => _materialMap.keys.toList();

  /// Returns all FA icon key-names (without "fa:" prefix).
  static List<String> get fontAwesomeKeys => _faMap.keys.toList();

  /// Material entry count.
  static int get materialCount => _materialMap.length;

  /// FA entry count.
  static int get fontAwesomeCount => _faMap.length;

  /// Returns all Material entries for backward-compat pickers.
  static List<MapEntry<String, IconData>> get allEntries =>
      _materialMap.entries.toList();

  // --------------------------------------------------------------------------
  // Material Icons Catalog
  // --------------------------------------------------------------------------
  static const Map<String, IconData> _materialMap = {
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
    'view_list_rounded':               Icons.view_list_rounded,
    'apps_rounded':                    Icons.apps_rounded,
    'more_horiz_rounded':              Icons.more_horiz_rounded,
    'view_stream_rounded':             Icons.view_stream_rounded,
    'table_chart_rounded':             Icons.table_chart_rounded,
    'table_rows_rounded':              Icons.table_rows_rounded,
    'view_compact_rounded':            Icons.view_compact_rounded,
    'view_quilt_rounded':              Icons.view_quilt_rounded,
    'window_rounded':                  Icons.window_rounded,
    'space_dashboard_rounded':         Icons.space_dashboard_rounded,
    'dashboard_customize_rounded':     Icons.dashboard_customize_rounded,
    // Queue & Operations
    'account_tree_rounded':            Icons.account_tree_rounded,
    'desk_rounded':                    Icons.desk_rounded,
    'tv_rounded':                      Icons.tv_rounded,
    'queue_rounded':                   Icons.queue_rounded,
    'timer_rounded':                   Icons.timer_rounded,
    'schedule_rounded':                Icons.schedule_rounded,
    'pending_actions_rounded':         Icons.pending_actions_rounded,
    'countertops_rounded':             Icons.countertops_rounded,
    'confirmation_number_rounded':     Icons.confirmation_number_rounded,
    'event_seat_rounded':              Icons.event_seat_rounded,
    'meeting_room_rounded':            Icons.meeting_room_rounded,
    'door_sliding_rounded':            Icons.door_sliding_rounded,
    'monitor_rounded':                 Icons.monitor_rounded,
    'display_settings_rounded':        Icons.display_settings_rounded,
    'connected_tv_rounded':            Icons.connected_tv_rounded,
    'hourglass_top_rounded':           Icons.hourglass_top_rounded,
    'hourglass_bottom_rounded':        Icons.hourglass_bottom_rounded,
    'update_rounded':                  Icons.update_rounded,
    'alarm_rounded':                   Icons.alarm_rounded,
    'punch_clock_rounded':             Icons.punch_clock_rounded,
    // People & Auth
    'badge_rounded':                   Icons.badge_rounded,
    'person_search_rounded':           Icons.person_search_rounded,
    'people_rounded':                  Icons.people_rounded,
    'person_rounded':                  Icons.person_rounded,
    'admin_panel_settings_rounded':    Icons.admin_panel_settings_rounded,
    'manage_accounts_rounded':         Icons.manage_accounts_rounded,
    'groups_rounded':                  Icons.groups_rounded,
    'supervisor_account_rounded':      Icons.supervisor_account_rounded,
    'person_add_rounded':              Icons.person_add_rounded,
    'person_remove_rounded':           Icons.person_remove_rounded,
    'face_rounded':                    Icons.face_rounded,
    'fingerprint_rounded':             Icons.fingerprint_rounded,
    'lock_rounded':                    Icons.lock_rounded,
    'lock_open_rounded':               Icons.lock_open_rounded,
    'key_rounded':                     Icons.key_rounded,
    'shield_rounded':                  Icons.shield_rounded,
    'verified_user_rounded':           Icons.verified_user_rounded,
    'remember_me_rounded':             Icons.remember_me_rounded,
    'account_circle_rounded':          Icons.account_circle_rounded,
    'portrait_rounded':                Icons.portrait_rounded,
    // Organization
    'business_rounded':                Icons.business_rounded,
    'corporate_fare_rounded':          Icons.corporate_fare_rounded,
    'location_on_rounded':             Icons.location_on_rounded,
    'apartment_rounded':               Icons.apartment_rounded,
    'store_rounded':                   Icons.store_rounded,
    'domain_rounded':                  Icons.domain_rounded,
    'map_rounded':                     Icons.map_rounded,
    'place_rounded':                   Icons.place_rounded,
    'navigation_rounded':              Icons.navigation_rounded,
    'pin_drop_rounded':                Icons.pin_drop_rounded,
    'my_location_rounded':             Icons.my_location_rounded,
    'center_focus_strong_rounded':     Icons.center_focus_strong_rounded,
    'flag_rounded':                    Icons.flag_rounded,
    // Config & System
    'category_rounded':                Icons.category_rounded,
    'settings_suggest_rounded':        Icons.settings_suggest_rounded,
    'settings_rounded':                Icons.settings_rounded,
    'tune_rounded':                    Icons.tune_rounded,
    'build_rounded':                   Icons.build_rounded,
    'extension_rounded':               Icons.extension_rounded,
    'toggle_on_rounded':               Icons.toggle_on_rounded,
    'toggle_off_rounded':              Icons.toggle_off_rounded,
    'sliders_rounded':                 Icons.tune_rounded,
    'construction_rounded':            Icons.construction_rounded,
    'handyman_rounded':                Icons.handyman_rounded,
    'psychology_rounded':              Icons.psychology_rounded,
    'memory_rounded':                  Icons.memory_rounded,
    'cpu_rounded':                     Icons.developer_board_rounded,
    'power_rounded':                   Icons.power_rounded,
    'dns_rounded':                     Icons.dns_rounded,
    'code_rounded':                    Icons.code_rounded,
    // Notifications & Comms
    'notifications_active_rounded':    Icons.notifications_active_rounded,
    'mark_email_read_rounded':         Icons.mark_email_read_rounded,
    'sms_rounded':                     Icons.sms_rounded,
    'mail_rounded':                    Icons.mail_rounded,
    'campaign_rounded':                Icons.campaign_rounded,
    'chat_bubble_rounded':             Icons.chat_bubble_rounded,
    'notifications_rounded':           Icons.notifications_rounded,
    'notifications_off_rounded':       Icons.notifications_off_rounded,
    'email_rounded':                   Icons.email_rounded,
    'contact_mail_rounded':            Icons.contact_mail_rounded,
    'contact_phone_rounded':           Icons.contact_phone_rounded,
    'phone_rounded':                   Icons.phone_rounded,
    'phone_in_talk_rounded':           Icons.phone_in_talk_rounded,
    'forum_rounded':                   Icons.forum_rounded,
    'message_rounded':                 Icons.message_rounded,
    'feedback_rounded':                Icons.feedback_rounded,
    'announcement_rounded':            Icons.announcement_rounded,
    // Analytics & Reports
    'analytics_rounded':               Icons.analytics_rounded,
    'bar_chart_rounded':               Icons.bar_chart_rounded,
    'show_chart_rounded':              Icons.show_chart_rounded,
    'pie_chart_rounded':               Icons.pie_chart_rounded,
    'trending_up_rounded':             Icons.trending_up_rounded,
    'assessment_rounded':              Icons.assessment_rounded,
    'insights_rounded':                Icons.insights_rounded,
    'stacked_bar_chart_rounded':       Icons.stacked_bar_chart_rounded,
    'donut_small_rounded':             Icons.donut_small_rounded,
    'multiline_chart_rounded':         Icons.multiline_chart_rounded,
    'query_stats_rounded':             Icons.query_stats_rounded,
    'timeline_rounded':                Icons.timeline_rounded,
    'ssid_chart_rounded':              Icons.ssid_chart_rounded,
    'leaderboard_rounded':             Icons.leaderboard_rounded,
    // Logs & Debug
    'terminal_rounded':                Icons.terminal_rounded,
    'history_rounded':                 Icons.history_rounded,
    'receipt_long_rounded':            Icons.receipt_long_rounded,
    'bug_report_rounded':              Icons.bug_report_rounded,
    'code_off_rounded':                Icons.code_off_rounded,
    'description_rounded':             Icons.description_rounded,
    'article_rounded':                 Icons.article_rounded,
    'summarize_rounded':               Icons.summarize_rounded,
    'find_in_page_rounded':            Icons.find_in_page_rounded,
    'integration_instructions_rounded': Icons.integration_instructions_rounded,
    // Finance & Commerce
    'payments_rounded':                Icons.payments_rounded,
    'receipt_rounded':                 Icons.receipt_rounded,
    'shopping_cart_rounded':           Icons.shopping_cart_rounded,
    'monetization_on_rounded':         Icons.monetization_on_rounded,
    'account_balance_rounded':         Icons.account_balance_rounded,
    'credit_card_rounded':             Icons.credit_card_rounded,
    'account_balance_wallet_rounded':  Icons.account_balance_wallet_rounded,
    'attach_money_rounded':            Icons.attach_money_rounded,
    'price_change_rounded':            Icons.price_change_rounded,
    'savings_rounded':                 Icons.savings_rounded,
    'point_of_sale_rounded':           Icons.point_of_sale_rounded,
    'currency_exchange_rounded':       Icons.currency_exchange_rounded,
    // Healthcare & Medical (Material)
    'local_hospital_rounded':          Icons.local_hospital_rounded,
    'medical_services_rounded':        Icons.medical_services_rounded,
    'health_and_safety_rounded':       Icons.health_and_safety_rounded,
    'medication_rounded':              Icons.medication_rounded,
    'vaccines_rounded':                Icons.vaccines_rounded,
    'bloodtype_rounded':               Icons.bloodtype_rounded,
    'personal_injury_rounded':         Icons.personal_injury_rounded,
    'healing_rounded':                 Icons.healing_rounded,
    'biotech_rounded':                 Icons.biotech_rounded,
    // Misc
    'star_rounded':                    Icons.star_rounded,
    'info_rounded':                    Icons.info_rounded,
    'help_rounded':                    Icons.help_rounded,
    'security_rounded':                Icons.security_rounded,
    'cloud_rounded':                   Icons.cloud_rounded,
    'storage_rounded':                 Icons.storage_rounded,
    'check_circle_rounded':            Icons.check_circle_rounded,
    'cancel_rounded':                  Icons.cancel_rounded,
    'error_rounded':                   Icons.error_rounded,
    'warning_rounded':                 Icons.warning_rounded,
    'lightbulb_rounded':               Icons.lightbulb_rounded,
    'launch_rounded':                  Icons.launch_rounded,
    'open_in_new_rounded':             Icons.open_in_new_rounded,
    // Gender & Identity
    'male_rounded':                    Icons.male_rounded,
    'female_rounded':                  Icons.female_rounded,
    'transgender_rounded':             Icons.transgender_rounded,
    'wc_rounded':                      Icons.wc_rounded,
  };

  // --------------------------------------------------------------------------
  // FontAwesome Icons Catalog (FaIconData — separate type from IconData)
  // --------------------------------------------------------------------------
  static final Map<String, FaIconData> _faMap = {
    // Healthcare & Medical
    'hospital':               FontAwesomeIcons.hospital,
    'hospitalUser':           FontAwesomeIcons.hospitalUser,
    'userDoctor':             FontAwesomeIcons.userDoctor,
    'stethoscope':            FontAwesomeIcons.stethoscope,
    'pills':                  FontAwesomeIcons.pills,
    'syringe':                FontAwesomeIcons.syringe,
    'heartPulse':             FontAwesomeIcons.heartPulse,
    'bedPulse':               FontAwesomeIcons.bedPulse,
    'ambulance':              FontAwesomeIcons.truckMedical,
    'microscope':             FontAwesomeIcons.microscope,
    'dna':                    FontAwesomeIcons.dna,
    'tooth':                  FontAwesomeIcons.tooth,
    'vial':                   FontAwesomeIcons.vial,
    'clipboardQuestion':      FontAwesomeIcons.clipboardQuestion,
    'notesMedical':           FontAwesomeIcons.notesMedical,
    'kitMedical':             FontAwesomeIcons.kitMedical,
    'weightScale':            FontAwesomeIcons.weightScale,
    'lungs':                  FontAwesomeIcons.lungs,
    'brain':                  FontAwesomeIcons.brain,
    // People & Identity
    'users':                  FontAwesomeIcons.users,
    'userTie':                FontAwesomeIcons.userTie,
    'userShield':             FontAwesomeIcons.userShield,
    'userGear':               FontAwesomeIcons.userGear,
    'usersGear':              FontAwesomeIcons.usersGear,
    'idCard':                 FontAwesomeIcons.idCard,
    'idBadge':                FontAwesomeIcons.idBadge,
    'addressBook':            FontAwesomeIcons.addressBook,
    'personChalkboard':       FontAwesomeIcons.personChalkboard,
    'child':                  FontAwesomeIcons.child,
    'userPlus':               FontAwesomeIcons.userPlus,
    'userMinus':              FontAwesomeIcons.userMinus,
    'userCheck':              FontAwesomeIcons.userCheck,
    'userXmark':              FontAwesomeIcons.userXmark,
    'userPen':                FontAwesomeIcons.userPen,
    'userLock':               FontAwesomeIcons.userLock,
    'userGraduate':           FontAwesomeIcons.userGraduate,
    'peopleGroup':            FontAwesomeIcons.peopleGroup,
    'peopleRoof':             FontAwesomeIcons.peopleRoof,
    // Communication
    'envelope':               FontAwesomeIcons.envelope,
    'envelopeOpenText':       FontAwesomeIcons.envelopeOpenText,
    'comments':               FontAwesomeIcons.comments,
    'comment':                FontAwesomeIcons.comment,
    'phone':                  FontAwesomeIcons.phone,
    'mobileScreen':           FontAwesomeIcons.mobileScreen,
    'bell':                   FontAwesomeIcons.bell,
    'bullhorn':               FontAwesomeIcons.bullhorn,
    'rss':                    FontAwesomeIcons.rss,
    'telegram':               FontAwesomeIcons.telegram,
    'whatsapp':               FontAwesomeIcons.whatsapp,
    'inbox':                  FontAwesomeIcons.inbox,
    'paperPlane':             FontAwesomeIcons.paperPlane,
    'shareNodes':             FontAwesomeIcons.shareNodes,
    'headset':                FontAwesomeIcons.headset,
    'walkieTalkie':           FontAwesomeIcons.walkieTalkie,
    'message':                FontAwesomeIcons.message,
    // Finance & Business
    'creditCard':             FontAwesomeIcons.creditCard,
    'moneyBill':              FontAwesomeIcons.moneyBill,
    'moneyBillWave':          FontAwesomeIcons.moneyBillWave,
    'fileInvoiceDollar':      FontAwesomeIcons.fileInvoiceDollar,
    'cashRegister':           FontAwesomeIcons.cashRegister,
    'handHoldingDollar':      FontAwesomeIcons.handHoldingDollar,
    'chartPie':               FontAwesomeIcons.chartPie,
    'chartLine':              FontAwesomeIcons.chartLine,
    'chartBar':               FontAwesomeIcons.chartBar,
    'chartArea':              FontAwesomeIcons.chartArea,
    'briefcase':              FontAwesomeIcons.briefcase,
    'building':               FontAwesomeIcons.building,
    'buildingColumns':        FontAwesomeIcons.buildingColumns,
    'shop':                   FontAwesomeIcons.shop,
    'shoppingCart':           FontAwesomeIcons.cartShopping,
    'coins':                  FontAwesomeIcons.coins,
    'wallet':                 FontAwesomeIcons.wallet,
    'receipt':                FontAwesomeIcons.receipt,
    'piggyBank':              FontAwesomeIcons.piggyBank,
    'scaleBalanced':          FontAwesomeIcons.scaleBalanced,
    'vault':                  FontAwesomeIcons.vault,
    'landmark':               FontAwesomeIcons.landmark,
    // Technology & System
    'server':                 FontAwesomeIcons.server,
    'database':               FontAwesomeIcons.database,
    'cloud':                  FontAwesomeIcons.cloud,
    'cloudArrowUp':           FontAwesomeIcons.cloudArrowUp,
    'code':                   FontAwesomeIcons.code,
    'laptop':                 FontAwesomeIcons.laptop,
    'desktop':                FontAwesomeIcons.desktop,
    'microchip':              FontAwesomeIcons.microchip,
    'wifi':                   FontAwesomeIcons.wifi,
    'lock':                   FontAwesomeIcons.lock,
    'key':                    FontAwesomeIcons.key,
    'shield':                 FontAwesomeIcons.shield,
    'gears':                  FontAwesomeIcons.gears,
    'terminal':               FontAwesomeIcons.terminal,
    'bug':                    FontAwesomeIcons.bug,
    'robot':                  FontAwesomeIcons.robot,
    'plugCircleBolt':         FontAwesomeIcons.plugCircleBolt,
    'networkWired':           FontAwesomeIcons.networkWired,
    'ethernet':               FontAwesomeIcons.ethernet,
    'sliders':                FontAwesomeIcons.sliders,
    'wrench':                 FontAwesomeIcons.wrench,
    'screwdriverWrench':      FontAwesomeIcons.screwdriverWrench,
    'simCard':                FontAwesomeIcons.simCard,
    'hardDrive':              FontAwesomeIcons.hardDrive,
    // Location & Transport
    'locationDot':            FontAwesomeIcons.locationDot,
    'mapLocationDot':         FontAwesomeIcons.mapLocationDot,
    'buildingUser':           FontAwesomeIcons.buildingUser,
    'car':                    FontAwesomeIcons.car,
    'truckFast':              FontAwesomeIcons.truckFast,
    'personWalking':          FontAwesomeIcons.personWalking,
    'personRunning':          FontAwesomeIcons.personRunning,
    'compass':                FontAwesomeIcons.compass,
    'route':                  FontAwesomeIcons.route,
    'plane':                  FontAwesomeIcons.plane,
    'train':                  FontAwesomeIcons.train,
    'crosshairs':             FontAwesomeIcons.crosshairs,
    // Queue & Workflow
    'listCheck':              FontAwesomeIcons.listCheck,
    'clipboardList':          FontAwesomeIcons.clipboardList,
    'clipboardCheck':         FontAwesomeIcons.clipboardCheck,
    'ticket':                 FontAwesomeIcons.ticket,
    'calendarCheck':          FontAwesomeIcons.calendarCheck,
    'calendarDays':           FontAwesomeIcons.calendarDays,
    'clock':                  FontAwesomeIcons.clock,
    'stopwatch':              FontAwesomeIcons.stopwatch,
    'hourglassHalf':          FontAwesomeIcons.hourglassHalf,
    'arrowsRotate':           FontAwesomeIcons.arrowsRotate,
    'shuffle':                FontAwesomeIcons.shuffle,
    'signsPost':              FontAwesomeIcons.signsPost,
    'diagramProject':         FontAwesomeIcons.diagramProject,
    'timeline':               FontAwesomeIcons.timeline,
    'barsProgress':           FontAwesomeIcons.barsProgress,
    'filter':                 FontAwesomeIcons.filter,
    'sitemap':                FontAwesomeIcons.sitemap,
    // Documents & Files
    'file':                   FontAwesomeIcons.file,
    'fileLines':              FontAwesomeIcons.fileLines,
    'filePdf':                FontAwesomeIcons.filePdf,
    'fileExcel':              FontAwesomeIcons.fileExcel,
    'fileImage':              FontAwesomeIcons.fileImage,
    'folderOpen':             FontAwesomeIcons.folderOpen,
    'paperclip':              FontAwesomeIcons.paperclip,
    'print':                  FontAwesomeIcons.print,
    'qrcode':                 FontAwesomeIcons.qrcode,
    'barcode':                FontAwesomeIcons.barcode,
    'boxArchive':             FontAwesomeIcons.boxArchive,
    'fileCode':               FontAwesomeIcons.fileCode,
    'fileCsv':                FontAwesomeIcons.fileCsv,
    'folderPlus':             FontAwesomeIcons.folderPlus,
    // Status & Feedback
    'circleCheck':            FontAwesomeIcons.circleCheck,
    'circleXmark':            FontAwesomeIcons.circleXmark,
    'circleInfo':             FontAwesomeIcons.circleInfo,
    'triangleExclamation':    FontAwesomeIcons.triangleExclamation,
    'star':                   FontAwesomeIcons.star,
    'thumbsUp':               FontAwesomeIcons.thumbsUp,
    'thumbsDown':             FontAwesomeIcons.thumbsDown,
    'flag':                   FontAwesomeIcons.flag,
    'tag':                    FontAwesomeIcons.tag,
    'tags':                   FontAwesomeIcons.tags,
    'fire':                   FontAwesomeIcons.fire,
    'bolt':                   FontAwesomeIcons.bolt,
    'lightbulb':              FontAwesomeIcons.lightbulb,
    'eye':                    FontAwesomeIcons.eye,
    'eyeSlash':               FontAwesomeIcons.eyeSlash,
    'heart':                  FontAwesomeIcons.heart,
    'bookmark':               FontAwesomeIcons.bookmark,
    // Gender & Identity (Font Awesome)
    'mars':                   FontAwesomeIcons.mars,
    'venus':                  FontAwesomeIcons.venus,
    'marsAndVenus':           FontAwesomeIcons.marsAndVenus,
    'transgender':            FontAwesomeIcons.transgender,
    'genderless':             FontAwesomeIcons.genderless,
    'neuter':                 FontAwesomeIcons.neuter,
    'venusMars':              FontAwesomeIcons.venusMars,
    'marsDouble':             FontAwesomeIcons.marsDouble,
    'venusDouble':            FontAwesomeIcons.venusDouble,
  };
}
