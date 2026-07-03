import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/mock_data.dart';

/// showReactionPicker — показывает нижнюю панель с эмодзи (❤️👍🔥😂👀) и возвращает
/// выбранный эмодзи (или null, если закрыли). Вызывается по долгому нажатию на пузырь.
Future<String?> showReactionPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: reactionSet.map((e) {
            return GestureDetector(
              // Возвращаем выбранный эмодзи вызывающему коду через Navigator.pop.
              onTap: () => Navigator.pop(context, e),
              child: Container(
                width: 52, height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(e, style: const TextStyle(fontSize: 26)),
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}
