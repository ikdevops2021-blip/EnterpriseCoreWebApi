import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_states.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// ============================================================================
/// TOKEN TRANSACTIONS & AUDIT LOG EXPLORER SCREEN (Domain 4)
/// Multi-filter operational log and chronological audit timeline for TokenTransaction and TokenAuditHistory
/// 1:1 Matched to Stitch Screen: "Real-time Token Transactions & Operational Audit Log"
/// ============================================================================
class TokenTransactionsView extends ConsumerStatefulWidget {
  const TokenTransactionsView({super.key});

  @override
  ConsumerState<TokenTransactionsView> createState() => _TokenTransactionsViewState();
}

class _TokenTransactionsViewState extends ConsumerState<TokenTransactionsView> {
  String _searchQuery = '';
  String _filterService = 'All Services';
  final String _filterCounter = 'All Counters';
  String _filterStatus = 'All Statuses';

  TokenTransactionModel? _selectedToken;

  @override
  Widget build(BuildContext context) {
    final tokens = ref.watch(tokenTransactionsProvider);

    final filteredTokens = tokens.where((t) {
      final matchesSearch = t.tokenNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.visitorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.subTokenNumber != null && t.subTokenNumber!.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesService = _filterService == 'All Services' || t.processName == _filterService;
      final matchesCounter = _filterCounter == 'All Counters' || t.counterName.contains(_filterCounter);
      final matchesStatus = _filterStatus == 'All Statuses' || t.status == _filterStatus;

      return matchesSearch && matchesService && matchesCounter && matchesStatus;
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filteredTokens, tokens),
      detailWidget: _selectedToken != null ? _buildAuditLogInspector(_selectedToken!) : null,
      detailTitle: _selectedToken != null ? 'Audit Log Inspector — ${_selectedToken!.tokenNumber}' : 'Audit Inspector',
      onCloseDetail: () => setState(() => _selectedToken = null),
    );
  }

  /// Master Token Table & Multi-Filter Bar
  Widget _buildMasterTable(List<TokenTransactionModel> filteredTokens, List<TokenTransactionModel> allTokens) {
    final uniqueServices = ['All Services', ...allTokens.map((t) => t.processName).toSet()];
    final uniqueStatuses = ['All Statuses', 'Issued', 'Called', 'Serving', 'Completed', 'NoShow', 'Transferred'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight = constraints.maxHeight < 550;

        // --------------------------------------------------------------------
        // 1. PAGE TITLE & TELEMETRY HEADER
        // --------------------------------------------------------------------
        final headerWidget = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.confirmation_number_rounded, color: AppColors.brandPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'Real-time Token Transactions & Audit Log',
                                  style: TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusActive.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.statusActive.withValues(alpha: 0.3)),
                                  ),
                                  child: const Text(
                                    'Live Stream Telemetry: 120Hz',
                                    style: TextStyle(color: AppColors.statusActive, fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Complete chronological timeline of visitor issuance, counter dispatch, transfer events, and SLA audits.',
                              style: TextStyle(color: AppColors.textSubtle, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Quick Action Controls
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      DqmsButton(
                        label: 'Export Audit Log (CSV)',
                        icon: Icons.file_download_outlined,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Audit log exported successfully.')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        // --------------------------------------------------------------------
        // 2. TELEMETRY KPI BANNER (5 CARDS)
        // --------------------------------------------------------------------
        final kpiBarWidget = LayoutBuilder(
          builder: (context, kpiConstraints) {
            final cardWidth = kpiConstraints.maxWidth < 550
                ? kpiConstraints.maxWidth
                : kpiConstraints.maxWidth < 960
                    ? (kpiConstraints.maxWidth - 8) / 2
                    : (kpiConstraints.maxWidth - 32) / 5;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Tokens Issued Today',
                  value: '1,429',
                  trend: '+14% vs baseline',
                  trendColor: AppColors.statusActive,
                  icon: Icons.confirmation_number_outlined,
                  accentColor: AppColors.brandPrimary,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Currently Waiting',
                  value: '38',
                  trend: 'Avg wait: 6m 40s',
                  trendColor: AppColors.brandAccent,
                  icon: Icons.hourglass_top_rounded,
                  accentColor: AppColors.brandAccent,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Completed Today',
                  value: '1,365',
                  trend: '95.5% SLA adherence',
                  trendColor: AppColors.statusActive,
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: AppColors.statusActive,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'No-Show / Voided',
                  value: '26',
                  trend: '1.8% rate (-0.4%)',
                  trendColor: AppColors.statusError,
                  icon: Icons.cancel_outlined,
                  accentColor: AppColors.statusError,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Real-time Throughput',
                  value: '42 tok/h',
                  trend: 'Peak: 58/hr',
                  trendColor: AppColors.brandPrimary,
                  icon: Icons.bolt_rounded,
                  accentColor: AppColors.brandPrimary,
                ),
              ],
            );
          },
        );

        // --------------------------------------------------------------------
        // 3. MULTI-FILTER TOOLBAR
        // --------------------------------------------------------------------
        final toolbarWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search field
              SizedBox(
                width: 250,
                child: DqmsTextField(
                  hintText: 'Search Token #, Patient MRN, or Doctor...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 16),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Filter by Service / Process
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterService,
                    dropdownColor: AppColors.bgSurface,
                    style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
                    items: uniqueServices
                        .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _filterService = val);
                    },
                  ),
                ),
              ),

              // Filter by Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterStatus,
                    dropdownColor: AppColors.bgSurface,
                    style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
                    items: uniqueStatuses
                        .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _filterStatus = val);
                    },
                  ),
                ),
              ),
            ],
          ),
        );

        // --------------------------------------------------------------------
        // 4. MASTER TABLE / LIST
        // --------------------------------------------------------------------
        final tableContainer = Container(
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: filteredTokens.isEmpty
                ? const DqmsEmptyState(
                    title: 'No Token Transactions Found',
                    message: 'No queue tokens match your multi-filter search criteria.',
                    icon: Icons.confirmation_number_outlined,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;
                      if (isMobile) {
                        return ListView.builder(
                          itemCount: filteredTokens.length,
                          padding: const EdgeInsets.all(12),
                          itemBuilder: (ctx, i) {
                            final token = filteredTokens[i];
                            final isSelected = _selectedToken?.tokenId == token.tokenId;
                            return _buildMobileTokenCard(token, isSelected);
                          },
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 880,
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSurfaceHover,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(width: 100, child: Text('TOKEN #', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace'))),
                                    Expanded(flex: 3, child: Text('SERVICE & WING', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    Expanded(flex: 2, child: Text('COUNTER & CLINICIAN', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    Expanded(flex: 2, child: Text('PATIENT / SUBJECT', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    SizedBox(width: 110, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    SizedBox(width: 100, child: Text('WAIT / SLA', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                    SizedBox(width: 50, child: Text('AUDIT', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                  ],
                                ),
                              ),

                              // Table Rows
                              Expanded(
                                child: ListView.separated(
                                  itemCount: filteredTokens.length,
                                  separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                                  itemBuilder: (ctx, i) {
                                    final token = filteredTokens[i];
                                    final isSelected = _selectedToken?.tokenId == token.tokenId;

                                    return InkWell(
                                      onTap: () => setState(() => _selectedToken = token),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
                                          border: isSelected ? const Border(left: BorderSide(color: AppColors.brandPrimary, width: 3)) : null,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    token.tokenNumber,
                                                    style: const TextStyle(
                                                      color: AppColors.brandPrimary,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w800,
                                                      fontFamily: 'monospace',
                                                    ),
                                                  ),
                                                  if (token.subTokenNumber != null)
                                                    Text(
                                                      token.subTokenNumber!,
                                                      style: const TextStyle(color: AppColors.brandAccent, fontSize: 10, fontFamily: 'monospace'),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                token.processName,
                                                style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                token.counterName,
                                                style: const TextStyle(color: AppColors.textSubtle, fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                token.visitorName,
                                                style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 110,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: _buildTokenStatusBadge(token.status),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Text(
                                                '${token.waitTimeMins}m Wait',
                                                style: TextStyle(
                                                  color: token.isSlaCompliant ? AppColors.statusActive : AppColors.statusError,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 50,
                                              child: IconButton(
                                                icon: const Icon(Icons.history_rounded, size: 20, color: AppColors.brandPrimary),
                                                tooltip: 'Inspect Audit Trail',
                                                onPressed: () => setState(() => _selectedToken = token),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );

        // --------------------------------------------------------------------
        // 5. FOOTER STATUS
        // --------------------------------------------------------------------
        final footerWidget = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Showing ${filteredTokens.length} of ${allTokens.length} Token Transactions',
                style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Row(
              children: [
                Icon(Icons.chevron_left_rounded, color: AppColors.textMuted, size: 18),
                SizedBox(width: 8),
                Text('Page 1 of 1', style: TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.w600)),
                SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
              ],
            ),
          ],
        );

        if (isCompactHeight) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerWidget,
                const SizedBox(height: 12),
                kpiBarWidget,
                const SizedBox(height: 12),
                toolbarWidget,
                const SizedBox(height: 12),
                SizedBox(height: 380, child: tableContainer),
                const SizedBox(height: 8),
                footerWidget,
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerWidget,
            const SizedBox(height: 12),
            kpiBarWidget,
            const SizedBox(height: 12),
            toolbarWidget,
            const SizedBox(height: 12),
            Expanded(child: tableContainer),
            const SizedBox(height: 8),
            footerWidget,
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required double width,
    required String title,
    required String value,
    required String trend,
    required Color trendColor,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: AppColors.textSubtle, fontSize: 10, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(color: trendColor, fontSize: 10, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTokenCard(TokenTransactionModel token, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedToken = token),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.45) : AppColors.borderSubtle,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        token.tokenNumber,
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (token.subTokenNumber != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${token.subTokenNumber!})',
                          style: const TextStyle(color: AppColors.brandAccent, fontSize: 10, fontFamily: 'monospace'),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                _buildTokenStatusBadge(token.status),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: (token.isSlaCompliant ? AppColors.statusActive : AppColors.statusError).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${token.waitTimeMins}m Wait',
                    style: TextStyle(
                      color: token.isSlaCompliant ? AppColors.statusActive : AppColors.statusError,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              token.processName,
              style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.desk_rounded, size: 14, color: AppColors.textSubtle),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    token.counterName,
                    style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (token.visitorName.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSubtle),
                  const SizedBox(width: 4),
                  Text(
                    token.visitorName,
                    style: const TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenStatusBadge(String status) {
    Color color = AppColors.brandPrimary;
    if (status == 'Serving') color = AppColors.statusActive;
    if (status == 'Completed') color = AppColors.brandAccent;
    if (status == 'NoShow') color = AppColors.statusError;
    if (status == 'Transferred') color = AppColors.statusWarning;
    if (status == 'Called') color = AppColors.brandPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAuditLogInspector(TokenTransactionModel token) {
    final auditLogs = ref.watch(tokenAuditHistoryProvider(token.tokenId));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inspector Header Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      token.tokenNumber,
                      style: const TextStyle(color: AppColors.brandPrimary, fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                    ),
                    _buildTokenStatusBadge(token.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(token.visitorName, style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w700)),
                Text(token.processName, style: const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
                const SizedBox(height: 10),
                const Divider(color: AppColors.borderSubtle, height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Wait: ${token.waitTimeMins}m', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
                    Text('Service: ${token.serviceTimeMins}m', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
                    Text(
                      token.isSlaCompliant ? 'SLA PASSED' : 'SLA BREACHED',
                      style: TextStyle(
                        color: token.isSlaCompliant ? AppColors.statusActive : AppColors.statusError,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Audit Timeline Header
          const Row(
            children: [
              Icon(Icons.history_rounded, color: AppColors.brandPrimary, size: 18),
              SizedBox(width: 8),
              Text(
                'Chronological Audit Trail (TokenAuditHistory)',
                style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Timeline Items
          Column(
            children: auditLogs.map((audit) {
              final timeStr = DateFormat('HH:mm:ss').format(audit.timestamp);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          audit.actionName,
                          style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        Text(timeStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'monospace')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'State: ${audit.previousStatus} ➔ ${audit.newStatus}',
                      style: const TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text('Staff / System: ${audit.performedByStaff}', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
                    Text('Station: ${audit.counterName}', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
                    if (audit.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Notes: ${audit.notes}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
