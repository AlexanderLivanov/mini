/// Reaction — эмодзи-реакция под сообщением и её счётчик.
class Reaction {
  final String emoji; // сам эмодзи, напр. '❤️'
  final int count;    // сколько раз поставили
  final bool mine;    // поставил ли реакцию я (тогда «чип» тёмный)

  const Reaction({required this.emoji, required this.count, this.mine = false});
}

/// Message — одно сообщение в переписке.
/// `final` = после создания объект менять нельзя (иммутабельность → меньше багов).
class Message {
  final String text;              // текст сообщения
  final bool mine;                // true — моё (справа, тёмное); false — собеседника
  final String time;              // время-строка, напр. '9:41'
  final List<Reaction> reactions; // реакции (может быть пусто)

  const Message({
    required this.text,
    required this.mine,
    required this.time,
    this.reactions = const [],
  });
}

/// Chat — один диалог в списке чатов.
class Chat {
  final String name;            // имя собеседника
  final String initials;        // инициалы для аватара
  final String status;          // 'в сети' / 'была в сети вчера'
  final bool online;            // показывать ли зелёную точку
  final String time;            // время последнего сообщения (для списка)
  final int unread;             // непрочитанные (0 — бейдж скрыт)
  final List<Message> messages; // история переписки

  const Chat({
    required this.name,
    required this.initials,
    required this.status,
    required this.online,
    required this.time,
    required this.unread,
    required this.messages,
  });

  /// preview — геттер (вычисляемое свойство, читается как поле: chat.preview).
  /// Возвращает текст последнего сообщения для строки в списке.
  String get preview => messages.isEmpty ? '' : messages.last.text;
}
