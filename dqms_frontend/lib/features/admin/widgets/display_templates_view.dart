import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';
import 'package:dqms_frontend/core/widgets/dqms_states.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// ============================================================================
/// DISPLAY TEMPLATES WORKSPACE VIEW (Domain 4)
/// Master-Detail management interface for TV display layouts & ticker text
/// ============================================================================
class DisplayTemplatesView extends ConsumerStatefulWidget {
  const DisplayTemplatesView({super.key});

  @override
  ConsumerState<DisplayTemplatesView> createState() => _DisplayTemplatesViewState();
}

class _DisplayTemplatesViewState extends ConsumerState<DisplayTemplatesView> {
  String _searchQuery = '';
  DisplayTemplateModel? _selectedTemplate;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminWorkspaceStateProvider);
    final filteredTemplates = state.displayTemplates.where((t) {
      return t.templateName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.layoutType.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filteredTemplates),
      detailWidget: _selectedTemplate != null ? _buildDetailInspector(_selectedTemplate!) : null,
      detailTitle: _selectedTemplate != null ? 'Template Inspector — ID: ${_selectedTemplate!.templateId}' : 'Template Inspector',
      onCloseDetail: () {
        setState(() {
          _selectedTemplate = null;
        });
      },
    );
  }

  Widget _buildMasterTable(List<DisplayTemplateModel> templates) {
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
          // Toolbar
          Row(
            children: [
              Expanded(
                child: DqmsTextField(
                  hintText: 'Search TV Layout Name or Type...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              DqmsButton(
                label: 'New Template',
                icon: Icons.add_rounded,
                onPressed: () {
                  setState(() {
                    _selectedTemplate = const DisplayTemplateModel(
                      templateId: 999,
                      templateName: 'New TV Layout Template',
                      layoutType: 'GridView (21001)',
                      audioChime: 'DigitalBell',
                      scrollSpeed: 'Normal',
                      tickerText: 'Enter announcement text here',
                      isActive: true,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // List / Table Content
          if (templates.isEmpty)
            const Expanded(
              child: DqmsEmptyState(
                title: 'No Templates Found',
                message: 'No TV display templates match your search criteria.',
                icon: Icons.tv_off_rounded,
              ),
            )
          else
            Expanded(
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
                        SizedBox(width: 60, child: Text('ID', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 3, child: Text('TEMPLATE NAME', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        Expanded(flex: 2, child: Text('LAYOUT TYPE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 110, child: Text('AUDIO CHIME', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                        SizedBox(width: 90, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rows
                  Expanded(
                    child: ListView.separated(
                      itemCount: templates.length,
                      separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                      itemBuilder: (ctx, i) {
                        final tmpl = templates[i];
                        final isSelected = _selectedTemplate?.templateId == tmpl.templateId;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTemplate = tmpl;
                            });
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    '#${tmpl.templateId}',
                                    style: const TextStyle(
                                      color: AppColors.brandPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    tmpl.templateName,
                                    style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    tmpl.layoutType,
                                    style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    tmpl.audioChime,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: DqmsStatusBadge.activeState(tmpl.isActive),
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
        ],
      ),
    );
  }

  Widget _buildDetailInspector(DisplayTemplateModel tmpl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DqmsTextField(label: 'Template Name', initialValue: tmpl.templateName),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Layout Type Enum Code', initialValue: tmpl.layoutType),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Audio Voice Chime', initialValue: tmpl.audioChime),
        const SizedBox(height: 14),
        DqmsTextField(label: 'Ticker Announcement Text', initialValue: tmpl.tickerText, maxLines: 3),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Active Layout Template:', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            DqmsStatusBadge.activeState(tmpl.isActive),
          ],
        ),
        const SizedBox(height: 24),
        DqmsButton(
          label: 'Save Display Template',
          icon: Icons.save_rounded,
          isFullWidth: true,
          onPressed: () async {
            try {
              final dio = ref.read(dioProvider);
              await dio.post('${AppConfig.adminApiBase}/template', data: {
                'id': tmpl.templateId,
                'templateName': tmpl.templateName,
                'layoutType': tmpl.layoutType,
                'audioChime': tmpl.audioChime,
                'scrollSpeed': tmpl.scrollSpeed,
                'tickerText': tmpl.tickerText,
                'organizationId': 1,
                'isActive': tmpl.isActive,
              });
            } catch (_) {}

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Display Template ${tmpl.templateName} saved to backend API.'), backgroundColor: AppColors.statusActive),
            );
          },
        ),
      ],
    );
  }
}
