import 'package:flutter/material.dart';

/// AppState — единый контейнер состояния приложения, живущего между экранами:
/// профиль, настройки, статус MINI+. Наследуемся от ChangeNotifier: когда данные
/// меняются, зовём notifyListeners() — и все подписанные виджеты перестраиваются.
///
/// Это «одно место правды» вместо разбросанных по экранам переменных.
class AppState extends ChangeNotifier {
  String userName;
  String userHandle;
  String userAbout;
  bool notifications;
  bool quietHours;
  bool isPlus;

  AppState({
    this.userName = 'Алекс',
    this.userHandle = '@alex',
    this.userAbout = 'Люблю тишину и хорошие шрифты.',
    this.notifications = true,
    this.quietHours = false,
    this.isPlus = false,
  });

  /// Первая буква имени — для аватара профиля.
  String get initials => userName.trim().isEmpty ? '?' : userName.trim().substring(0, 1).toUpperCase();

  /// Подпись статуса подписки для строки настроек.
  String get plusLabel => isPlus ? 'активна' : 'выключено';

  void setProfile({String? name, String? handle, String? about}) {
    if (name != null) userName = name;
    if (handle != null) userHandle = handle;
    if (about != null) userAbout = about;
    notifyListeners();
  }

  void setNotifications(bool v) { notifications = v; notifyListeners(); }
  void setQuietHours(bool v) { quietHours = v; notifyListeners(); }
  void togglePlus() { isPlus = !isPlus; notifyListeners(); }
}

/// AppScope — раздаёт AppState вниз по дереву виджетов через InheritedNotifier.
/// InheritedNotifier сам подписывается на ChangeNotifier: при notifyListeners()
/// перестраивает всех, кто читал состояние через AppScope.of(context).
///
/// Любой экран получает состояние одной строкой: final app = AppScope.of(context);
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope не найден выше по дереву');
    return scope!.notifier!;
  }
}
