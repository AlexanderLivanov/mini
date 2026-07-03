import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

/// ChatTile — строка списка чатов: аватар, значок типа, имя, время, превью, бейдж.
class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  const ChatTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        child: Row(
          children: [
            _Avatar(chat: chat),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Значок группы/канала перед именем (📢 / 👥).
                      if (chat.badge.isNotEmpty) ...[
                        Text(chat.badge, style: AppText.sans(11, color: AppColors.inkFaint)),
                        const SizedBox(width: 5),
                      ],
                      Expanded(
                        child: Text(chat.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: AppText.sans(16, weight: FontWeight.w600)),
                      ),
                      Text(chat.time, style: AppText.sans(12, color: AppColors.inkFaint)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(chat.preview,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: AppText.sans(13.5, color: AppColors.inkSoft)),
                      ),
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

/// _Avatar — шалфейный аватар: круг для личных чатов, скруглённый квадрат для
/// групп и каналов. Зелёная точка — только у личных чатов «в сети».
class _Avatar extends StatelessWidget {
  final Chat chat;
  const _Avatar({required this.chat});

  @override
  Widget build(BuildContext context) {
    // Форма: DM — круг (радиус 27 = половина от 54); группа/канал — скругление 16.
    final shape = chat.roundedAvatar
        ? BorderRadius.circular(16)
        : BorderRadius.circular(27);

    return SizedBox(
      width: 54, height: 54,
      child: Stack(
        children: [
          Container(
            width: 54, height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.sage, borderRadius: shape),
            child: Text(chat.initials, style: AppText.sans(19, weight: FontWeight.w600)),
          ),
          if (chat.isDM && chat.online)
            Positioned(
              right: 1, bottom: 1,
              child: Container(
                width: 13, height: 13,
                decoration: BoxDecoration(
                  color: AppColors.online, shape: BoxShape.circle,
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
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(999)),
      child: Text('$count',
          style: AppText.sans(11.5, color: Colors.white, weight: FontWeight.w600)),
    );
  }
}
