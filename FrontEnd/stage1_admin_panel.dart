import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// ============================================================================
// 1. ENUM DEFINITIONS (MANDATORY e_ PREFIX STANDARD)
// ============================================================================
enum e_ActiveSearchStatus { deactive(0), active(1), all(2); const e_ActiveSearchStatus(this.value); final int value; }
enum e_DeleteSearchStatus { notDeleted(0), deleted(1), all(2); const e_DeleteSearchStatus(this.value); final int value; }

enum e_TokenStatus { queued(18001), waiting(18002), calling(18003), active(18004), hold(18005), canceled(18006), completed(18007), forwarded(18008); const e_TokenStatus(this.value); final int value; }
enum e_PriorityTier { standard(19001), seniorCitizen(19002), disabled(19003), emergency(19004), vip(19005); const e_PriorityTier(this.value); final int value; }
enum e_CounterStatus { idle(20001), serving(20002), breakMode(20003), offline(20004); const e_CounterStatus(this.value); final int value; }
enum e_DisplayTemplateType { gridView(21001), splitScreenVideo(21002), highDensityList(21003), audioVisualBanner(21004); const e_DisplayTemplateType(this.value); final int value; }

// ============================================================================
// 2. DTO MODELS
// ============================================================================
class AreaDto {
  final int id;
  final string areaCode;
  final int organizationId;
  final int locationId;
  final string areaName;
  final string? description;
  final bool isActive;

  AreaDto({required this.id, required this.areaCode, required this.organizationId, required this.locationId, required this.areaName, this.description, required this.isActive});

  factory AreaDto.fromJson(Map<String, dynamic> json) {
    return AreaDto(
      id: json['id'] ?? 0,
      areaCode: json['areaCode'] ?? '',
      organizationId: json['organizationId'] ?? 0,
      locationId: json['locationId'] ?? 0,
      areaName: json['areaName'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? true,
    );
  }
}

class ProcessDto {
  final int id;
  final string processCode;
  final int organizationId;
  final string processName;
  final string prefix;
  final int targetTATMinutes;
  final bool allowSubTokens;
  final bool isActive;

  ProcessDto({required this.id, required this.processCode, required this.organizationId, required this.processName, required this.prefix, required this.targetTATMinutes, required this.allowSubTokens, required this.isActive});

  factory ProcessDto.fromJson(Map<String, dynamic> json) {
    return ProcessDto(
      id: json['id'] ?? 0,
      processCode: json['processCode'] ?? '',
      organizationId: json['organizationId'] ?? 0,
      processName: json['processName'] ?? '',
      prefix: json['prefix'] ?? 'A',
      targetTATMinutes: json['targetTATMinutes'] ?? 15,
      allowSubTokens: json['allowSubTokens'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }
}

// ============================================================================
// 3. DIO HTTP CLIENT PROVIDER
// ============================================================================
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'http://localhost:5026',
    connectTimeout: const Duration(seconds: 5),
    headers: {'Content-Type': 'application/json'},
  ));
});

// ============================================================================
// 4. RIVERPOD ASYNC NOTIFIER PROVIDERS (STAGE 1 ADMIN MASTERS)
// ============================================================================
final areaListProvider = AsyncNotifierProvider<AreaListNotifier, List<AreaDto>>(AreaListNotifier.new);

class AreaListNotifier extends AsyncNotifier<List<AreaDto>> {
  @override
  Future<List<AreaDto>> build() async {
    return _fetchAreas();
  }

  Future<List<AreaDto>> _fetchAreas() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get('/api/v1/admin/areas', queryParameters: {'isActive': e_ActiveSearchStatus.active.value});
    final List data = response.data['data'] ?? [];
    return data.map((item) => AreaDto.fromJson(item)).toList();
  }

  Future<void> saveArea(AreaDto dto) async {
    final dio = ref.read(dioProvider);
    await dio.post('/api/v1/admin/area', data: {
      'id': dto.id,
      'areaCode': dto.areaCode,
      'organizationId': dto.organizationId,
      'locationId': dto.locationId,
      'areaName': dto.areaName,
      'description': dto.description,
      'isActive': dto.isActive,
    });
    ref.invalidateSelf();
  }
}

final processListProvider = AsyncNotifierProvider<ProcessListNotifier, List<ProcessDto>>(ProcessListNotifier.new);

class ProcessListNotifier extends AsyncNotifier<List<ProcessDto>> {
  @override
  Future<List<ProcessDto>> build() async {
    return _fetchProcesses();
  }

  Future<List<ProcessDto>> _fetchProcesses() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get('/api/v1/admin/processes', queryParameters: {'isActive': e_ActiveSearchStatus.active.value});
    final List data = response.data['data'] ?? [];
    return data.map((item) => ProcessDto.fromJson(item)).toList();
  }

  Future<void> saveProcess(ProcessDto dto) async {
    final dio = ref.read(dioProvider);
    await dio.post('/api/v1/admin/process', data: {
      'id': dto.id,
      'processCode': dto.processCode,
      'organizationId': dto.organizationId,
      'processName': dto.processName,
      'prefix': dto.prefix,
      'targetTATMinutes': dto.targetTATMinutes,
      'allowSubTokens': dto.allowSubTokens,
      'isActive': dto.isActive,
    });
    ref.invalidateSelf();
  }
}

// ============================================================================
// 5. STAGE 1 ADMIN MASTER WEB PANEL UI
// ============================================================================
class Stage1AdminPanelScreen extends ConsumerStatefulWidget {
  const Stage1AdminPanelScreen({super.key});

  @override
  ConsumerState<Stage1AdminPanelScreen> createState() => _Stage1AdminPanelScreenState();
}

class _Stage1AdminPanelScreenState extends ConsumerState<Stage1AdminPanelScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktopOrWeb = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('DQMS Admin Master Setup (Stage 1)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
      ),
      body: Row(
        children: [
          if (isDesktopOrWeb)
            NavigationRail(
              backgroundColor: const Color(0xFF161B22),
              selectedIndex: _selectedTabIndex,
              onDestinationSelected: (index) => setState(() => _selectedTabIndex = index),
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.location_city, color: Colors.blueAccent), label: Text('Areas / Zones')),
                NavigationRailDestination(icon: Icon(Icons.account_tree, color: Colors.blueAccent), label: Text('Process Pipelines')),
                NavigationRailDestination(icon: Icon(Icons.tv, color: Colors.blueAccent), label: Text('Display Templates')),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: const [
                AreaMasterView(),
                ProcessMasterView(),
                DisplayTemplateMasterView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AreaMasterView extends ConsumerWidget {
  const AreaMasterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areaState = ref.watch(areaListProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Area & Zone Hierarchy Masters', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add New Area'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: () => _showAddAreaDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: areaState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (areas) => ListView.builder(
                itemCount: areas.length,
                itemBuilder: (context, index) {
                  final area = areas[index];
                  return Card(
                    color: const Color(0xFF161B22),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.blueAccent.withOpacity(0.2), child: Text(area.areaCode, style: const TextStyle(color: Colors.blueAccent))),
                      title: Text(area.areaName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(area.description ?? 'Location ID: ${area.locationId}', style: const TextStyle(color: Colors.grey)),
                      trailing: Chip(
                        label: Text(area.isActive ? 'Active' : 'Deactive'),
                        backgroundColor: area.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        labelStyle: TextStyle(color: area.isActive ? Colors.green : Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAreaDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Create Area / Zone', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Area Code (e.g. Z-01)', labelStyle: TextStyle(color: Colors.grey)), style: const TextStyle(color: Colors.white)),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Area Name (e.g. Radiology Zone B)', labelStyle: TextStyle(color: Colors.grey)), style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(areaListProvider.notifier).saveArea(AreaDto(id: 0, areaCode: codeCtrl.text, organizationId: 1, locationId: 1, areaName: nameCtrl.text, isActive: true));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class ProcessMasterView extends ConsumerWidget {
  const ProcessMasterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processState = ref.watch(processListProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          const Text('Process Pipeline & SLA TAT Masters', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: processState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (processes) => ListView.builder(
                itemCount: processes.length,
                itemBuilder: (context, index) {
                  final proc = processes[index];
                  return Card(
                    color: const Color(0xFF161B22),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.purpleAccent.withOpacity(0.2), child: Text(proc.prefix, style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold))),
                      title: Text(proc.processName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('Target TAT: ${proc.targetTATMinutes} mins | Sub-Tokens: ${proc.allowSubTokens ? "Yes" : "No"}', style: const TextStyle(color: Colors.grey)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayTemplateMasterView extends StatelessWidget {
  const DisplayTemplateMasterView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Display Template Configuration View (GridView / Split-Screen)', style: TextStyle(color: Colors.grey)),
    );
  }
}
