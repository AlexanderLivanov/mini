import 'package:flutter/material.dart';
import '../theme.dart';

/// SettingsSubScreen — универсальный раздел настроек (заглушка на будущее).
class SettingsSubScreen extends StatelessWidget {
  final String title;
  const SettingsSubScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text(title, style: AppText.sans(17, weight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.rule),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text('Раздел «$title» появится в следующей версии.',
              textAlign: TextAlign.center,
              style: AppText.sans(15, color: AppColors.inkSoft, height: 1.4)),
        ),
      ),
    );
  }
}
