import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

/// MessageBubble — «пузырь» одного сообщения плюс реакции под ним.
/// Моё:         тёмный фон, белый текст, справа, острый угол снизу-СПРАВА.
/// Собеседника: шалфейный фон, тёмный текст, слева, острый угол снизу-СЛЕВА.
class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;

    // Асимметричное скругление: три угла по kRadius, один — острый (4px).
    // Именно это придаёт пузырям «характер» из макета MINI.
    final radius = mine
        ? const BorderRadius.only(
            topLeft: Radius.circular(kRadius),
            topRight: Radius.circular(kRadius),
            bottomLeft: Radius.circular(kRadius),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(kRadius),
            topRight: Radius.circular(kRadius),
            bottomRight: Radius.circular(kRadius),
            bottomLeft: Radius.circular(4),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        // Пузырь и реакции прижимаем вправо (моё) или влево (чужое).
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Ограничиваем ширину пузыря 78% ширины экрана — как в оригинале.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: mine ? AppColors.ink : AppColors.sage,
                borderRadius: radius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text,
                      style: AppText.sans(15,
                          height: 1.42, color: mine ? Colors.white : AppColors.ink)),
                  const SizedBox(height: 3),
                  // Время — мелким, приглушённого цвета.
                  Text(message.time,
                      style: AppText.sans(10,
                          color: mine ? Colors.white70 : AppColors.inkFaint)),
                ],
              ),
            ),
          ),
          // Реакции под пузырём (если есть). Wrap переносит чипы на новую строку.
          if (message.reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                children: message.reactions
                    .map((r) => _ReactionChip(reaction: r))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// _ReactionChip — «чип» с эмодзи и счётчиком.
/// Если реакцию поставил я — чип тёмный; иначе — шалфейный.
class _ReactionChip extends StatelessWidget {
  final Reaction reaction;
  const _ReactionChip({required this.reaction});

  @override
  Widget build(BuildContext context) {
    final mine = reaction.mine;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: mine ? AppColors.ink : AppColors.sage,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('${reaction.emoji} ${reaction.count}',
          style: AppText.sans(11.5, color: mine ? Colors.white : AppColors.ink)),
    );
  }
}
