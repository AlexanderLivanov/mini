import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../data/mock_data.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/composer.dart';
import '../widgets/reaction_picker.dart';
import '../widgets/schedule_sheet.dart';
import '../widgets/member_card.dart';
import 'comments_screen.dart';

/// ConversationScreen — экран переписки со всеми фичами MINI:
/// реакции по долгому нажатию, «толк» с тряской, «письмо в будущее»,
/// мягкое напоминание «вы обещали ответить», карточки участников, комментарии канала.
class ConversationScreen extends StatefulWidget {
  final Chat chat;
  const ConversationScreen({super.key, required this.chat});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

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

  late final AnimationController _shake;
  late bool _oweShown; // показывать ли баннер «вы обещали ответить»

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.chat.messages);
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _oweShown = widget.chat.owe;
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

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(Message(text: text, mine: true, time: _now(), date: 'Сегодня'));
      _input.clear();
    });
    _scrollToBottom();
    if (widget.chat.isDM) {
      _replyTimer?.cancel();
      _replyTimer = Timer(const Duration(milliseconds: 750), _startLiveReply);
    }
  }

  void _startLiveReply() {
    if (!mounted) return;
    final pool = replyPools[widget.chat.id] ??
        const ['Звучит отлично', 'Хорошо, договорились', 'Расскажи подробнее'];
    final reply = pool[_replyIx % pool.length];
    _replyIx++;

    setState(() => _typing = true);
    _scrollToBottom();

    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() { _typing = false; _liveText = ''; });
      int i = 0;
      _liveTimer?.cancel();
      _liveTimer = Timer.periodic(const Duration(milliseconds: 55), (timer) {
        if (!mounted) { timer.cancel(); return; }
        i++;
        if (i > reply.length) {
          timer.cancel();
          setState(() {
            _liveText = null;
            _messages.add(Message(text: reply, mine: false, time: _now(), date: 'Сегодня'));
          });
          _scrollToBottom();
        } else {
          setState(() => _liveText = reply.substring(0, i));
          _scrollToBottom();
        }
      });
    });
  }

  /// _nudge() — «толк»: служебная строка + тряска ленты.
  void _nudge() {
    setState(() => _messages.add(
        const Message(kind: MsgKind.system, text: 'Вы отправили «толк»', mine: true)));
    _shake.forward(from: 0);
    _scrollToBottom();
  }

  /// _schedule() — «письмо в будущее»: выбрать время, запланировать текст из поля.
  Future<void> _schedule() async {
    final text = _input.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала напишите сообщение'), duration: Duration(seconds: 1)),
      );
      return;
    }
    final when = await showScheduleSheet(context);
    if (when == null || !mounted) return;
    setState(() {
      _messages.add(Message(
          kind: MsgKind.system, text: 'Запланировано ($when): «$text»', mine: true));
      _input.clear();
    });
    _scrollToBottom();
  }

  /// _openReactionPicker() — по долгому нажатию: выбрать эмодзи и переключить реакцию.
  Future<void> _openReactionPicker(int index) async {
    final emoji = await showReactionPicker(context);
    if (emoji == null || !mounted) return;
    _toggleReaction(index, emoji);
  }

  /// _toggleReaction() — добавить/убрать МОЮ реакцию на сообщение (иммутабельно).
  void _toggleReaction(int index, String emoji) {
    setState(() {
      final m = _messages[index];
      final list = List<Reaction>.of(m.reactions);
      final i = list.indexWhere((r) => r.emoji == emoji);
      if (i >= 0) {
        final r = list[i];
        if (r.mine) {
          // моя реакция уже стоит → снять
          if (r.count <= 1) {
            list.removeAt(i);
          } else {
            list[i] = Reaction(emoji: emoji, count: r.count - 1, mine: false);
          }
        } else {
          // чужая реакция есть → добавить свою сверху
          list[i] = Reaction(emoji: emoji, count: r.count + 1, mine: true);
        }
      } else {
        list.add(Reaction(emoji: emoji, count: 1, mine: true));
      }
      _messages[index] = m.copyWith(reactions: list);
    });
  }

  /// Открыть карточку участника группы по его id.
  void _openMember(String senderId) {
    final p = people[senderId];
    if (p == null) return;
    showMemberCard(context,
        initials: p.initials, name: p.name, handle: '@$senderId',
        online: p.online, bio: p.bio);
  }

  /// Открыть карточку собеседника (для личного чата) из шапки.
  void _openContactCard() {
    final c = widget.chat;
    showMemberCard(context,
        initials: c.initials, name: c.name, handle: '@${c.id}',
        online: c.online, bio: c.bio);
  }

  /// Открыть комментарии к посту канала.
  void _openComments(String postText) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => CommentsScreen(postText: postText)));
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final extra = (_typing || _liveText != null) ? 1 : 0;

    return Scaffold(
      appBar: _buildHeader(),
      body: Column(
        children: [
          // Мягкое напоминание «вы обещали ответить» — фирменная фича MINI.
          if (_oweShown) _OweBanner(onDismiss: () => setState(() => _oweShown = false)),
          Expanded(
            child: AnimatedBuilder(
              animation: _shake,
              builder: (context, child) {
                final dx = math.sin(_shake.value * math.pi * 4) * (1 - _shake.value) * 7;
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
          if (chat.isChannel)
            const _ReadOnlyBar(label: 'Канал · только просмотр')
          else
            Composer(
              controller: _input,
              onSend: _send,
              onNudge: _nudge,
              onSchedule: _schedule,
            ),
        ],
      ),
    );
  }

  Widget _row(int index) {
    final m = _messages[index];
    if (m.kind == MsgKind.system) return SystemLine(text: m.text);

    final isGroupSender =
        !m.mine && widget.chat.type == ChatType.group && m.senderId != null;
    final sender = isGroupSender ? people[m.senderId!]?.name : null;

    // Тап по посту канала → комментарии; долгое нажатие везде → реакции.
    final bubble = MessageBubble(
      message: m,
      senderName: sender,
      onLongPress: () => _openReactionPicker(index),
      onTap: widget.chat.isChannel ? () => _openComments(m.text) : null,
      onSenderTap: isGroupSender ? () => _openMember(m.senderId!) : null,
    );

    final showDate =
        m.date.isNotEmpty && (index == 0 || _messages[index - 1].date != m.date);
    if (showDate) return Column(children: [DateSeparator(label: m.date), bubble]);
    return bubble;
  }

  PreferredSizeWidget _buildHeader() {
    final chat = widget.chat;
    final avatarShape =
        chat.roundedAvatar ? BorderRadius.circular(11) : BorderRadius.circular(19);

    return AppBar(
      backgroundColor: AppColors.paper,
      elevation: 0,
      foregroundColor: AppColors.ink,
      titleSpacing: 0,
      // Тап по шапке личного чата открывает карточку собеседника.
      title: GestureDetector(
        onTap: chat.isDM ? _openContactCard : null,
        child: Row(
          children: [
            Container(
              width: 38, height: 38, alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.sage, borderRadius: avatarShape),
              child: Text(chat.initials, style: AppText.sans(14, weight: FontWeight.w600)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(chat.name, style: AppText.sans(15.5, weight: FontWeight.w600)),
                Text(chat.status,
                    style: AppText.sans(12,
                        color: (chat.isDM && chat.online) ? AppColors.online : AppColors.inkFaint)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Меню чата — скоро'), duration: Duration(seconds: 1)),
          ),
          icon: const Icon(Icons.more_vert, size: 20),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.rule),
      ),
    );
  }
}

/// _OweBanner — мягкое напоминание «вы обещали ответить позже» с крестиком.
class _OweBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _OweBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6F2),
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppText.sans(12.5, color: AppColors.ink),
                children: [
                  const TextSpan(text: 'Вы обещали ответить позже '),
                  TextSpan(
                      text: '· мягко, без двойных галочек',
                      style: AppText.sans(12.5, color: AppColors.inkFaint)),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16, color: AppColors.inkFaint),
            ),
          ),
        ],
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: const BoxDecoration(
          color: AppColors.sage,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(kRadius), topRight: Radius.circular(kRadius),
            bottomRight: Radius.circular(kRadius), bottomLeft: Radius.circular(4),
          ),
        ),
        child: Text(text.isEmpty ? '…' : text,
            style: AppText.sans(15, height: 1.42, color: AppColors.ink)),
      ),
    );
  }
}

/// _ReadOnlyBar — нижняя полоса для канала (писать нельзя).
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
