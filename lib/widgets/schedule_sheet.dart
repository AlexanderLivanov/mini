import 'package:flutter/material.dart';
import '../theme.dart';

/// showScheduleSheet — «письмо в будущее»: выбор, когда отправить. Возвращает
/// подпись выбранного времени (или null). Фича-подпись MINI: отложенная отправка.
Future<String?> showScheduleSheet(BuildContext context) {
  const options = ['Через час', 'Сегодня вечером', 'Завтра утром', 'Через неделю'];
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
            child: Text('Письмо в будущее', style: AppText.sans(17, weight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Text('Сообщение уйдёт само в выбранное время.',
                style: AppText.sans(13, color: AppColors.inkSoft)),
          ),
          ...options.map((o) => InkWell(
                onTap: () => Navigator.pop(context, o),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 19, color: AppColors.ink),
                      const SizedBox(width: 12),
                      Text(o, style: AppText.sans(15)),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
