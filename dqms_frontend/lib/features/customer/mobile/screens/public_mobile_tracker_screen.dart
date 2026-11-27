import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/core/models/customer_models.dart';
import 'package:dqms_frontend/core/widgets/language_selector_dropdown.dart';

/// ============================================================================
/// PWA VIRTUAL QUEUEING TRACKER (PublicMobileTrackerScreen)
/// App-less, login-free live status tracking screen opened via QR scan on phone.
/// Features live polling, queue position counter, estimated wait time,
/// and high-priority sound / haptic vibration when called at a counter.
/// ============================================================================
class PublicMobileTrackerScreen extends ConsumerStatefulWidget {
  final String identifier; // Numeric TokenId or Alphanumeric TokenNumber (e.g. A-010)
  final bool autoPolling;

  const PublicMobileTrackerScreen({
    super.key,
    required this.identifier,
    this.autoPolling = true,
  });

  @override
  ConsumerState<PublicMobileTrackerScreen> createState() => _PublicMobileTrackerScreenState();
}

class _PublicMobileTrackerScreenState extends ConsumerState<PublicMobileTrackerScreen> {
  PublicTokenStatusDto? _status;
  bool _isLoading = true;
  String? _error;
  Timer? _poller;
  int _lastKnownStatus = 0;

  @override
  void initState() {
    super.initState();
    if (widget.autoPolling) {
      _fetchTicketStatus();
      // Auto-poll status every 3.5 seconds
      _poller = Timer.periodic(const Duration(milliseconds: 3500), (_) => _fetchTicketStatus());
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  Future<void> _fetchTicketStatus() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));

      final response = await dio.get('/api/v1/public/ticket-status/${widget.identifier}');

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final data = body is Map ? (body['data'] ?? body['Data']) : null;

        if (data != null && data is Map) {
          final newStatus = PublicTokenStatusDto.fromJson(Map<String, dynamic>.from(data));

          // Trigger haptic buzz if token state transitions to 'Calling' (18003)
          if (newStatus.tokenStatus == 18003 && _lastKnownStatus != 18003) {
            HapticFeedback.heavyImpact();
            SystemSound.play(SystemSoundType.alert);
          }

          if (mounted) {
            setState(() {
              _status = newStatus;
              _lastKnownStatus = newStatus.tokenStatus;
              _isLoading = false;
              _error = null;
            });
          }
          return;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Ticket not active or invalid number.';
        });
      }
    } catch (e) {
      if (mounted && _status == null) {
        setState(() {
          _isLoading = false;
          _error = 'Connecting to clinic queue system...';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final isCalling = status?.tokenStatus == 18003;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.qr_code_2_rounded, color: Colors.cyanAccent, size: 20),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Virtual Queue Pass', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                  Text('Real-Time Mobile Tracker • No App Required', style: TextStyle(color: Colors.white54, fontSize: 10), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: LanguageSelectorDropdown(showNativeName: false)),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                : _error != null && status == null
                    ? _buildErrorView()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Column(
                          children: [
                            // 1. Live Calling Banner (Flashing Amber/Green if calling)
                            if (isCalling) _buildCallingBanner(status!),

                            // 2. Primary Ticket Pass Card
                            _buildTicketCard(status),

                            const SizedBox(height: 20),

                            // 3. Live Metrics Grid (Ahead in line & Est. Wait)
                            _buildMetricsRow(status),

                            const SizedBox(height: 20),

                            // 4. Assigned Counter & Service Info
                            _buildServiceInfoCard(status),

                            const SizedBox(height: 24),

                            // 5. Live Auto-Refresh Status Pill
                            _buildLiveSyncIndicator(),
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallingBanner(PublicTokenStatusDto status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amberAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amberAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amberAccent.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded, color: Colors.amberAccent, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOW CALLING YOUR NUMBER!',
                  style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'Please proceed immediately to ${status.counterName ?? "Counter ${status.counterNumber ?? '1'}"}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(PublicTokenStatusDto? status) {
    final tokenNum = status?.tokenNumber ?? widget.identifier.toUpperCase();
    final isCalling = status?.tokenStatus == 18003;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF131D2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCalling ? Colors.amberAccent : Colors.cyanAccent.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCalling ? Colors.amberAccent : Colors.cyanAccent).withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'YOUR QUEUE TICKET',
            style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Text(
            tokenNum,
            style: TextStyle(
              color: isCalling ? Colors.amberAccent : Colors.cyanAccent,
              fontSize: 56,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status?.tokenStatus ?? 18001).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor(status?.tokenStatus ?? 18001)),
            ),
            child: Text(
              _getStatusLabel(status?.tokenStatus ?? 18001),
              style: TextStyle(
                color: _getStatusColor(status?.tokenStatus ?? 18001),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(PublicTokenStatusDto? status) {
    final aheadCount = status?.customersAhead ?? 0;
    final waitMins = status?.estimatedWaitMinutes ?? (aheadCount * 5);

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            icon: Icons.people_alt_outlined,
            label: 'CUSTOMERS AHEAD',
            value: '$aheadCount',
            accentColor: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.timer_outlined,
            label: 'ESTIMATED WAIT',
            value: '~ $waitMins Mins',
            accentColor: Colors.tealAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131D2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildServiceInfoCard(PublicTokenStatusDto? status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131D2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Service Requested', status?.processName ?? 'Medical Consultation & Triage'),
          const Divider(color: Colors.white12, height: 20),
          _buildInfoRow('Target Serving Window', status?.counterName ?? (status?.counterNumber != null ? 'Counter ${status!.counterNumber}' : 'Auto-Allocating Counter...')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 3,
          child: Text(
            val,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveSyncIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.greenAccent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Live Queue Synchronized • Auto-Refreshes Instantly',
            style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.amberAccent, size: 48),
          const SizedBox(height: 16),
          Text(_error ?? 'Unable to find ticket.', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Please ensure your QR code was scanned accurately or speak with reception.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Refreshing'),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchTicketStatus();
            },
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(int code) {
    switch (code) {
      case 18003:
        return 'NOW CALLING';
      case 18004:
        return 'BEING SERVED';
      case 18005:
        return 'ON HOLD';
      case 18007:
        return 'COMPLETED';
      case 18008:
        return 'FORWARDED';
      case 18006:
        return 'CANCELED';
      case 18001:
      default:
        return 'IN WAITING QUEUE';
    }
  }

  Color _getStatusColor(int code) {
    switch (code) {
      case 18003:
        return Colors.amberAccent; // Calling
      case 18004:
        return Colors.greenAccent; // Active
      case 18005:
        return Colors.orangeAccent; // Hold
      case 18007:
        return Colors.tealAccent; // Completed
      case 18008:
        return Colors.purpleAccent; // Forwarded
      case 18001:
      default:
        return Colors.cyanAccent; // Queued
    }
  }
}
