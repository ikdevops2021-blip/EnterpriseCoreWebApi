import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';

/// Enterprise Color Picker Component powered by FlexColorPicker
class DqmsColorPicker extends StatefulWidget {
  final String label;
  final String initialHex;
  final ValueChanged<String> onColorChanged;
  final bool showSwatches;

  const DqmsColorPicker({
    super.key,
    required this.label,
    required this.initialHex,
    required this.onColorChanged,
    this.showSwatches = true,
  });

  /// Helper to safely convert hex string to Flutter Color
  static Color parseHex(String? hexString, {Color fallback = AppColors.brandPrimary}) {
    if (hexString == null || hexString.trim().isEmpty) return fallback;
    try {
      String clean = hexString.replaceAll('#', '').trim();
      if (clean.length == 6) {
        clean = 'FF$clean';
      } else if (clean.length == 3) {
        final r = clean[0];
        final g = clean[1];
        final b = clean[2];
        clean = 'FF$r$r$g$g$b$b';
      }
      return Color(int.parse(clean, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  /// Helper to convert Flutter Color to #RRGGBB hex string
  static String toHexString(Color color) {
    final argb = color.toARGB32();
    final rgb = argb & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  State<DqmsColorPicker> createState() => _DqmsColorPickerState();
}

class _DqmsColorPickerState extends State<DqmsColorPicker> {
  late String _currentHex;
  late TextEditingController _hexController;

  static final Map<ColorSwatch<int>, String> _customSwatches = <ColorSwatch<int>, String>{
    ColorTools.createPrimarySwatch(const Color(0xFF2F81F7)): 'Electric Blue',
    ColorTools.createPrimarySwatch(const Color(0xFF8957E5)): 'Deep Purple',
    ColorTools.createPrimarySwatch(const Color(0xFFDA3633)): 'Crimson Red',
    ColorTools.createPrimarySwatch(const Color(0xFFD29922)): 'Amber Orange',
    ColorTools.createPrimarySwatch(const Color(0xFF238636)): 'Forest Green',
    ColorTools.createPrimarySwatch(const Color(0xFF0969DA)): 'Cyan Ocean',
    ColorTools.createPrimarySwatch(const Color(0xFFBF3989)): 'Vibrant Pink',
  };

  @override
  void initState() {
    super.initState();
    _currentHex = widget.initialHex.isEmpty ? '#2F81F7' : widget.initialHex;
    _hexController = TextEditingController(text: _currentHex);
  }

  @override
  void didUpdateWidget(DqmsColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialHex != widget.initialHex) {
      _currentHex = widget.initialHex;
      _hexController.text = _currentHex;
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _updateHex(String hex) {
    setState(() {
      _currentHex = hex;
      _hexController.text = hex;
    });
    widget.onColorChanged(hex);
  }

  Future<void> _openFlexColorPickerDialog() async {
    final Color currentColor = DqmsColorPicker.parseHex(_currentHex);

    final bool isConfirmed = await ColorPicker(
      color: currentColor,
      onColorChanged: (Color color) {
        final newHex = DqmsColorPicker.toHexString(color);
        _updateHex(newHex);
      },
      width: 36,
      height: 36,
      borderRadius: 6,
      spacing: 6,
      runSpacing: 6,
      wheelDiameter: 185,
      wheelWidth: 14,
      wheelHasBorder: true,
      enableOpacity: false,
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      colorCodeHasColor: true,
      colorCodeTextStyle: const TextStyle(
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: AppColors.brandPrimary,
      ),
      heading: const Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: Text(
          'Select Primary Theme Swatch',
          style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
      subheading: const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text(
          'Select Color Tonal Shade',
          style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      wheelSubheading: const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text(
          'Custom Color Wheel & Spectrum',
          style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      recentColorsSubheading: const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child: Text(
          'Recently Selected Colors',
          style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      showRecentColors: true,
      maxRecentColors: 8,
      customColorSwatchesAndNames: _customSwatches,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        copyButton: true,
        pasteButton: true,
        longPressMenu: true,
      ),
    ).showPickerDialog(
      context,
      backgroundColor: AppColors.bgSurface,
      elevation: 8,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      constraints: const BoxConstraints(minWidth: 460, minHeight: 520, maxWidth: 520),
      title: const Row(
        children: [
          Icon(Icons.palette_rounded, color: AppColors.brandPrimary, size: 22),
          SizedBox(width: 8),
          Text(
            'FlexColorPicker — Color Selector',
            style: TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    if (!isConfirmed) {
      // Revert if cancelled
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = DqmsColorPicker.parseHex(_currentHex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.color_lens_rounded, size: 14),
              label: const Text('Open Color Picker', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              onPressed: _openFlexColorPickerDialog,
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            // FlexColorPicker ColorIndicator Box (Clickable)
            Tooltip(
              message: 'Click to launch FlexColorPicker dialog',
              child: InkWell(
                onTap: _openFlexColorPickerDialog,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      ColorIndicator(
                        width: 36,
                        height: 36,
                        borderRadius: 6,
                        color: currentColor,
                        hasBorder: true,
                        borderColor: Colors.white54,
                        elevation: 2,
                        onSelect: () => _openFlexColorPickerDialog(),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Hex Code Input Field
            Expanded(
              child: DqmsTextField(
                controller: _hexController,
                prefixIcon: const Icon(Icons.tag_rounded, size: 16, color: AppColors.brandPrimary),
                hintText: '#2F81F7',
                onChanged: (val) {
                  setState(() => _currentHex = val);
                  widget.onColorChanged(val);
                },
              ),
            ),
          ],
        ),

        if (widget.showSwatches) ...[
          const SizedBox(height: 10),
          // FlexColorPicker Swatch Palette Bar
          ColorPicker(
            color: currentColor,
            onColorChanged: (Color color) {
              final newHex = DqmsColorPicker.toHexString(color);
              _updateHex(newHex);
            },
            width: 24,
            height: 24,
            borderRadius: 12,
            spacing: 6,
            runSpacing: 6,
            enableOpacity: false,
            showMaterialName: false,
            showColorName: false,
            showColorCode: false,
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.both: false,
              ColorPickerType.primary: true,
              ColorPickerType.accent: false,
              ColorPickerType.bw: false,
              ColorPickerType.custom: true,
              ColorPickerType.wheel: false,
            },
            customColorSwatchesAndNames: _customSwatches,
          ),
        ],
      ],
    );
  }
}
