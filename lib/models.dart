/// Тип чата: определяет форму аватара, значок в списке и права
/// (канал — только чтение, без поля ввода).
enum ChatType { dm, group, channel }

/// Тип содержимого сообщения — как его рисовать.
enum MsgKind { text, sticker, photo, video, system }

/// Reaction — эмодзи-реакция под сообщением и её счётчик.
class Reaction {
  final String emoji; // сам эмодзи, напр. '❤️'
  final int count; // сколько раз поставили
  final bool mine; // поставил ли реакцию я (тогда «чип» тёмный)
  const Reaction({required this.emoji, required this.count, this.mine = false});
}

/// Person — участник: нужен для подписи отправителя в группах.
class Person {
  final String initials;
  final String name;
  final bool online;
  const Person(
      {required this.initials, required this.name, this.online = false});
}

/// Message — одно сообщение. Поле `kind` решает, как его отрисовать.
class Message {
  final MsgKind kind; // тип содержимого
  final String text; // текст / подпись стикера / метка медиа / текст системного
  final bool mine; // true — моё (справа, тёмное)
  final String time; // время-строка, напр. '9:41'
  final String
      date; // ярлык даты для разделителя: 'Сегодня' / 'Вчера' / '1 июля'
  final String? senderId; // id отправителя в группе (для подписи над пузырём)
  final String? duration; // длительность видео, напр. '0:14'
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
}

/// Chat — один диалог/группа/канал.
class Chat {
  final String id;
  final ChatType type;
  final String name;
  final String initials;
  final bool online;
  final String lastSeen; // 'была в сети в 9:10' и т.п. (для DM не в сети)
  final String time; // время последнего сообщения (в списке)
  final int unread;
  final String preview; // готовое превью для строки списка
  final String subscribers; // для канала: '1 240 подписчиков'
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
    required this.messages,
  });

  bool get isDM => type == ChatType.dm;
  bool get isChannel => type == ChatType.channel;

  /// Группа и канал — скруглённый квадрат; личный чат — круг.
  bool get roundedAvatar => type != ChatType.dm;

  /// Значок рядом с именем в списке: канал 📢, группа 👥, DM — пусто.
  String get badge =>
      type == ChatType.channel ? '📢' : (type == ChatType.group ? '👥' : '');

  /// Статус в шапке переписки.
  String get status {
    if (isChannel) return subscribers;
    if (online) return 'в сети';
    return lastSeen.isNotEmpty ? lastSeen : 'недавно';
  }
}
