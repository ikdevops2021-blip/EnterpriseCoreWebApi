import 'package:flutter/material.dart';
import 'package:universal_printer/universal_printer.dart';

/// Simple bottom‑sheet UI for selecting the thermal roll width.
class PrinterSettingsSheet extends StatefulWidget {
  const PrinterSettingsSheet({Key? key}) : super(key: key);

  @override
  State<PrinterSettingsSheet> createState() => _PrinterSettingsSheetState();
}

class _PrinterSettingsSheetState extends State<PrinterSettingsSheet> {
  late PrinterConfig _config;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final repo = PrinterConfigRepository();
    final cfg = await repo.load();
    setState(() {
      _config = cfg;
      _loading = false;
    });
  }

  Future<void> _saveConfig(PrinterConfig cfg) async {
    final repo = PrinterConfigRepository();
    await repo.save(cfg);
    setState(() => _config = cfg);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Thermal Roll Width', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          RadioListTile<PrinterMode>(
            title: const Text('58 mm Roll'),
            value: PrinterMode.thermal58,
            groupValue: _config.mode,
            onChanged: (v) => _onModeChanged(v!),
          ),
          RadioListTile<PrinterMode>(
            title: const Text('80 mm Roll'),
            value: PrinterMode.thermal80,
            groupValue: _config.mode,
            onChanged: (v) => _onModeChanged(v!),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onModeChanged(PrinterMode mode) async {
    final newCfg = PrinterConfig(
      mode: mode,
      connectionType: _config.connectionType,
      ipAddress: _config.ipAddress,
      port: _config.port,
    );
    await _saveConfig(newCfg);
  }
}
