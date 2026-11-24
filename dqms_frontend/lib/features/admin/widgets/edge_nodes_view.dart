import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/dqms_button.dart';
import '../../../core/widgets/dqms_status_badge.dart';
import '../../../core/widgets/dqms_text_field.dart';
import 'master_detail_layout.dart';
import '../models/edge_node_models.dart';
import '../providers/edge_node_provider.dart';
import 'edge_resilience_banner.dart';

class EdgeNodesView extends ConsumerStatefulWidget {
  const EdgeNodesView({super.key});

  @override
  ConsumerState<EdgeNodesView> createState() => _EdgeNodesViewState();
}

class _EdgeNodesViewState extends ConsumerState<EdgeNodesView> with SingleTickerProviderStateMixin {
  EdgeNodeRegistration? _selectedNode;
  bool _isRegistering = false;
  String _searchQuery = '';

  final _nodeIdController = TextEditingController();
  final _nodeNameController = TextEditingController();
  final _ipController = TextEditingController();
  final _macController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _versionController = TextEditingController(text: '1.0.0');
  bool _isActive = true;

  @override
  void dispose() {
    _nodeIdController.dispose();
    _nodeNameController.dispose();
    _ipController.dispose();
    _macController.dispose();
    _secretKeyController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  void _initForm(EdgeNodeRegistration? node) {
    if (node != null) {
      _nodeIdController.text = node.nodeId;
      _nodeNameController.text = node.nodeName;
      _ipController.text = node.ipAddress ?? '';
      _macController.text = node.macAddress ?? '';
      _secretKeyController.text = '';
      _versionController.text = node.softwareVersion ?? '1.0.0';
      _isActive = node.isActive;
      _isRegistering = false;
    } else {
      final randSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
      _nodeIdController.text = 'EDGE-BR-$randSuffix';
      _nodeNameController.text = 'Branch Edge Appliance $randSuffix';
      _ipController.text = '192.168.1.50';
      _macController.text = '00:1A:2B:3C:4D:5E';
      _secretKeyController.text = 'edgesec_key_$randSuffix';
      _versionController.text = '1.0.0';
      _isActive = true;
      _isRegistering = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nodesAsync = ref.watch(edgeNodesProvider);

    return nodesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary)),
      error: (err, _) => Center(child: Text('Error loading edge appliances: $err', style: const TextStyle(color: Colors.red))),
      data: (nodes) {
        final filteredNodes = nodes.where((n) {
          return n.nodeId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              n.nodeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (n.ipAddress ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return MasterDetailLayout(
          masterWidget: _buildMasterList(filteredNodes),
          detailWidget: (_selectedNode != null || _isRegistering) ? _buildDetailInspector() : null,
          detailTitle: _isRegistering
              ? 'Register New Edge Appliance'
              : (_selectedNode != null ? 'Appliance Telemetry — ${_selectedNode!.nodeId}' : 'Edge Inspector'),
          onCloseDetail: () {
            setState(() {
              _selectedNode = null;
              _isRegistering = false;
            });
          },
        );
      },
    );
  }

  Widget _buildMasterList(List<EdgeNodeRegistration> nodes) {
    final offlineCount = nodes.where((n) => !n.isOnline).length;
    final bannerStatus = offlineCount > 0 ? EdgeConnectivityStatus.edgeAutonomous : EdgeConnectivityStatus.cloudOnline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Network Resilience Status Banner
        EdgeResilienceBanner(
          status: bannerStatus,
          pendingJournalCount: nodes.fold<int>(0, (sum, n) => sum + n.pendingJournalCount),
          onSyncPressed: () => ref.read(edgeNodesProvider.notifier).refresh(),
        ),
        const SizedBox(height: 16),

        // Title Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Branch Edge Appliances & Hybrid Sync',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Local Kiosk, Counter Station & TV chime autonomy with automated cloud delta reconciliation',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Refresh Appliances',
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                  onPressed: () => ref.read(edgeNodesProvider.notifier).refresh(),
                ),
                const SizedBox(width: 8),
                DqmsButton(
                  label: '+ Register Edge Appliance',
                  icon: Icons.add_to_queue_rounded,
                  onPressed: () {
                    setState(() {
                      _selectedNode = null;
                      _initForm(null);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search Field
        SizedBox(
          width: 340,
          child: DqmsTextField(
            hintText: 'Search appliances by Node ID, Name, or IP...',
            prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.textSubtle),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        const SizedBox(height: 16),

        // Master Table of Nodes
        Expanded(
          child: nodes.isEmpty
              ? _buildEmptyState()
              : Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: ListView.separated(
                    itemCount: nodes.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.06), height: 1),
                    itemBuilder: (context, index) {
                      final node = nodes[index];
                      final isSelected = _selectedNode?.id == node.id;

                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          selected: isSelected,
                          selectedTileColor: AppColors.brandPrimary.withOpacity(0.12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: node.isOnline
                                ? AppColors.statusActive.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            child: Icon(
                              node.isOnline ? Icons.dns_rounded : Icons.router_rounded,
                              color: node.isOnline ? AppColors.statusActive : Colors.orangeAccent,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                node.nodeId,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(node),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${node.nodeName} • IP: ${node.ipAddress ?? "127.0.0.1"} • v${node.softwareVersion}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pending Journal: ${node.pendingJournalCount} events • Last Heartbeat: ${_formatTime(node.lastHeartbeatAt)}',
                                style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.sync_rounded, color: Colors.amber, size: 20),
                                tooltip: 'Trigger Delta Sync',
                                onPressed: () => _triggerManualSync(node),
                              ),
                              IconButton(
                                icon: const Icon(Icons.tune_rounded, color: Colors.white70, size: 20),
                                tooltip: 'Inspect Appliance',
                                onPressed: () {
                                  setState(() {
                                    _selectedNode = node;
                                    _initForm(node);
                                  });
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectedNode = node;
                              _initForm(node);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(EdgeNodeRegistration node) {
    if (!node.isActive) {
      return const DqmsStatusBadge(label: 'DISABLED', color: Colors.grey);
    }
    if (node.isOnline) {
      return const DqmsStatusBadge(label: 'ONLINE (HEALTHY)', color: AppColors.statusActive);
    }
    return const DqmsStatusBadge(label: 'AUTONOMOUS (OFFLINE)', color: Colors.orangeAccent);
  }

  Widget _buildDetailInspector() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node ID
          const Text('Appliance Node ID *', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          const SizedBox(height: 6),
          DqmsTextField(
            controller: _nodeIdController,
            hintText: 'EDGE-BRANCH-01',
          ),
          const SizedBox(height: 14),

          // Node Name
          const Text('Appliance Display Name *', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          const SizedBox(height: 6),
          DqmsTextField(
            controller: _nodeNameController,
            hintText: 'Dubai Main Clinic Edge Server',
          ),
          const SizedBox(height: 14),

          // IP Address & MAC
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LAN IP Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 6),
                    DqmsTextField(
                      controller: _ipController,
                      hintText: '192.168.1.50',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MAC Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 6),
                    DqmsTextField(
                      controller: _macController,
                      hintText: '00:1A:2B:3C:4D:5E',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Software Version
          const Text('Software Version', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          const SizedBox(height: 6),
          DqmsTextField(
            controller: _versionController,
            hintText: '1.0.0',
          ),
          const SizedBox(height: 16),

          // Switch
          Row(
            children: [
              Switch(
                value: _isActive,
                activeColor: AppColors.brandPrimary,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(width: 8),
              const Text('Active (Accept LAN dispatches & Syncs)', style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),

          // Save Button
          DqmsButton(
            label: _isRegistering ? 'Register Appliance' : 'Save Appliance Config',
            icon: Icons.save_rounded,
            onPressed: _saveAppliance,
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),

          // Sync Audit Logs for this Node
          if (_selectedNode != null) ...[
            Text(
              'Sync Reconciliation History — ${_selectedNode!.nodeId}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 10),
            _buildSyncAuditTable(_selectedNode!.nodeId),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncAuditTable(String nodeId) {
    final logsAsync = ref.watch(edgeSyncLogsProvider(nodeId));

    return logsAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.brandPrimary))),
      error: (e, _) => Text('Error loading sync logs: $e', style: const TextStyle(color: Colors.red, fontSize: 12)),
      data: (logs) {
        if (logs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('No sync batches recorded yet for this edge node.', style: TextStyle(color: Colors.white60, fontSize: 12)),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            children: logs.take(5).map((log) {
              return ListTile(
                dense: true,
                leading: Icon(
                  log.status == 'Success' ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: log.status == 'Success' ? Colors.green : Colors.redAccent,
                  size: 16,
                ),
                title: Text('Batch: ${log.batchId}', style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                subtitle: Text(
                  'Ingested: ${log.recordsCount} • Conflicts: ${log.conflictsResolved} • Latency: ${log.durationMs}ms',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
                trailing: Text(
                  _formatTime(log.createdDate),
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.router_rounded, size: 56, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          const Text('No Edge Appliances Registered', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Register a local branch Edge Node to enable zero-downtime offline continuity.', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _saveAppliance() async {
    final data = {
      'id': _selectedNode?.id ?? 0,
      'nodeId': _nodeIdController.text.trim(),
      'nodeName': _nodeNameController.text.trim(),
      'organizationId': 1,
      'locationId': 1,
      'ipAddress': _ipController.text.trim(),
      'macAddress': _macController.text.trim(),
      'secretKey': _secretKeyController.text.trim(),
      'softwareVersion': _versionController.text.trim(),
      'isActive': _isActive,
    };

    final ok = await ref.read(edgeNodesProvider.notifier).registerNode(data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Edge Appliance Saved Successfully' : 'Failed to save Edge Appliance')),
      );
      if (ok) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  Future<void> _triggerManualSync(EdgeNodeRegistration node) async {
    final repo = ref.read(edgeNodeRepositoryProvider);
    final batchData = {
      'batchId': 'manual_${DateTime.now().millisecondsSinceEpoch}',
      'nodeId': node.nodeId,
      'organizationId': node.organizationId,
      'locationId': node.locationId,
      'items': [
        {
          'clientTokenGuid': '018dc3f0-4a82-7000-8000-123456789abc',
          'tokenNumber': 'OFF-T-101',
          'processId': 1,
          'counterId': 1,
          'priorityTier': 19001,
          'tokenStatus': 18007,
          'createdDate': DateTime.now().toUtc().toIso8601String(),
          'completedTime': DateTime.now().toUtc().toIso8601String(),
        }
      ],
    };

    final result = await repo.triggerSyncBatch(batchData);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result != null
              ? 'Sync Completed: ${result.recordsIngested} Ingested, ${result.conflictsResolved} Conflicts Resolved (${result.durationMs}ms)'
              : 'Sync Trigger Failed'),
        ),
      );
      ref.invalidate(edgeSyncLogsProvider(node.nodeId));
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'Never';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
