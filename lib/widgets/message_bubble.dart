import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

/// DateSeparator — центрированная метка даты между блоками сообщений.
class DateSeparator extends StatelessWidget {
  final String label;
  const DateSeparator({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: AppText.sans(11.5, color: AppColors.inkSoft)),
      ),
    );
  }
}

/// SystemLine — служебная строка по центру (напр. «Вы отправили „толк"»).
class SystemLine extends StatelessWidget {
  final String text;
  const SystemLine({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(text,
            textAlign: TextAlign.center,
            style: AppText.sans(12, color: AppColors.inkFaint)),
      ),
    );
  }
}

/// MessageBubble — пузырь одного сообщения (текст/стикер/фото/видео) плюс реакции.
/// senderName != null для чужих сообщений в группе — рисуем имя над пузырём.
class MessageBubble extends StatelessWidget {
  final Message message;
  final String? senderName;
  const MessageBubble({super.key, required this.message, this.senderName});

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;

    // Асимметричное скругление: острый угол снизу-справа (моё) / снизу-слева (чужое).
    final radius = mine
        ? const BorderRadius.only(
            topLeft: Radius.circular(kRadius),
            topRight: Radius.circular(kRadius),
            bottomLeft: Radius.circular(kRadius),
            bottomRight: Radius.circular(4))
        : const BorderRadius.only(
            topLeft: Radius.circular(kRadius),
            topRight: Radius.circular(kRadius),
            bottomRight: Radius.circular(kRadius),
            bottomLeft: Radius.circular(4));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Имя отправителя в группе (только для чужих сообщений).
          if (senderName != null)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 2),
              child: Text(senderName!,
                  style: AppText.sans(11.5,
                      color: AppColors.inkSoft, weight: FontWeight.w600)),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78),
            child: _content(context, mine, radius),
          ),
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

  /// _content — выбирает отрисовку по типу сообщения.
  Widget _content(BuildContext context, bool mine, BorderRadius radius) {
    switch (message.kind) {
      case MsgKind.sticker:
        return _StickerTile(label: message.text);
      case MsgKind.photo:
        return _MediaTile(label: message.text, isVideo: false, radius: radius);
      case MsgKind.video:
        return _MediaTile(
            label: message.text,
            isVideo: true,
            duration: message.duration,
            radius: radius);
      case MsgKind.text:
      case MsgKind
            .system: // system сюда не попадает (рисуется через SystemLine)
        return _TextBubble(message: message, mine: mine, radius: radius);
    }
  }
}

/// _TextBubble — обычный текстовый пузырь со временем.
class _TextBubble extends StatelessWidget {
  final Message message;
  final bool mine;
  final BorderRadius radius;
  const _TextBubble(
      {required this.message, required this.mine, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
          color: mine ? AppColors.ink : AppColors.sage, borderRadius: radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.text,
              style: AppText.sans(15,
                  height: 1.42, color: mine ? Colors.white : AppColors.ink)),
          const SizedBox(height: 3),
          Text(message.time,
              style: AppText.sans(10,
                  color: mine ? Colors.white54 : AppColors.inkFaint)),
        ],
      ),
    );
  }
}

/// _StickerTile — «стикер»: рукописная подпись без тяжёлого фона (в духе MINI).
class _StickerTile extends StatelessWidget {
  final String label;
  const _StickerTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(kRadius),
      ),
      // Caveat придаёт стикеру «рукописную» лёгкость.
      child:
          Text('« $label »', style: AppText.logo(26, color: AppColors.inkSoft)),
    );
  }
}

/// _MediaTile — плитка-заглушка под фото/видео с подписью (реальных медиа в демке нет).
class _MediaTile extends StatelessWidget {
  final String label;
  final bool isVideo;
  final String? duration;
  final BorderRadius radius;
  const _MediaTile(
      {required this.label,
      required this.isVideo,
      this.duration,
      required this.radius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: 230,
        height: 150,
        color: AppColors.sage,
        child: Stack(
          children: [
            // Иконка по центру: «горы» для фото, «play» для видео.
            Center(
              child: Icon(
                  isVideo ? Icons.play_circle_outline : Icons.image_outlined,
                  size: 40,
                  color: AppColors.inkSoft),
            ),
            // Подпись снизу.
            Positioned(
              left: 10,
              bottom: 8,
              child: Text(label,
                  style: AppText.sans(12,
                      color: AppColors.ink, weight: FontWeight.w600)),
            ),
            // Бейдж длительности для видео.
            if (isVideo && duration != null)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(999)),
                  child: Text(duration!,
                      style: AppText.sans(10, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// _ReactionChip — «чип» реакции. Моя реакция — тёмная; чужая — светло-шалфейная.
class _ReactionChip extends StatelessWidget {
  final Reaction reaction;
  const _ReactionChip({required this.reaction});

  @override
  Widget build(BuildContext context) {
    final mine = reaction.mine;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: mine ? AppColors.ink : const Color(0xFFEFF3ED),
        borderRadius: BorderRadius.circular(999),
        border: mine ? null : Border.all(color: AppColors.rule),
      ),
      child: Text('${reaction.emoji} ${reaction.count}',
          style:
              AppText.sans(11.5, color: mine ? Colors.white : AppColors.ink)),
    );
  }
}
