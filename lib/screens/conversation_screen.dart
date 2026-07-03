import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../data/mock_data.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/composer.dart';

/// ConversationScreen — экран переписки. Stateful: сообщения приходят, собеседник
/// «печатает вживую», работает «толк» с тряской. Канал — только чтение.
class ConversationScreen extends StatefulWidget {
  final Chat chat;
  const ConversationScreen({super.key, required this.chat});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

// TickerProviderStateMixin — нужен для анимации тряски (нескольких контроллеров).
class _ConversationScreenState extends State<ConversationScreen>
    with TickerProviderStateMixin {
  late final List<Message> _messages;
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool _typing = false;
  String? _liveText;
  Timer? _replyTimer;
  Timer? _liveTimer;
  int _replyIx = 0;

  late final AnimationController _shake; // короткая тряска ленты по «толку»

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.chat.messages);
    _shake = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _replyTimer?.cancel();
    _liveTimer?.cancel();
    _shake.dispose();
    super.dispose();
  }

  String _now() {
    final t = TimeOfDay.now();
    return '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  /// _send() — отправить своё сообщение. Авто-ответ запускаем только для личных чатов.
  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages
          .add(Message(text: text, mine: true, time: _now(), date: 'Сегодня'));
      _input.clear();
    });
    _scrollToBottom();

    if (widget.chat.isDM) {
      _replyTimer?.cancel();
      _replyTimer = Timer(const Duration(milliseconds: 750), _startLiveReply);
    }
  }

  /// _startLiveReply() — точки, затем посимвольный набор ответа из пула контакта.
  void _startLiveReply() {
    if (!mounted) return;
    // Берём пул реплик именно этого контакта (или общий запасной).
    final pool = replyPools[widget.chat.id] ??
        const [
          'Звучит отлично',
          'Хорошо, договорились',
          'Расскажи подробнее, интересно'
        ];
    final reply = pool[_replyIx % pool.length];
    _replyIx++;

    setState(() => _typing = true);
    _scrollToBottom();

    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _liveText = '';
      });
      int i = 0;
      _liveTimer?.cancel();
      // 55мс на символ — как в оригинале MINI.
      _liveTimer = Timer.periodic(const Duration(milliseconds: 55), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        i++;
        if (i > reply.length) {
          timer.cancel();
          setState(() {
            _liveText = null;
            _messages.add(Message(
                text: reply, mine: false, time: _now(), date: 'Сегодня'));
          });
          _scrollToBottom();
        } else {
          setState(() => _liveText = reply.substring(0, i));
          _scrollToBottom();
        }
      });
    });
  }

  /// _nudge() — «толк»: добавляем служебную строку и трясём ленту (как miniShake).
  void _nudge() {
    setState(() {
      _messages.add(const Message(
          kind: MsgKind.system, text: 'Вы отправили «толк»', mine: true));
    });
    _shake.forward(from: 0); // проиграть тряску с начала
    _scrollToBottom();
  }

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final extra = (_typing || _liveText != null) ? 1 : 0;

    return Scaffold(
      appBar: _buildHeader(),
      body: Column(
        children: [
          Expanded(
            // AnimatedBuilder сдвигает всю ленту по горизонтали во время «толка».
            child: AnimatedBuilder(
              animation: _shake,
              builder: (context, child) {
                // Затухающая синусоида: сильнее в начале, к концу — в ноль.
                final dx = math.sin(_shake.value * math.pi * 4) *
                    (1 - _shake.value) *
                    7;
                return Transform.translate(offset: Offset(dx, 0), child: child);
              },
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                itemCount: _messages.length + extra,
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    if (_typing) return const TypingIndicator();
                    if (_liveText != null) return _LiveBubble(text: _liveText!);
                  }
                  return _row(index);
                },
              ),
            ),
          ),
          // Канал — только чтение; в личных/группах — полноценный композер.
          if (chat.isChannel)
            const _ReadOnlyBar(label: 'Канал · только просмотр')
          else
            Composer(
              controller: _input,
              onSend: _send,
              onNudge: _nudge,
              onSchedule: () => _stub('Письмо в будущее — скоро'),
            ),
        ],
      ),
    );
  }

  /// _row() — строит одну строку ленты: при смене даты добавляет разделитель,
  /// системные сообщения рисует по центру, остальные — пузырём (с именем в группе).
  Widget _row(int index) {
    final m = _messages[index];

    // Системное сообщение — отдельная центрированная строка.
    if (m.kind == MsgKind.system) return SystemLine(text: m.text);

    // Имя отправителя показываем только для чужих сообщений в группе.
    final sender =
        (!m.mine && widget.chat.type == ChatType.group && m.senderId != null)
            ? people[m.senderId!]?.name
            : null;

    final bubble = MessageBubble(message: m, senderName: sender);

    // Разделитель даты — если у предыдущего сообщения дата другая.
    final showDate = m.date.isNotEmpty &&
        (index == 0 || _messages[index - 1].date != m.date);
    if (showDate) {
      return Column(children: [DateSeparator(label: m.date), bubble]);
    }
    return bubble;
  }

  PreferredSizeWidget _buildHeader() {
    final chat = widget.chat;
    // Форма мини-аватара в шапке: круг для DM, скруглённый квадрат для группы/канала.
    final avatarShape = chat.roundedAvatar
        ? BorderRadius.circular(11)
        : BorderRadius.circular(19);

    return AppBar(
      backgroundColor: AppColors.paper,
      elevation: 0,
      foregroundColor: AppColors.ink,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(color: AppColors.sage, borderRadius: avatarShape),
            child: Text(chat.initials,
                style: AppText.sans(14, weight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(chat.name,
                  style: AppText.sans(15.5, weight: FontWeight.w600)),
              Text(chat.status,
                  style: AppText.sans(12,
                      color: (chat.isDM && chat.online)
                          ? AppColors.online
                          : AppColors.inkFaint)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
            onPressed: () => _stub('Меню чата — скоро'),
            icon: const Icon(Icons.more_vert, size: 20)),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.rule),
      ),
    );
  }
}

/// _LiveBubble — шалфейный пузырь: собеседник «печатает вживую» (посимвольно).
class _LiveBubble extends StatelessWidget {
  final String text;
  const _LiveBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: const BoxDecoration(
          color: AppColors.sage,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(kRadius),
            topRight: Radius.circular(kRadius),
            bottomRight: Radius.circular(kRadius),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Text(text.isEmpty ? '…' : text,
            style: AppText.sans(15, height: 1.42, color: AppColors.ink)),
      ),
    );
  }
}

/// _ReadOnlyBar — нижняя полоса для канала (нельзя писать).
class _ReadOnlyBar extends StatelessWidget {
  final String label;
  const _ReadOnlyBar({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.rule)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          child: Text(label,
              textAlign: TextAlign.center,
              style: AppText.sans(13, color: AppColors.inkFaint)),
        ),
      ),
    );
  }
}
