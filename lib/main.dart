import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/chat_list_screen.dart';

/// main() — точка входа любого Dart-приложения: систему запускает именно её.
/// runApp() «монтирует» корневой виджет в дерево и запускает отрисовку.
void main() => runApp(const MiniApp());

/// MiniApp — корневой виджет приложения.
/// StatelessWidget = виджет без изменяемого состояния: рисуется по входным данным.
class MiniApp extends StatelessWidget {
  const MiniApp({super.key});

  /// build() — «функция отрисовки». Flutter вызывает её, чтобы получить UI.
  /// MaterialApp даёт навигацию, тему и базовую механику приложения.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MINI',
      debugShowCheckedModeBanner: false, // убрать красную ленту "DEBUG"
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.ink,
          primary: AppColors.ink,
        ),
        useMaterial3: true,
      ),
      home: const ChatListScreen(), // первый экран — список чатов
    );
  }
}
