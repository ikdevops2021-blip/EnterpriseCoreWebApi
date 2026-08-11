import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/utils/icon_resolver.dart';

// ============================================================================
// DqmsIconPicker
// Reusable, searchable icon picker supporting BOTH Material (rounded) icons
// and Font Awesome icons side-by-side in a tabbed dialog.
//
// Storage convention:
//   "dashboard_rounded"  -> Material Icons  (no prefix)
//   "fa:hospital"        -> FontAwesome     ("fa:" prefix)
// ============================================================================

// -- Material icon groups ----------------------------------------------------
const _kMaterialGroups = <String, List<String>>{
  'Navigation & UI': [
    'menu_rounded','widgets_rounded','home_rounded','dashboard_rounded',
    'explore_rounded','layers_rounded','pages_rounded','view_module_rounded',
    'grid_view_rounded','view_list_rounded','apps_rounded','more_horiz_rounded',
    'view_stream_rounded','table_chart_rounded','table_rows_rounded','view_compact_rounded',
    'view_quilt_rounded','window_rounded','space_dashboard_rounded','dashboard_customize_rounded',
  ],
  'Queue & Operations': [
    'account_tree_rounded','desk_rounded','tv_rounded','queue_rounded',
    'timer_rounded','schedule_rounded','pending_actions_rounded','countertops_rounded',
    'confirmation_number_rounded','event_seat_rounded','meeting_room_rounded',
    'door_sliding_rounded','monitor_rounded','display_settings_rounded',
    'connected_tv_rounded','hourglass_top_rounded','hourglass_bottom_rounded',
    'update_rounded','alarm_rounded','punch_clock_rounded',
  ],
  'People & Auth': [
    'badge_rounded','person_search_rounded','people_rounded','person_rounded',
    'admin_panel_settings_rounded','manage_accounts_rounded','groups_rounded',
    'supervisor_account_rounded','person_add_rounded','person_remove_rounded',
    'face_rounded','fingerprint_rounded','lock_rounded','lock_open_rounded',
    'key_rounded','shield_rounded','verified_user_rounded','remember_me_rounded',
    'account_circle_rounded','portrait_rounded',
  ],
  'Organization': [
    'business_rounded','corporate_fare_rounded','location_on_rounded','apartment_rounded',
    'store_rounded','domain_rounded','map_rounded','place_rounded',
    'navigation_rounded','pin_drop_rounded','my_location_rounded',
    'center_focus_strong_rounded','flag_rounded',
  ],
  'Config & System': [
    'category_rounded','settings_suggest_rounded','settings_rounded',
    'tune_rounded','build_rounded','extension_rounded',
    'toggle_on_rounded','toggle_off_rounded',
    'sliders_rounded','construction_rounded','handyman_rounded',
    'psychology_rounded','memory_rounded','cpu_rounded','power_rounded',
    'dns_rounded','code_rounded',
  ],
  'Notifications & Comms': [
    'notifications_active_rounded','mark_email_read_rounded','sms_rounded',
    'mail_rounded','campaign_rounded','chat_bubble_rounded',
    'notifications_rounded','notifications_off_rounded','email_rounded',
    'contact_mail_rounded','contact_phone_rounded','phone_rounded',
    'phone_in_talk_rounded','forum_rounded','message_rounded',
    'feedback_rounded','announcement_rounded',
  ],
  'Analytics & Reports': [
    'analytics_rounded','bar_chart_rounded','show_chart_rounded',
    'pie_chart_rounded','trending_up_rounded','assessment_rounded',
    'insights_rounded','stacked_bar_chart_rounded','donut_small_rounded',
    'multiline_chart_rounded','query_stats_rounded','timeline_rounded',
    'ssid_chart_rounded','leaderboard_rounded',
  ],
  'Logs & Debug': [
    'terminal_rounded','history_rounded','receipt_long_rounded','bug_report_rounded',
    'code_off_rounded','description_rounded','article_rounded','summarize_rounded',
    'find_in_page_rounded','integration_instructions_rounded',
  ],
  'Finance & Commerce': [
    'payments_rounded','receipt_rounded','shopping_cart_rounded',
    'monetization_on_rounded','account_balance_rounded','credit_card_rounded',
    'account_balance_wallet_rounded','attach_money_rounded','price_change_rounded',
    'savings_rounded','point_of_sale_rounded','currency_exchange_rounded',
  ],
  'Healthcare & Medical': [
    'local_hospital_rounded','medical_services_rounded','health_and_safety_rounded',
    'medication_rounded','vaccines_rounded','bloodtype_rounded',
    'personal_injury_rounded','healing_rounded','biotech_rounded',
  ],
  'Misc': [
    'star_rounded','info_rounded','help_rounded','security_rounded',
    'cloud_rounded','storage_rounded','check_circle_rounded','cancel_rounded',
    'error_rounded','warning_rounded','lightbulb_rounded','launch_rounded','open_in_new_rounded',
  ],
  'Gender & Identity': [
    'male_rounded','female_rounded','transgender_rounded','wc_rounded',
  ],
};

// -- FontAwesome icon groups -------------------------------------------------
const _kFaGroups = <String, List<String>>{
  'Healthcare & Medical': [
    'hospital','hospitalUser','userDoctor','stethoscope','pills','syringe',
    'heartPulse','bedPulse','ambulance','microscope','dna','tooth',
    'vial','clipboardQuestion','notesMedical','kitMedical','weightScale','lungs','brain',
  ],
  'People & Identity': [
    'users','userTie','userShield','userGear','usersGear',
    'idCard','idBadge','addressBook','personChalkboard','child',
    'userPlus','userMinus','userCheck','userXmark','userPen','userLock',
    'userGraduate','peopleGroup','peopleRoof',
  ],
  'Communication': [
    'envelope','envelopeOpenText','comments','comment','phone','mobileScreen',
    'bell','bullhorn','rss','telegram','whatsapp','inbox','paperPlane',
    'shareNodes','headset','walkieTalkie','message',
  ],
  'Finance & Business': [
    'creditCard','moneyBill','moneyBillWave','fileInvoiceDollar','cashRegister',
    'handHoldingDollar','chartPie','chartLine','chartBar','chartArea',
    'briefcase','building','buildingColumns','shop','shoppingCart',
    'coins','wallet','receipt','piggyBank','scaleBalanced','vault','landmark',
  ],
  'Technology & System': [
    'server','database','cloud','cloudArrowUp','code','laptop','desktop',
    'microchip','wifi','lock','key','shield','gears','terminal','bug','robot',
    'plugCircleBolt','networkWired','ethernet','sliders','wrench',
    'screwdriverWrench','simCard','hardDrive',
  ],
  'Location & Transport': [
    'locationDot','mapLocationDot','buildingUser','car','truckFast',
    'personWalking','personRunning','compass','route','plane','train','crosshairs',
  ],
  'Queue & Workflow': [
    'listCheck','clipboardList','clipboardCheck','ticket','calendarCheck','calendarDays',
    'clock','stopwatch','hourglassHalf','arrowsRotate','shuffle','signsPost',
    'diagramProject','timeline','barsProgress','filter','sitemap',
  ],
  'Documents & Files': [
    'file','fileLines','filePdf','fileExcel','fileImage','folderOpen',
    'paperclip','print','qrcode','barcode','boxArchive','fileCode','fileCsv','folderPlus',
  ],
  'Status & Feedback': [
    'circleCheck','circleXmark','circleInfo','triangleExclamation',
    'star','thumbsUp','thumbsDown','flag','tag','tags','fire','bolt',
    'lightbulb','eye','eyeSlash','heart','bookmark',
  ],
  'Gender & Identity': [
    'mars','venus','marsAndVenus','transgender','genderless',
    'neuter','venusMars','marsDouble','venusDouble',
  ],
};

// ============================================================================
// Widget: Trigger row (compact - shown inline in forms)
// ============================================================================
class DqmsIconPicker extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onIconChanged;
  final Color accentColor;
  final String label;

  const DqmsIconPicker({
    super.key,
    this.value,
    required this.onIconChanged,
    this.accentColor = AppColors.brandPrimary,
    this.label = 'Category Icon',
  });

  @override
  State<DqmsIconPicker> createState() => _DqmsIconPickerState();
}

class _DqmsIconPickerState extends State<DqmsIconPicker> {
  String get _current => widget.value ?? 'widgets_rounded';

  Future<void> _openPicker() async {
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => _IconPickerDialog(
        initialSelection: _current,
        accentColor: widget.accentColor,
      ),
    );
    if (result != null) widget.onIconChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final resolved = IconResolver.resolve(_current);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label,
            style: const TextStyle(
                color: AppColors.textSubtle, fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 0.4)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: _openPicker,
              hoverColor: AppColors.bgSurfaceHover,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    // Preview swatch
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: widget.accentColor.withValues(alpha: 0.35)),
                      ),
                      child: Center(child: resolved.build(size: 18, color: widget.accentColor)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (resolved.isFontAwesome)
                                Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF528DD7).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text('FA',
                                      style: TextStyle(color: Color(0xFF528DD7), fontSize: 8, fontWeight: FontWeight.w900)),
                                ),
                              Flexible(
                                child: Text(_current,
                                    style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontFamily: 'monospace'),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          const Text('Tap to change icon',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(4)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.grid_view_rounded, color: Colors.white, size: 13),
                          SizedBox(width: 5),
                          Text('Pick Icon',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Dialog: full searchable tabbed picker
// ============================================================================
class _IconPickerDialog extends StatefulWidget {
  final String initialSelection;
  final Color accentColor;
  const _IconPickerDialog({required this.initialSelection, required this.accentColor});

  @override
  State<_IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<_IconPickerDialog>
    with SingleTickerProviderStateMixin {
  late String _selected;
  String _searchQuery = '';
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
    _tabController = TabController(length: 2, vsync: this, initialIndex: _selected.startsWith('fa:') ? 1 : 0);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Map<String, List<String>> _filterMaterial() {
    if (_searchQuery.isEmpty) return _kMaterialGroups;
    final q = _searchQuery;
    final result = <String, List<String>>{};
    for (final e in _kMaterialGroups.entries) {
      final m = e.value.where((k) => k.contains(q)).toList();
      if (m.isNotEmpty) result[e.key] = m;
    }
    return result;
  }

  Map<String, List<String>> _filterFa() {
    if (_searchQuery.isEmpty) return _kFaGroups;
    final q = _searchQuery;
    final result = <String, List<String>>{};
    for (final e in _kFaGroups.entries) {
      final m = e.value.where((k) => k.toLowerCase().contains(q)).toList();
      if (m.isNotEmpty) result[e.key] = m;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final selectedResolved = IconResolver.resolve(_selected);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        width: 780,
        constraints: const BoxConstraints(maxHeight: 640),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 40, offset: const Offset(0, 12))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -- Header --
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: widget.accentColor.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Center(child: selectedResolved.build(size: 22, color: widget.accentColor)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Icon',
                            style: TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: selectedResolved.isFontAwesome
                                    ? const Color(0xFF528DD7).withValues(alpha: 0.25)
                                    : AppColors.brandPrimary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                selectedResolved.isFontAwesome ? 'Font Awesome' : 'Material',
                                style: TextStyle(
                                  color: selectedResolved.isFontAwesome ? const Color(0xFF528DD7) : AppColors.brandPrimary,
                                  fontSize: 9, fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(_selected,
                                  style: const TextStyle(color: AppColors.brandAccent, fontSize: 11, fontFamily: 'monospace'),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(padding: EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18)),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: 1),

            // -- Search --
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                cursorColor: AppColors.brandPrimary,
                decoration: InputDecoration(
                  hintText: 'Search icons across both libraries...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 16),
                          onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                      : null,
                  filled: true,
                  fillColor: AppColors.bgCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              ),
            ),

            // -- Tabs --
            Container(
              color: AppColors.bgCanvas,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.brandPrimary,
                indicatorWeight: 2,
                labelColor: AppColors.textMain,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.widgets_rounded, size: 14),
                        const SizedBox(width: 6),
                        const Text('Material'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('',
                              style: const TextStyle(color: AppColors.brandPrimary, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.font_download_rounded, size: 14),
                        const SizedBox(width: 6),
                        const Text('Font Awesome'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF528DD7).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('',
                              style: const TextStyle(color: Color(0xFF528DD7), fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: 1),

            // -- Tab Content --
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGroupedGrid(_filterMaterial(), isFa: false),
                  _buildGroupedGrid(_filterFa(), isFa: true),
                ],
              ),
            ),

            const Divider(color: AppColors.borderSubtle, height: 1),

            // -- Footer --
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.borderSubtle)),
                    child: Text(
                      ' Material  |   Font Awesome',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 15),
                    label: const Text('Use This Icon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => Navigator.pop(context, _selected),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedGrid(Map<String, List<String>> groups, {required bool isFa}) {
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, color: AppColors.textDisabled, size: 40),
            const SizedBox(height: 10),
            Text('No icons match ""',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 4),
            const Text('Try a shorter keyword like "user" or "chart"',
                style: TextStyle(color: AppColors.textDisabled, fontSize: 11)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Row(
              children: [
                Container(width: 3, height: 12,
                    color: isFa ? const Color(0xFF528DD7) : AppColors.brandPrimary,
                    margin: const EdgeInsets.only(right: 6)),
                Text(entry.key,
                    style: const TextStyle(color: AppColors.textSubtle, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                const SizedBox(width: 6),
                Text('',
                    style: const TextStyle(color: AppColors.textDisabled, fontSize: 10)),
              ],
            ),
          ),
          Wrap(
            spacing: 4, runSpacing: 4,
            children: [
              for (final key in entry.value) _buildCell(key, isFa: isFa),
            ],
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCell(String key, {required bool isFa}) {
    final storedKey = isFa ? 'fa:$key' : key;
    final isSelected = storedKey == _selected;
    final resolved = IconResolver.resolve(storedKey);

    return Tooltip(
      message: storedKey,
      waitDuration: const Duration(milliseconds: 350),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.borderSubtle)),
      textStyle: const TextStyle(color: AppColors.textMain, fontSize: 10, fontFamily: 'monospace'),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => setState(() => _selected = storedKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: isSelected ? widget.accentColor.withValues(alpha: 0.20) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? widget.accentColor : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: resolved.build(
                size: 20,
                color: isSelected ? widget.accentColor : AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
