import 'package:flutter/material.dart';
import '../theme.dart';

/// showMemberCard — карточка участника (нижняя панель): аватар, имя, @ник, «о себе».
/// Открывается по тапу на отправителя в группе или на шапку личного чата.
Future<void> showMemberCard(
  BuildContext context, {
  required String initials,
  required String name,
  required String handle,
  required bool online,
  required String bio,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60, height: 60, alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
                  child: Text(initials, style: AppText.sans(24, weight: FontWeight.w600)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppText.sans(19, weight: FontWeight.w700)),
                    Text(handle, style: AppText.sans(13, color: AppColors.inkFaint)),
                    if (online)
                      Text('в сети', style: AppText.sans(12, color: AppColors.online)),
                  ],
                ),
              ],
            ),
            if (bio.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(bio, style: AppText.sans(14, color: AppColors.inkSoft, height: 1.45)),
            ],
            const SizedBox(height: 18),
            // Кнопка «Написать» — в демке просто закрывает карточку.
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(999)),
                child: Text('Написать',
                    style: AppText.sans(15, color: Colors.white, weight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
