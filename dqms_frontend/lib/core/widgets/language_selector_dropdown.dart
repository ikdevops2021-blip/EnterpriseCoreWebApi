import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/localization/locale_provider.dart';

/// Reusable Glassmorphism Language Selector Dropdown
class LanguageSelectorDropdown extends ConsumerWidget {
  final bool showNativeName;

  const LanguageSelectorDropdown({
    super.key,
    this.showNativeName = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final activeCode = currentLocale.languageCode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: SupportedLanguages.all.any((l) => l.code == activeCode) ? activeCode : 'en',
          icon: const Icon(Icons.language_rounded, color: Colors.cyanAccent, size: 18),
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (String? newCode) {
            if (newCode != null) {
              ref.read(localeProvider.notifier).setLocale(newCode);
            }
          },
          items: SupportedLanguages.all.map<DropdownMenuItem<String>>((AppLanguage lang) {
            return DropdownMenuItem<String>(
              value: lang.code,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(lang.nativeName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (showNativeName && lang.name != lang.nativeName) ...[
                    const SizedBox(width: 6),
                    Text('(${lang.name})', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
