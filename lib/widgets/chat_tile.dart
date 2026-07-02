import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

/// ChatTile — одна строка списка чатов: аватар, имя, время, превью, бейдж.
class ChatTile extends StatelessWidget {
  final Chat chat;          // данные диалога для отрисовки
  final VoidCallback onTap; // колбэк — функция, вызываемая при нажатии на строку

  const ChatTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // InkWell делает область «нажимаемой» и рисует лёгкую рябь при тапе.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        child: Row(
          children: [
            _Avatar(initials: chat.initials, online: chat.online),
            const SizedBox(width: 13),
            // Expanded «растягивает» центральный блок, оставляя место аватару слева.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Верхняя строка: имя (слева, растянуто) + время (справа).
                  Row(
                    children: [
                      Expanded(
                        child: Text(chat.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.sans(16, weight: FontWeight.w600)),
                      ),
                      Text(chat.time,
                          style: AppText.sans(12, color: AppColors.inkFaint)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Нижняя строка: превью (слева) + бейдж непрочитанных (справа).
                  Row(
                    children: [
                      Expanded(
                        child: Text(chat.preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.sans(13.5, color: AppColors.inkSoft)),
                      ),
                      // Условная отрисовка: бейдж рисуем только если есть непрочитанные.
                      if (chat.unread > 0) _UnreadBadge(count: chat.unread),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// _Avatar — круг шалфейного цвета с инициалами и точкой «в сети».
/// Имя с "_" делает класс приватным — он виден только внутри этого файла.
class _Avatar extends StatelessWidget {
  final String initials;
  final bool online;
  const _Avatar({required this.initials, required this.online});

  @override
  Widget build(BuildContext context) {
    // Stack накладывает виджеты друг на друга — рисуем точку поверх круга.
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
            child: Text(initials, style: AppText.sans(19, weight: FontWeight.w600)),
          ),
          if (online)
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: AppColors.online,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.paper, width: 2.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// _UnreadBadge — тёмная «таблетка» с числом непрочитанных.
class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      // '$count' — строковая интерполяция: подставляем значение переменной в строку.
      child: Text('$count',
          style: AppText.sans(11.5, color: Colors.white, weight: FontWeight.w600)),
    );
  }
}
