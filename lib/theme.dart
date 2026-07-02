import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Дизайн-токены MINI. В исходном HTML это CSS-переменные:
///   --mini-c    = #1A1A1A  (контраст / «чернила»)
///   --mini-p    = #E8EDE6  (пастель / шалфейный акцент)
///   --mini-r    = 18px     (радиус скругления)
///   --mini-hand = Caveat   (рукописный шрифт логотипа)
/// Переносим их в Dart как обычные константы.
///
/// Приём Dart: класс с одними статическими полями = «пространство имён» для
/// констант. Приватный конструктор AppColors._() запрещает создавать объект —
/// классом пользуются только на чтение: AppColors.ink и т.д.
class AppColors {
  AppColors._();

  static const Color ink    = Color(0xFF1A1A1A); // основной текст и «мои» пузыри
  static const Color sage   = Color(0xFFE8EDE6); // акцент: аватары, входящие пузыри
  static const Color paper  = Color(0xFFFFFFFF); // поверхности (фон экранов)
  static const Color online = Color(0xFF3BA55D); // зелёная точка «в сети»

  // Приглушённые оттенки чернил. В HTML это color-mix(ink % + white);
  // здесь — заранее посчитанные близкие значения (sRGB-приближение).
  static const Color inkSoft  = Color(0xFF7E7E7C); // ~55% — превью, статусы
  static const Color inkFaint = Color(0xFF9A9A97); // ~45% — время, подписи
  static const Color hint     = Color(0xFFB6B6B2); // плейсхолдеры полей
  static const Color rule     = Color(0xFFECEBE8); // тонкие линии-разделители
  static const Color field    = Color(0xFFF3F5F2); // фон полей ввода/поиска
}

/// Единый радиус скругления пузырей и карточек (--mini-r).
const double kRadius = 18;

/// AppText — типографика. В MINI один рукописный акцент (Caveat) для логотипа,
/// всё остальное — системный гротеск (на iOS San Francisco, на Android Roboto).
class AppText {
  AppText._();

  /// Рукописный логотип «MINI» — единственное место с Caveat.
  static TextStyle logo(double size, {Color? color}) => GoogleFonts.caveat(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1,
        color: color ?? AppColors.ink,
      );

  /// Обычный текст интерфейса и сообщений системным шрифтом.
  static TextStyle sans(double size,
          {Color? color, FontWeight weight = FontWeight.w400, double height = 1.3}) =>
      TextStyle(
        fontSize: size,
        color: color ?? AppColors.ink,
        fontWeight: weight,
        height: height,
      );
}
