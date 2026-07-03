import 'package:flutter/material.dart';
import '../theme.dart';
import '../state/app_state.dart';

/// PlusScreen — MINI+: тихая подписка. Список преимуществ и кнопка оформления,
/// которая переключает статус в AppState (в демке — бесплатно, мгновенно).
class PlusScreen extends StatelessWidget {
  const PlusScreen({super.key});

  static const _features = [
    ('Папки для чатов', 'Разложи разговоры по своим полкам.'),
    ('Тихие часы по расписанию', 'Уведомления замолкают сами.'),
    ('Больше реакций', 'Расширенный набор эмодзи под сообщения.'),
    ('Поддержка проекта', 'MINI живёт без рекламы и продажи данных.'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('MINI+', style: AppText.sans(17, weight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.rule),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 6),
              child: Text('Тихая подписка', style: AppText.sans(26, weight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
              child: Text('Немного удобства и поддержка проекта. Без шума.',
                  style: AppText.sans(14, color: AppColors.inkSoft)),
            ),
            Expanded(
              child: ListView(
                children: _features.map((f) => _FeatureRow(title: f.$1, subtitle: f.$2)).toList(),
              ),
            ),
            // Кнопка оформления / отмены — переключает статус MINI+.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: GestureDetector(
                onTap: app.togglePlus,
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: app.isPlus ? AppColors.field : AppColors.ink,
                    borderRadius: BorderRadius.circular(999),
                    border: app.isPlus ? Border.all(color: AppColors.rule) : null,
                  ),
                  child: Text(
                    app.isPlus ? 'Подписка активна · отключить' : 'Оформить бесплатно',
                    style: AppText.sans(15,
                        color: app.isPlus ? AppColors.ink : Colors.white, weight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// _FeatureRow — одна строка преимущества MINI+.
class _FeatureRow extends StatelessWidget {
  final String title, subtitle;
  const _FeatureRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 12),
            child: Icon(Icons.check_circle_outline, size: 20, color: AppColors.ink),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.sans(15.5, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppText.sans(13, color: AppColors.inkSoft, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
