import '../models.dart';

/// Участники — для подписи отправителей в группах (взято из прототипа MINI).
const Map<String, Person> people = {
  'nastya': Person(initials: 'Н', name: 'Настя', online: true),
  'igor':   Person(initials: 'И', name: 'Игорь'),
  'lena':   Person(initials: 'Л', name: 'Лена', online: true),
};

/// mockChats — реальные данные из прототипа MINI: личные чаты, группа и канал,
/// с разными типами сообщений (текст, стикер, фото, видео), датами и реакциями.
final List<Chat> mockChats = [
  Chat(
    id: 'julia', type: ChatType.dm, name: 'Юля', initials: 'Ю',
    online: true, time: '9:41', unread: 2, preview: 'Ездили за город',
    messages: const [
      Message(text: 'Привет!', mine: false, time: '9:39', date: 'Сегодня',
          reactions: [Reaction(emoji: '👍', count: 1)]),
      Message(kind: MsgKind.sticker, text: 'обнимаю', mine: false, time: '9:39', date: 'Сегодня'),
      Message(text: 'Привет! Как выходные?', mine: true, time: '9:40', date: 'Сегодня'),
      Message(text: 'Ездили за город, было тихо и хорошо. А у тебя?',
          mine: false, time: '9:41', date: 'Сегодня',
          reactions: [Reaction(emoji: '❤️', count: 1, mine: true)]),
      Message(text: 'Приезжай в следующий раз с нами — там озеро и ноль связи',
          mine: false, time: '9:41', date: 'Сегодня'),
    ],
  ),
  Chat(
    id: 'team', type: ChatType.group, name: 'Команда дизайна', initials: 'Д',
    time: '9:37', unread: 1, preview: 'Лена: спасибо!',
    messages: const [
      Message(text: 'Собрал всё в одну папку — ссылка в описании чата',
          mine: true, time: '9:30', date: 'Сегодня'),
      Message(text: 'Супер. Макеты у тебя?', mine: false, time: '9:35', date: 'Сегодня',
          senderId: 'nastya', reactions: [Reaction(emoji: '🔥', count: 2)]),
      Message(text: 'Я подхвачу вёрстку, к пятнице будет готово',
          mine: false, time: '9:36', date: 'Сегодня', senderId: 'igor'),
      Message(kind: MsgKind.sticker, text: 'спасибо!', mine: false, time: '9:37',
          date: 'Сегодня', senderId: 'lena'),
    ],
  ),
  Chat(
    id: 'news', type: ChatType.channel, name: 'MINI · Канал', initials: 'M',
    time: '12:30', preview: 'Папки и тихие часы — скоро',
    subscribers: '1 240 подписчиков',
    messages: const [
      Message(text: 'MINI 1.0 уже здесь. Тихие чаты, реакции и никакой ленты.',
          mine: false, time: '8:00', date: '1 июля',
          reactions: [Reaction(emoji: '❤️', count: 24), Reaction(emoji: '🔥', count: 9)]),
      Message(kind: MsgKind.photo, text: 'обложка 1.0', mine: false, time: '8:00', date: '1 июля',
          reactions: [Reaction(emoji: '👍', count: 12)]),
      Message(text: 'На следующей неделе — папки и тихие часы.',
          mine: false, time: '12:30', date: 'Сегодня',
          reactions: [Reaction(emoji: '👀', count: 7)]),
    ],
  ),
  Chat(
    id: 'sonya', type: ChatType.dm, name: 'Соня', initials: 'С',
    lastSeen: 'была в сети в 9:10', time: '9:02', preview: 'Видео',
    messages: const [
      Message(text: 'Смотри, какой был закат', mine: false, time: 'Вчера', date: 'Вчера'),
      Message(kind: MsgKind.photo, text: 'закат у моря', mine: false, time: 'Вчера', date: 'Вчера',
          reactions: [Reaction(emoji: '❤️', count: 2)]),
      Message(text: 'Ого, красота! Где это?', mine: true, time: 'Вчера', date: 'Вчера'),
      Message(text: 'На заливе, у старого пирса. А вот видео оттуда:',
          mine: false, time: '9:01', date: 'Сегодня'),
      Message(kind: MsgKind.video, text: 'прогулка у воды', duration: '0:14',
          mine: false, time: '9:02', date: 'Сегодня'),
    ],
  ),
  Chat(
    id: 'pasha', type: ChatType.dm, name: 'Паша', initials: 'П',
    lastSeen: 'был в сети в 8:30', time: '9:10', preview: 'Договорились',
    messages: const [
      Message(text: 'Встречаемся в семь на площадке?', mine: false, time: '9:05', date: 'Сегодня'),
      Message(text: 'Договорились, буду вовремя', mine: true, time: '9:10', date: 'Сегодня'),
    ],
  ),
  Chat(
    id: 'mama', type: ChatType.dm, name: 'Мама', initials: 'М',
    lastSeen: 'была в сети вчера', time: 'Вчера', preview: 'Позвони, когда сможешь',
    messages: const [
      Message(text: 'Позвони, когда сможешь', mine: false, time: 'Вчера', date: 'Вчера'),
    ],
  ),
];

/// Пулы авто-ответов по контактам (как в прототипе): для каждого DM — свои реплики.
const Map<String, List<String>> replyPools = {
  'julia': ['У меня спокойно — читаю и пью чай', 'Давай на неделе выберемся вместе?',
    'Пришлю тебе фото оттуда, ты оценишь', 'Согласна, тишина лечит'],
  'sonya': ['Сейчас скину ещё пару кадров!', 'Это я на плёнку снимала, кстати',
    'Пойдёшь со мной на закат в субботу?', 'Спасибо! Мне тоже этот кадр нравится'],
  'pasha': ['Окей, буду в семь ровно', 'Захвати мяч, мой сдулся',
    'После игры можно кофе', 'Договорились, до вечера!'],
  'mama': ['Спасибо, что написал! Как ты там?', 'Позвони вечером, расскажу новости',
    'Береги себя и ешь нормально', 'Целую!'],
};