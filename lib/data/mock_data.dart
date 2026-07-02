import '../models.dart';

/// mockChats — тестовые данные. В боевом приложении список пришёл бы с сервера;
/// для демки достаточно захардкоженного списка в памяти.
/// Персонажи и реплики взяты из макета MINI.
final List<Chat> mockChats = [
  Chat(
    name: 'Настя',
    initials: 'Н',
    status: 'в сети',
    online: true,
    time: '9:41',
    unread: 2,
    messages: const [
      Message(text: 'Привет!', mine: false, time: '9:39',
          reactions: [Reaction(emoji: '👍', count: 1)]),
      Message(text: 'Привет) Как выходные прошли?', mine: true, time: '9:40'),
      Message(text: 'Ездили за город, было тихо и хорошо. А у тебя?',
          mine: false, time: '9:41',
          reactions: [Reaction(emoji: '❤️', count: 1, mine: true)]),
    ],
  ),
  Chat(
    name: 'Игорь',
    initials: 'И',
    status: 'был в сети 5 минут назад',
    online: false,
    time: '9:10',
    unread: 0,
    messages: const [
      Message(text: 'Встречаемся в семь?', mine: false, time: '9:05'),
      Message(text: 'Договорились', mine: true, time: '9:10'),
    ],
  ),
  Chat(
    name: 'Мама',
    initials: 'М',
    status: 'была в сети вчера',
    online: false,
    time: 'Вчера',
    unread: 0,
    messages: const [
      Message(text: 'Позвони, когда сможешь', mine: false, time: 'Вчера'),
    ],
  ),
];
