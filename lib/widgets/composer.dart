import 'package:flutter/material.dart';
import '../theme.dart';

/// Composer — нижняя панель ввода: кнопка-напоминание (nudge), поле ввода,
/// «письмо в будущее» (schedule) и кнопка отправки.
/// В демке полностью работает отправка; nudge и schedule — заглушки-«характер MINI».
class Composer extends StatelessWidget {
  final TextEditingController controller; // «пульт» поля ввода
  final VoidCallback onSend;              // отправить сообщение
  final VoidCallback onNudge;             // мягкое напоминание
  final VoidCallback onSchedule;          // отложенная отправка

  const Composer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onNudge,
    required this.onSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.rule)),
      ),
      // SafeArea уводит панель выше «домашней полоски» на iPhone без кнопки Home.
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              // Круглая кнопка-«колокольчик» (nudge).
              _CircleButton(
                onTap: onNudge,
                child: const Icon(Icons.notifications_none, size: 20, color: AppColors.ink),
              ),
              const SizedBox(width: 8),
              // Поле ввода-«таблетка».
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppText.sans(15),
                  cursorColor: AppColors.ink,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(), // Enter на клавиатуре тоже отправляет
                  decoration: InputDecoration(
                    hintText: 'Сообщение',
                    hintStyle: AppText.sans(15, color: AppColors.hint),
                    filled: true,
                    fillColor: AppColors.field,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999), // полностью скруглённое
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // «Письмо в будущее» — отложенная отправка.
              _CircleButton(
                onTap: onSchedule,
                child: const Icon(Icons.schedule, size: 19, color: AppColors.ink),
              ),
              const SizedBox(width: 8),
              // Кнопка отправки — тёмный круг с белой стрелкой.
              GestureDetector(
                onTap: onSend,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_upward, size: 19, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// _CircleButton — круглая кнопка с тонкой обводкой (nudge / schedule).
class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _CircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.rule),
        ),
        child: child,
      ),
    );
  }
}
