import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/admin/screens/admin_panel_screen.dart';

void main() {
  runApp(const ProviderScope(child: DqmsApp()));
}

class DqmsApp extends StatelessWidget {
  const DqmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DQMS - Digital Queue Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorSchemeSeed: const Color(0xFF58A6FF),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      home: const AdminPanelScreen(),
    );
  }
}
