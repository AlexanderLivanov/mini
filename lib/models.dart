/// Тип чата: форма аватара, значок в списке, права (канал — только чтение).
enum ChatType { dm, group, channel }

/// Тип содержимого сообщения — как его рисовать.
enum MsgKind { text, sticker, photo, video, system }

/// Reaction — эмодзи-реакция под сообщением и её счётчик.
class Reaction {
  final String emoji;
  final int count;
  final bool mine;
  const Reaction({required this.emoji, required this.count, this.mine = false});
}

/// Person — участник: имя, инициалы, «о себе» (для карточки участника в группах).
class Person {
  final String initials;
  final String name;
  final bool online;
  final String bio;
  const Person({required this.initials, required this.name, this.online = false, this.bio = ''});
}

/// Message — одно сообщение. `kind` решает отрисовку.
class Message {
  final MsgKind kind;
  final String text;
  final bool mine;
  final String time;
  final String date;
  final String? senderId;
  final String? duration;
  final List<Reaction> reactions;

  const Message({
    this.kind = MsgKind.text,
    this.text = '',
    required this.mine,
    this.time = '',
    this.date = '',
    this.senderId,
    this.duration,
    this.reactions = const [],
  });

  /// copyWith — вернуть копию сообщения с изменёнными полями (иммутабельное
  /// обновление). Нужен, чтобы «поменять» реакции: мы не мутируем объект,
  /// а заменяем его новой копией в списке.
  Message copyWith({List<Reaction>? reactions}) => Message(
        kind: kind,
        text: text,
        mine: mine,
        time: time,
        date: date,
        senderId: senderId,
        duration: duration,
        reactions: reactions ?? this.reactions,
      );
}

/// Comment — комментарий под постом канала.
class Comment {
  final String author;
  final String initials;
  final String text;
  final String time;
  const Comment({required this.author, required this.initials, required this.text, required this.time});
}

/// Chat — диалог / группа / канал.
class Chat {
  final String id;
  final ChatType type;
  final String name;
  final String initials;
  final bool online;
  final String lastSeen;
  final String time;
  final int unread;
  final String preview;
  final String subscribers;
  final String bio;      // «о себе» собеседника (для карточки в DM)
  final bool owe;        // «вы обещали ответить позже» — мягкое напоминание
  final List<Message> messages;

  const Chat({
    required this.id,
    required this.type,
    required this.name,
    required this.initials,
    this.online = false,
    this.lastSeen = '',
    this.time = '',
    this.unread = 0,
    this.preview = '',
    this.subscribers = '',
    this.bio = '',
    this.owe = false,
    required this.messages,
  });

  bool get isDM => type == ChatType.dm;
  bool get isChannel => type == ChatType.channel;
  bool get roundedAvatar => type != ChatType.dm;
  String get badge =>
      type == ChatType.channel ? '📢' : (type == ChatType.group ? '👥' : '');

  String get status {
    if (isChannel) return subscribers;
    if (online) return 'в сети';
    return lastSeen.isNotEmpty ? lastSeen : 'недавно';
  }
}
