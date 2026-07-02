import 'package:flutter/material.dart';
import '../theme.dart';

/// TypingIndicator — шалфейный пузырь с тремя «прыгающими» точками.
/// Это StatefulWidget, потому что точки анимируются во времени
/// (в макете это CSS @keyframes miniDot).
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  // createState() связывает виджет с его изменяемым состоянием.
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

// SingleTickerProviderStateMixin даёт «тикер» — источник кадров для анимации.
class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  /// initState() вызывается один раз при создании — удобно для инициализации.
  @override
  void initState() {
    super.initState();
    // Контроллер гоняет значение 0→1 за 1.1с и повторяет бесконечно.
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  /// dispose() вызывается при закрытии — обязательно освобождаем анимацию.
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// _dy() — вертикальный сдвиг точки №i в текущий момент.
  /// У каждой точки своя фаза, поэтому они «прыгают» по очереди волной.
  double _dy(int i) {
    final phase = (_c.value - i * 0.15) % 1.0;
    final double lift = phase < 0.3
        ? (phase / 0.3)                     // вверх
        : (phase < 0.6 ? (1 - (phase - 0.3) / 0.3) : 0.0); // вниз, затем покой
    return -4 * lift;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: const BoxDecoration(
          color: AppColors.sage,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(kRadius),
            topRight: Radius.circular(kRadius),
            bottomRight: Radius.circular(kRadius),
            bottomLeft: Radius.circular(4),
          ),
        ),
        // AnimatedBuilder перестраивает только точки на каждом кадре анимации.
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.translate(
                  offset: Offset(0, _dy(i)),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
