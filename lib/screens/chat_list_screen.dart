import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/mock_data.dart';
import '../widgets/chat_tile.dart';
import 'conversation_screen.dart';

/// ChatListScreen — экран «Чаты»: рукописный логотип, поиск и список диалогов.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea отступает от «чёлки» и системных зон iPhone.
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Логотип «MINI» рукописным Caveat.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Text('MINI', style: AppText.logo(36)),
            ),
            // Поле поиска — «таблетка» (в демке визуальная, без логики).
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: _SearchPill(),
            ),
            // Список чатов занимает всё оставшееся место по вертикали.
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                itemCount: mockChats.length,        // сколько строк построить
                itemBuilder: (context, index) {     // как построить строку №index
                  final chat = mockChats[index];
                  return ChatTile(
                    chat: chat,
                    // При тапе открываем экран переписки этого чата.
                    // Navigator.push кладёт новый экран поверх текущего (стек экранов).
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ConversationScreen(chat: chat)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// _SearchPill — визуальное поле поиска (без логики в демке).
class _SearchPill extends StatelessWidget {
  const _SearchPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('Поиск', style: AppText.sans(14, color: AppColors.hint)),
    );
  }
}
