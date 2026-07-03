import 'package:flutter/material.dart';
import '../theme.dart';
import 'chat_list_screen.dart';
import 'settings_screen.dart';

/// HomeShell — каркас приложения после онбординга: две вкладки (Чаты / Настройки)
/// снизу. Stateful, потому что хранит выбранную вкладку.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0; // 0 — Чаты, 1 — Настройки

  // IndexedStack держит оба экрана «живыми» и просто показывает нужный —
  // так состояние вкладки (позиция скролла и т.п.) не сбрасывается при переключении.
  static const _screens = [ChatListScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.rule)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          backgroundColor: AppColors.paper,
          elevation: 0,
          selectedItemColor: AppColors.ink,
          unselectedItemColor: AppColors.inkFaint,
          selectedLabelStyle: AppText.sans(11, weight: FontWeight.w600),
          unselectedLabelStyle: AppText.sans(11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Чаты'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Настройки'),
          ],
        ),
      ),
    );
  }
}
