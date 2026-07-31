import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/logging/client_logger.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// App Log Item Model
class AppLogModel {
  final int id;
  final String machineName;
  final DateTime logged;
  final String level;
  final String message;
  final String logger;
  final String? callsite;
  final String? exception;
  final String? verboseInfo;
  final String? url;
  final String? action;

  const AppLogModel({
    required this.id,
    required this.machineName,
    required this.logged,
    required this.level,
    required this.message,
    required this.logger,
    this.callsite,
    this.exception,
    this.verboseInfo,
    this.url,
    this.action,
  });

  factory AppLogModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['Id'] ?? 0;
    final rawLogged = json['logged'] ?? json['Logged'];
    DateTime parsedDate;
    if (rawLogged != null) {
      parsedDate = DateTime.tryParse(rawLogged.toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return AppLogModel(
      id: rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0,
      machineName: (json['machineName'] ?? json['MachineName'] ?? 'SERVER').toString(),
      logged: parsedDate,
      level: (json['level'] ?? json['Level'] ?? 'Info').toString(),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      logger: (json['logger'] ?? json['Logger'] ?? 'System').toString(),
      callsite: json['callsite'] ?? json['Callsite'],
      exception: json['exception'] ?? json['Exception'],
      verboseInfo: json['verboseInfo'] ?? json['VerboseInfo'],
      url: json['url'] ?? json['Url'],
      action: json['action'] ?? json['Action'],
    );
  }
}

/// APPLICATION & AUDIT LOGS INSPECTION VIEW
class AppLogsView extends ConsumerStatefulWidget {
  const AppLogsView({super.key});

  @override
  ConsumerState<AppLogsView> createState() => _AppLogsViewState();
}

class _AppLogsViewState extends ConsumerState<AppLogsView> {
  String _searchQuery = '';
  String _selectedLevel = 'ALL';
  DateTime? _selectedDate; // Optional Date Filter
  AppLogModel? _selectedLog;
  bool _isLoading = false;

  List<AppLogModel> _logs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLogs();
    });
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$y-$m-$d $hh:$mm:$ss.$ms';
  }

  String _formatShortTime(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$m/$d $hh:$mm:$ss.$ms';
  }

  List _extractDataList(dynamic responseData) {
    if (responseData == null) return [];
    if (responseData is String) {
      try {
        responseData = jsonDecode(responseData);
      } catch (_) {
        return [];
      }
    }
    if (responseData is List) return responseData;
    if (responseData is Map) {
      final dataObj = responseData['data'] ?? responseData['Data'] ?? responseData['items'] ?? responseData['Items'] ?? responseData['result'] ?? responseData['Result'];
      if (dataObj is List) return dataObj;
      if (dataObj is String) {
        try {
          final parsed = jsonDecode(dataObj);
          if (parsed is List) return parsed;
        } catch (_) {}
      }
    }
    return [];
  }

  Future<void> _fetchLogs() async {
    try {
      setState(() => _isLoading = true);
      final dio = ref.read(dioProvider);

      final queryParams = <String, dynamic>{
        'pageSize': 150,
      };

      if (_selectedLevel != 'ALL') {
        queryParams['level'] = _selectedLevel;
      }
      if (_selectedDate != null) {
        queryParams['logDate'] = _formatDate(_selectedDate!);
      }
      if (_searchQuery.trim().isNotEmpty) {
        queryParams['search'] = _searchQuery.trim();
      }

      final res = await dio.get(
        '${AppConfig.apiBaseUrl}/api/v1/Logs',
        queryParameters: queryParams,
      );

      final items = _extractDataList(res.data);
      if (items.isNotEmpty) {
        final fetched = items.map((j) => AppLogModel.fromJson(Map<String, dynamic>.from(j))).toList();
        setState(() {
          _logs = fetched;
          if (_selectedLog == null && _logs.isNotEmpty) {
            _selectedLog = _logs.first;
          }
        });
      } else {
        setState(() {
          _logs = [];
          _selectedLog = null;
        });
      }
    } catch (e) {
      debugPrint('Error fetching application logs: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateFilter(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.brandPrimary,
              onPrimary: Colors.white,
              surface: AppColors.bgSurface,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _logs.where((l) {
      final matchesSearch = _searchQuery.isEmpty ||
          l.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.logger.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (l.exception?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (l.url?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesLevel = _selectedLevel == 'ALL' || l.level.toUpperCase() == _selectedLevel.toUpperCase();

      return matchesSearch && matchesLevel;
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filtered),
      detailWidget: _selectedLog != null ? _buildLogDetailInspector(_selectedLog!) : null,
      detailTitle: _selectedLog != null ? 'Log Inspector — Entry #${_selectedLog!.id}' : 'Log Inspector',
      onCloseDetail: () => setState(() => _selectedLog = null),
    );
  }

  Widget _buildMasterTable(List<AppLogModel> logs) {
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
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(color: AppColors.brandPrimary, minHeight: 2),
            ),

          // Filter Toolbar
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DqmsTextField(
                  hintText: 'Search Log Message, Exception, Logger, or URL...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _fetchLogs();
                  },
                ),
              ),
              const SizedBox(width: 10),

              // Log Level Dropdown Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLevel,
                    dropdownColor: AppColors.bgSurface,
                    style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w700),
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Levels')),
                      DropdownMenuItem(value: 'ERROR', child: Text('🔴 ERROR / FATAL')),
                      DropdownMenuItem(value: 'WARN', child: Text('🟡 WARN')),
                      DropdownMenuItem(value: 'INFO', child: Text('🔵 INFO')),
                      DropdownMenuItem(value: 'DEBUG', child: Text('⚪ DEBUG / TRACE')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedLevel = val);
                        _fetchLogs();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Optional Date Filter Picker Button
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month_rounded, size: 16),
                label: Text(
                  _selectedDate != null ? _formatDate(_selectedDate!) : 'All Dates (Default)',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _selectedDate != null ? AppColors.brandAccent : AppColors.textSubtle,
                  side: BorderSide(color: _selectedDate != null ? AppColors.brandAccent : AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onPressed: () => _selectDateFilter(context),
              ),

              if (_selectedDate != null) ...[
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.statusDeactive),
                  tooltip: 'Clear Date Filter',
                  onPressed: () {
                    setState(() => _selectedDate = null);
                    _fetchLogs();
                  },
                ),
              ],
              const SizedBox(width: 10),

              DqmsButton(
                label: 'Refresh',
                icon: Icons.refresh_rounded,
                onPressed: _fetchLogs,
              ),
              const SizedBox(width: 8),

              // Dispatch Test Client Log Button
              ElevatedButton.icon(
                icon: const Icon(Icons.bug_report_rounded, size: 14),
                label: const Text('Send Test Log', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final dio = ref.read(dioProvider);
                  await ClientLogger.logError(
                    dio,
                    'Manual Test Log Entry triggered from Admin Workspace Log Inspection View',
                    error: Exception('Manual Test Exception Diagnostics'),
                    loggerName: 'AppLogsView',
                  );
                  _fetchLogs();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Test Log dispatched to POST /api/v1/Logs!'),
                      backgroundColor: AppColors.statusActive,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Header Status Banner
          Row(
            children: [
              Text('Showing ${logs.length} Log Entries', style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
              if (_selectedDate != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.brandAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                  child: Text('Filtered by Date: ${_formatDate(_selectedDate!)}', style: const TextStyle(color: AppColors.brandAccent, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ],
              const Spacer(),
              const Text('Source: NLog + AppLogs DB Table', style: TextStyle(color: AppColors.textSubtle, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),

          // Log Entries Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: logs.isEmpty
                  ? const Center(
                      child: Text('No application logs found matching current filters.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    )
                  : Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: const BoxDecoration(
                            color: AppColors.bgHeader,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                            border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 140, child: Text('TIMESTAMP', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                              SizedBox(width: 90, child: Text('LEVEL', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                              SizedBox(width: 160, child: Text('LOGGER', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                              Expanded(child: Text('MESSAGE / EXCEPTION SUMMARY', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                            ],
                          ),
                        ),
                        // List
                        Expanded(
                          child: ListView.separated(
                            itemCount: logs.length,
                            separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                            itemBuilder: (ctx, i) {
                              final log = logs[i];
                              final isSelected = _selectedLog?.id == log.id;

                              return InkWell(
                                onTap: () => setState(() => _selectedLog = log),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          _formatShortTime(log.logged.toLocal()),
                                          style: const TextStyle(color: AppColors.textSubtle, fontSize: 11, fontFamily: 'monospace'),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: _buildLogLevelBadge(log.level),
                                      ),
                                      SizedBox(
                                        width: 160,
                                        child: Text(
                                          log.logger,
                                          style: const TextStyle(color: AppColors.brandPrimary, fontSize: 11, fontWeight: FontWeight.w700),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          log.message,
                                          style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
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
          ),
        ],
      ),
    );
  }

  Widget _buildLogLevelBadge(String level) {
    Color bg;

    switch (level.toUpperCase()) {
      case 'ERROR':
      case 'FATAL':
      case 'CRITICAL':
        bg = AppColors.statusDeactive;
        break;
      case 'WARN':
      case 'WARNING':
        bg = Colors.amber.shade800;
        break;
      case 'INFO':
        bg = AppColors.brandPrimary;
        break;
      case 'DEBUG':
      case 'TRACE':
      default:
        bg = AppColors.textMuted;
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: bg.withValues(alpha: 0.5)),
        ),
        child: Text(
          level.toUpperCase(),
          style: TextStyle(color: bg, fontSize: 10, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildLogDetailInspector(AppLogModel log) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildLogLevelBadge(log.level),
                    const SizedBox(width: 8),
                    Text('Log ID #${log.id}', style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text(_formatDateTime(log.logged.toLocal()), style: const TextStyle(color: AppColors.textSubtle, fontSize: 11, fontFamily: 'monospace')),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Logger Component: ${log.logger}', style: const TextStyle(color: AppColors.brandPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                Text('Server Machine Name: ${log.machineName}', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Message Container
          const Text('Log Message', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: SelectableText(
              log.message,
              style: const TextStyle(color: AppColors.textMain, fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 14),

          // Triggering URL / Action
          if (log.url != null && log.url!.isNotEmpty) ...[
            const Text('Triggering URL / Route', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: SelectableText(
                log.url!,
                style: const TextStyle(color: AppColors.brandAccent, fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Exception Diagnostics Stack Trace
          if (log.exception != null && log.exception!.isNotEmpty) ...[
            const Text('Exception Diagnostics & Stack Trace', style: TextStyle(color: AppColors.statusDeactive, fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgCanvas,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.statusDeactive.withValues(alpha: 0.4)),
              ),
              child: SelectableText(
                log.exception!,
                style: const TextStyle(color: AppColors.statusDeactive, fontSize: 11, fontFamily: 'monospace', height: 1.4),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Verbose Info / Properties
          if (log.verboseInfo != null && log.verboseInfo!.isNotEmpty) ...[
            const Text('Verbose Thread & Property Details', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: SelectableText(
                log.verboseInfo!,
                style: const TextStyle(color: AppColors.textSubtle, fontSize: 11, fontFamily: 'monospace', height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
