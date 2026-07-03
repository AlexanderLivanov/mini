import 'package:flutter/material.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../widgets/settings_row.dart';
import 'profile_screen.dart';
import 'settings_sub_screen.dart';
import 'plus_screen.dart';

/// SettingsScreen — вкладка «Настройки»: шапка профиля, переключатели и разделы.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AppScope.of подписывает экран на состояние: тумблеры и статус MINI+
    // перерисуются сами при изменении.
    final app = AppScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Text('Настройки', style: AppText.sans(24, weight: FontWeight.w700)),
            ),
            _ProfileHeader(
              initials: app.initials,
              name: app.userName,
              handle: app.userHandle,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
            const Divider(height: 1, color: AppColors.rule),
            SettingsRow(
              title: 'Уведомления',
              subtitle: 'Звук и баннеры новых сообщений.',
              toggleValue: app.notifications,
              onToggle: app.setNotifications,
            ),
            SettingsRow(
              title: 'Тихие часы',
              subtitle: 'Уведомления сами замолкают по расписанию.',
              toggleValue: app.quietHours,
              onToggle: app.setQuietHours,
            ),
            SettingsRow(title: 'Внешний вид', onTap: () => _sub(context, 'Внешний вид')),
            SettingsRow(title: 'Приватность', onTap: () => _sub(context, 'Приватность')),
            SettingsRow(title: 'Данные и память', onTap: () => _sub(context, 'Данные и память')),
            const Divider(height: 1, color: AppColors.rule),
            SettingsRow(
              title: 'MINI+',
              subtitle: 'Тихая подписка',
              trailingText: app.plusLabel,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const PlusScreen())),
            ),
          ],
        ),
      ),
    );
  }

  void _sub(BuildContext c, String title) =>
      Navigator.push(c, MaterialPageRoute(builder: (_) => SettingsSubScreen(title: title)));
}

/// _ProfileHeader — верхняя строка настроек: аватар, имя, @ник, шеврон.
class _ProfileHeader extends StatelessWidget {
  final String initials, name, handle;
  final VoidCallback onTap;
  const _ProfileHeader(
      {required this.initials, required this.name, required this.handle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 52, height: 52, alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
              child: Text(initials, style: AppText.sans(20, weight: FontWeight.w600)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppText.sans(17, weight: FontWeight.w700)),
                  Text(handle, style: AppText.sans(13, color: AppColors.inkFaint)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.inkFaint, size: 22),
          ],
        ),
      ),
    );
  }
}
