import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/customer_models.dart';
import '../../../core/network/dio_provider.dart';

/// ============================================================================
/// STAGE 3: CUSTOMER MOBILE WEB TICKET STATUS TRACKER
/// Customers scan QR code on physical ticket to track live queue status on phone
/// ============================================================================
class CustomerMobileStatusScreen extends ConsumerStatefulWidget {
  final int tokenId;
  const CustomerMobileStatusScreen({super.key, this.tokenId = 1});

  @override
  ConsumerState<CustomerMobileStatusScreen> createState() => _CustomerMobileStatusScreenState();
}

class _CustomerMobileStatusScreenState extends ConsumerState<CustomerMobileStatusScreen> {
  PublicTokenStatusDto? _status;
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // Auto-poll live ticket status every 4 seconds on mobile
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) => _fetchStatus());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/v1/public/ticket-status/${widget.tokenId}');

      if (response.data != null && response.data is Map) {
        final data = response.data['data'] ?? response.data['Data'];
        if (data != null) {
          setState(() {
            _status = PublicTokenStatusDto.fromJson(Map<String, dynamic>.from(data));
            _isLoading = false;
            _error = null;
          });
          return;
        }
      }
      setState(() {
        _isLoading = false;
        _error = 'Ticket not active or completed.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = null; // Suppress raw network errors gracefully
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12171F),
        elevation: 0,
        title: const Text('Live Queue Ticket Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2F81F7)))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Ticket Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12171F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF222B36)),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 16)],
                    ),
                    child: Column(
                      children: [
                        const Text('YOUR QUEUE NUMBER', style: TextStyle(color: Color(0xFF6E7681), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                        const SizedBox(height: 12),
                        Text(
                          _status?.tokenNumber ?? 'A-001',
                          style: const TextStyle(color: Color(0xFF2F81F7), fontSize: 64, fontWeight: FontWeight.w900, letterSpacing: -2),
                        ),
                        const SizedBox(height: 8),
                        Text(_status?.processName ?? 'Consultation Service', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const Divider(color: Color(0xFF222B36), height: 32),

                        // Queue Metrics Grid
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Text('CUSTOMERS AHEAD', style: TextStyle(color: Color(0xFF6E7681), fontSize: 11, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text('${_status?.customersAhead ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            Container(height: 40, width: 1, color: const Color(0xFF222B36)),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text('EST. WAIT TIME', style: TextStyle(color: Color(0xFF6E7681), fontSize: 11, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text('~${_status?.estimatedWaitMinutes ?? 0} mins', style: const TextStyle(color: Color(0xFFD29922), fontSize: 24, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Banner if ticket not found
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ),

                  // Counter Alert Box if Called
                  if (_status?.counterNumber != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF238636).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF238636)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.campaign_rounded, color: Color(0xFF238636), size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('YOUR TOKEN HAS BEEN CALLED!', style: TextStyle(color: Color(0xFF238636), fontWeight: FontWeight.w800, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('Please proceed to Counter ${_status?.counterNumber}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),
                  const Text('Live auto-refresh enabled • Keep this page open', style: TextStyle(color: Color(0xFF6E7681), fontSize: 12)),
                ],
              ),
            ),
    );
  }
}
