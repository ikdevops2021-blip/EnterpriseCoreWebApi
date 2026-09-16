import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_states.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// ============================================================================
/// TOKEN TRANSACTIONS & AUDIT LOG EXPLORER SCREEN (Domain 4)
/// Multi-filter operational log and chronological audit timeline for TokenTransaction and TokenAuditHistory
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
      detailTitle: _selectedToken != null ? 'Token Audit Log Inspector — ${_selectedToken!.tokenNumber}' : 'Audit Inspector',
      onCloseDetail: () => setState(() => _selectedToken = null),
    );
  }

  /// Master Token Table & Multi-Filter Bar
  Widget _buildMasterTable(List<TokenTransactionModel> filteredTokens, List<TokenTransactionModel> allTokens) {
    final uniqueServices = ['All Services', ...allTokens.map((t) => t.processName).toSet()];
    final uniqueStatuses = ['All Statuses', 'Issued', 'Called', 'Serving', 'Completed', 'NoShow', 'Transferred'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------------------
          // Multi-Filter Bar
          // ------------------------------------------------------------------
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search Input
              SizedBox(
                width: 260,
                child: DqmsTextField(
                  hintText: 'Search Token #, Sub-Token, Visitor...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Filter by Service / Process
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgCanvas,
                  borderRadius: BorderRadius.circular(6),
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
                  color: AppColors.bgCanvas,
                  borderRadius: BorderRadius.circular(6),
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
          const SizedBox(height: 16),

          // ------------------------------------------------------------------
          // Master Table Content (Responsive Layout)
          // ------------------------------------------------------------------
          if (filteredTokens.isEmpty)
            const Expanded(
              child: DqmsEmptyState(
                title: 'No Token Transactions Found',
                message: 'No queue tokens match your multi-filter search criteria.',
                icon: Icons.confirmation_number_outlined,
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 650;

                  if (isMobile) {
                    return ListView.builder(
                      itemCount: filteredTokens.length,
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      itemBuilder: (ctx, i) {
                        final token = filteredTokens[i];
                        final isSelected = _selectedToken?.tokenId == token.tokenId;
                        return _buildMobileTokenCard(token, isSelected);
                      },
                    );
                  }

                  // Desktop / Tablet Multi-Column View
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 780,
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.bgHeader,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 90, child: Text('TOKEN #', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                Expanded(flex: 3, child: Text('SERVICE / PROCESS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                Expanded(flex: 2, child: Text('COUNTER STATION', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                Expanded(flex: 2, child: Text('VISITOR / PERSON', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                SizedBox(width: 100, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                SizedBox(width: 90, child: Text('SLA TAT', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Token List Rows
                          Expanded(
                            child: ListView.separated(
                              itemCount: filteredTokens.length,
                              separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                              itemBuilder: (ctx, i) {
                                final token = filteredTokens[i];
                                final isSelected = _selectedToken?.tokenId == token.tokenId;

                                return InkWell(
                                  onTap: () => setState(() => _selectedToken = token),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        // Token # Column
                                        SizedBox(
                                          width: 90,
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
                                        // Service Name
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            token.processName,
                                            style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Counter Station
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            token.counterName,
                                            style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Visitor / Person Name
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            token.visitorName,
                                            style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w700),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Status Pill
                                        SizedBox(
                                          width: 100,
                                          child: _buildTokenStatusBadge(token.status),
                                        ),
                                        // SLA TAT & Wait Time
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            '${token.waitTimeMins}m Wait',
                                            style: TextStyle(
                                              color: token.isSlaCompliant ? AppColors.statusActive : AppColors.statusError,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
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
            ),
        ],
      ),
    );
  }

  /// Mobile Adaptive Card for Small Screens (< 650px)
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Token Badge, Status Badge & Wait Time
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

            // Middle: Service / Process Name
            Text(
              token.processName,
              style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            // Bottom: Counter Station & Visitor Name
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

  /// Status Badge Helper
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

  /// Right Side Panel — Chronological Token Audit Log Inspector (`TokenAuditHistory`)
  Widget _buildAuditLogInspector(TokenTransactionModel token) {
    final auditLogs = ref.watch(tokenAuditHistoryProvider(token.tokenId));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCanvas,
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
                    Text('Wait Time: ${token.waitTimeMins}m', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
                    Text('Service Time: ${token.serviceTimeMins}m', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
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
                  color: AppColors.bgCanvas,
                  borderRadius: BorderRadius.circular(6),
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
