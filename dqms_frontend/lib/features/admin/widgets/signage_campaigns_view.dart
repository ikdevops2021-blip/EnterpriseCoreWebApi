import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/signage_models.dart';
import '../providers/signage_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import 'master_detail_layout.dart';

/// ============================================================================
/// DIGITAL SIGNAGE & EMERGENCY BROADCAST ADMIN VIEW
/// Console for managing promotional/health campaigns, playlists, and triggering
/// instant high-priority emergency alerts across waiting room TV monitors.
/// ============================================================================
class SignageCampaignsView extends ConsumerStatefulWidget {
  const SignageCampaignsView({super.key});

  @override
  ConsumerState<SignageCampaignsView> createState() => _SignageCampaignsViewState();
}

class _SignageCampaignsViewState extends ConsumerState<SignageCampaignsView> {
  SignageCampaign? _selectedCampaign;

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(signageCampaignsProvider);
    final emergencyAsync = ref.watch(activeEmergencyProvider(1));
    final emergency = emergencyAsync.value;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Emergency Active Override Banner
          if (emergency != null && emergency.isActive)
            _buildActiveEmergencyBanner(emergency),

          // Main Header Bar
          _buildHeader(emergency),

          // Main Body
          Expanded(
            child: campaignsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
              data: (campaigns) {
                if (_selectedCampaign == null && campaigns.isNotEmpty) {
                  _selectedCampaign = campaigns.first;
                }

                return MasterDetailLayout(
                  masterWidget: _buildCampaignsList(campaigns),
                  detailTitle: 'Campaign Inspector',
                  detailWidget: _selectedCampaign != null
                      ? _buildCampaignDetail(_selectedCampaign!)
                      : const Center(
                          child: Text(
                            'Select a campaign from the list or create a new one',
                            style: TextStyle(color: AppColors.textSubtle),
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

  Widget _buildActiveEmergencyBanner(EmergencyBroadcast alert) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFD50000),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚨 ACTIVE EMERGENCY BROADCAST: ${alert.title.toUpperCase()} (${alert.broadcastCode})',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                ),
                Text(
                  alert.messageText.isNotEmpty ? alert.messageText : 'Lobby screens are overridden with emergency instructions.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('CANCEL BROADCAST (ALL CLEAR)', style: TextStyle(fontWeight: FontWeight.w900)),
            onPressed: () async {
              final ok = await ref.read(activeEmergencyProvider(1).notifier).dismissEmergency(alert.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Emergency dismissed. All Clear.' : 'Failed to dismiss alert.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(EmergencyBroadcast? emergency) {
    final isEmergencyActive = emergency != null && emergency.isActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        color: AppColors.bgHeader,
        border: Border(bottom: BorderSide(color: AppColors.glassBorderLight)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.campaign_rounded, color: AppColors.cyanGlow, size: 24),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Digital Signage & Emergency Broadcast',
                style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              Text(
                'Manage TV waiting room media playlists, schedule slots & life-safety broadcast overlays',
                style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),

          // Emergency Broadcast Panic Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isEmergencyActive ? Colors.grey.shade800 : const Color(0xFFFF1744),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            icon: const Icon(Icons.warning_rounded, size: 18),
            label: Text(
              isEmergencyActive ? 'BROADCAST ACTIVE' : 'EMERGENCY BROADCAST',
              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
            ),
            onPressed: isEmergencyActive ? null : () => _showEmergencyDialog(context),
          ),
          const SizedBox(width: 12),

          // Create Campaign Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cyanGlow,
              side: const BorderSide(color: AppColors.cyanGlow),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Campaign', style: TextStyle(fontWeight: FontWeight.w800)),
            onPressed: () => _showCreateCampaignDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsList(List<SignageCampaign> campaigns) {
    if (campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_remove_rounded, size: 48, color: AppColors.textSubtle.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text('No digital signage campaigns found', style: TextStyle(color: AppColors.textSubtle)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showCreateCampaignDialog(context),
              child: const Text('Create First Campaign'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: campaigns.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final c = campaigns[i];
        final isSelected = _selectedCampaign?.id == c.id;

        return InkWell(
          onTap: () => setState(() => _selectedCampaign = c),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.15) : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? AppColors.cyanGlow : AppColors.glassBorderLight,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.campaignName,
                        style: TextStyle(
                          color: isSelected ? AppColors.cyanGlow : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: c.isActive ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: c.isActive ? Colors.green : Colors.grey),
                      ),
                      child: Text(
                        c.isActive ? 'ACTIVE' : 'INACTIVE',
                        style: TextStyle(
                          color: c.isActive ? Colors.green : Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade300),
                    const SizedBox(width: 4),
                    Text('Priority ${c.priority}', style: const TextStyle(color: AppColors.textSubtle, fontSize: 12)),
                    const SizedBox(width: 14),
                    const Icon(Icons.slideshow_rounded, size: 14, color: AppColors.cyanGlow),
                    const SizedBox(width: 4),
                    Text('${c.mediaItems.length} Slides', style: const TextStyle(color: AppColors.textSubtle, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Valid: ${c.startDate.year}-${c.startDate.month.toString().padLeft(2, '0')}-${c.startDate.day.toString().padLeft(2, '0')} to ${c.endDate.year}-${c.endDate.month.toString().padLeft(2, '0')}-${c.endDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCampaignDetail(SignageCampaign c) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detail Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.campaignName,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Campaign ID: #${c.id} • Target Location: ${c.locationId ?? "All Branches"}',
                      style: const TextStyle(color: AppColors.textSubtle, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                tooltip: 'Delete Campaign',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Campaign?'),
                      content: Text('Are you sure you want to remove "${c.campaignName}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await ref.read(signageCampaignsProvider.notifier).deleteCampaign(c.id);
                    setState(() => _selectedCampaign = null);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.glassBorderLight),
          const SizedBox(height: 14),

          // Playlist Items Section Header
          Row(
            children: [
              const Icon(Icons.video_library_rounded, color: AppColors.cyanGlow, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Media Playlist Slides',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary.withValues(alpha: 0.3),
                  foregroundColor: AppColors.cyanGlow,
                  side: const BorderSide(color: AppColors.cyanGlow),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Slide', style: TextStyle(fontSize: 12)),
                onPressed: () => _showAddMediaDialog(context, c),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Playlist Items List
          Expanded(
            child: c.mediaItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 40, color: AppColors.textSubtle.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        const Text('No media slides configured yet.', style: TextStyle(color: AppColors.textSubtle)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: c.mediaItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final item = c.mediaItems[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.glassSurfaceDark,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.glassBorderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Center(
                                child: Text(
                                  '#${item.displayOrder}',
                                  style: const TextStyle(color: AppColors.cyanGlow, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    item.mediaUrl,
                                    style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.glassBorderLight,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                '${item.durationSeconds}s',
                                style: const TextStyle(color: AppColors.cyanGlow, fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCreateCampaignDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    int priority = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: const Text('Create Signage Campaign', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Campaign Name',
                  labelStyle: TextStyle(color: AppColors.cyanGlow),
                  hintText: 'e.g. Winter Health Advisories',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Priority (1-10): ', style: TextStyle(color: Colors.white)),
                  DropdownButton<int>(
                    value: priority,
                    dropdownColor: AppColors.bgSurface,
                    items: List.generate(10, (i) => i + 1)
                        .map((val) => DropdownMenuItem(value: val, child: Text('$val', style: const TextStyle(color: Colors.white))))
                        .toList(),
                    onChanged: (val) => setDlgState(() => priority = val ?? 5),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await ref.read(signageCampaignsProvider.notifier).saveCampaign({
                  'campaignName': nameCtrl.text.trim(),
                  'organizationId': 1,
                  'locationId': 1,
                  'priority': priority,
                  'startDate': DateTime.now().toIso8601String(),
                  'endDate': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
                  'isActive': true,
                  'mediaItems': [
                    {
                      'title': 'Welcome Slide',
                      'mediaType': 1,
                      'mediaUrl': 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=1200',
                      'durationSeconds': 15,
                    }
                  ],
                });
              },
              child: const Text('Save Campaign'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMediaDialog(BuildContext context, SignageCampaign campaign) {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    int duration = 15;
    int mediaType = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text('Add Media Slide to ${campaign.campaignName}', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Slide Title',
                  labelStyle: TextStyle(color: AppColors.cyanGlow),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Media Stream / Image URL',
                  labelStyle: TextStyle(color: AppColors.cyanGlow),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text('Type: ', style: TextStyle(color: Colors.white)),
                  DropdownButton<int>(
                    value: mediaType,
                    dropdownColor: AppColors.bgSurface,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Image Slide', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 2, child: Text('Video Clip', style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (val) => setDlgState(() => mediaType = val ?? 1),
                  ),
                  const Spacer(),
                  const Text('Dwell: ', style: TextStyle(color: Colors.white)),
                  DropdownButton<int>(
                    value: duration,
                    dropdownColor: AppColors.bgSurface,
                    items: [10, 15, 20, 30, 60]
                        .map((d) => DropdownMenuItem(value: d, child: Text('${d}s', style: const TextStyle(color: Colors.white))))
                        .toList(),
                    onChanged: (val) => setDlgState(() => duration = val ?? 15),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);

                final updatedItems = List<SignageMediaItem>.from(campaign.mediaItems)
                  ..add(SignageMediaItem(
                    id: 0,
                    campaignId: campaign.id,
                    mediaType: mediaType,
                    mediaUrl: urlCtrl.text.trim(),
                    title: titleCtrl.text.trim(),
                    durationSeconds: duration,
                    displayOrder: campaign.mediaItems.length + 1,
                  ));

                await ref.read(signageCampaignsProvider.notifier).saveCampaign({
                  'id': campaign.id,
                  'campaignName': campaign.campaignName,
                  'organizationId': campaign.organizationId,
                  'locationId': campaign.locationId,
                  'priority': campaign.priority,
                  'startDate': campaign.startDate.toIso8601String(),
                  'endDate': campaign.endDate.toIso8601String(),
                  'isActive': campaign.isActive,
                  'mediaItems': updatedItems.map((e) => e.toJson()).toList(),
                });
              },
              child: const Text('Add Slide'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    String selectedCode = 'CODE_RED';
    final titleCtrl = TextEditingController(text: 'FIRE EVACUATION IN PROGRESS');
    final msgCtrl = TextEditingController(text: 'Evacuate immediately via Stairwell B. Do not use elevators.');
    final pinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1E0A0E),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text('TRIGGER EMERGENCY BROADCAST', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This will immediately take over all waiting room displays, sound sirens, and suspend token calls.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCode,
                  dropdownColor: AppColors.bgSurface,
                  decoration: const InputDecoration(labelText: 'Emergency Protocol', labelStyle: TextStyle(color: Colors.redAccent)),
                  items: const [
                    DropdownMenuItem(value: 'CODE_RED', child: Text('Code Red: Fire / Evacuation', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'CODE_BLUE', child: Text('Code Blue: Cardiac / Medical Alert', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'WEATHER', child: Text('Severe Weather / Tornado', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'LOCKDOWN', child: Text('Security Lockdown', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'CUSTOM', child: Text('Custom Alert', style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDlgState(() {
                        selectedCode = val;
                        if (val == 'CODE_RED') {
                          titleCtrl.text = 'FIRE EVACUATION IN PROGRESS';
                          msgCtrl.text = 'Evacuate immediately via Stairwell B. Do not use elevators.';
                        } else if (val == 'CODE_BLUE') {
                          titleCtrl.text = 'CODE BLUE - MEDICAL EMERGENCY';
                          msgCtrl.text = 'Resuscitation team required at Main Lobby Station 2 immediately.';
                        } else if (val == 'WEATHER') {
                          titleCtrl.text = 'SEVERE WEATHER ALERT';
                          msgCtrl.text = 'Tornado warning in effect. Proceed immediately to lower level shelter.';
                        } else if (val == 'LOCKDOWN') {
                          titleCtrl.text = 'FACILITY LOCKDOWN ACTIVE';
                          msgCtrl.text = 'Shelter in place immediately. Close and lock all corridor doors.';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Banner Headline', labelStyle: TextStyle(color: Colors.redAccent)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: msgCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Actionable Instructions', labelStyle: TextStyle(color: Colors.redAccent)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pinCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace', letterSpacing: 3),
                  decoration: const InputDecoration(
                    labelText: 'Confirm PIN (1234)',
                    labelStyle: TextStyle(color: Colors.amber),
                    hintText: 'Enter safety PIN',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF1744)),
              onPressed: () async {
                if (pinCtrl.text.trim() != '1234') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid Safety PIN. Broadcast aborted.')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final ok = await ref.read(activeEmergencyProvider(1).notifier).triggerEmergency({
                  'organizationId': 1,
                  'locationId': 1,
                  'broadcastCode': selectedCode,
                  'title': titleCtrl.text.trim(),
                  'messageText': msgCtrl.text.trim(),
                  'severity': 3,
                  'audioSirenType': 1,
                  'flashColorHex': '#FF1744',
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? 'EMERGENCY BROADCAST ACTIVATED!' : 'Failed to trigger emergency.')),
                  );
                }
              },
              child: const Text('CONFIRM & BROADCAST', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}
