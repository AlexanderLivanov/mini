import 'dart:async'; // для Timer (задержки и посимвольный набор)
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/composer.dart';

/// ConversationScreen — экран одной переписки.
/// Это StatefulWidget, потому что содержимое МЕНЯЕТСЯ во времени: приходят
/// сообщения, собеседник «печатает вживую», обновляется поле ввода.
class ConversationScreen extends StatefulWidget {
  final Chat chat;
  const ConversationScreen({super.key, required this.chat});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

/// _ConversationScreenState — здесь живёт изменяемое состояние экрана.
class _ConversationScreenState extends State<ConversationScreen> {
  late final List<Message> _messages;            // изменяемая копия переписки
  final TextEditingController _input = TextEditingController(); // «пульт» поля ввода
  final ScrollController _scroll = ScrollController();          // «пульт» прокрутки

  bool _typing = false;   // показывать ли «прыгающие точки»
  String? _liveText;      // текст, набираемый собеседником «вживую» (null — не набирает)
  Timer? _replyTimer;     // таймер задержки перед ответом
  Timer? _liveTimer;      // таймер посимвольного набора

  // Пул авто-ответов из макета MINI.
  static const List<String> _replies = [
    'Звучит отлично',
    'Да, давай — сейчас пришлю',
    'Расскажи подробнее, интересно',
    'Хорошо, договорились',
    'Только что вспомнил — надо обсудить',
  ];
  int _replyIx = 0; // какой ответ выдать следующим (по кругу)

  @override
  void initState() {
    super.initState();
    // List.of создаёт ИЗМЕНЯЕМУЮ копию истории — исходные данные не трогаем.
    _messages = List.of(widget.chat.messages);
  }

  @override
  void dispose() {
    // Освобождаем контроллеры и таймеры, иначе утечки и падения после закрытия.
    _input.dispose();
    _scroll.dispose();
    _replyTimer?.cancel();
    _liveTimer?.cancel();
    super.dispose();
  }

  /// _now() — текущее время в формате Ч:ММ (как в макете).
  String _now() {
    final t = TimeOfDay.now();
    return '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
  }

  /// _scrollToBottom() — прокрутить ленту к последнему сообщению.
  /// addPostFrameCallback ждёт, пока Flutter дорисует новый элемент, и лишь потом
  /// прокручивает — иначе высота ленты ещё не пересчитана.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// _send() — отправить своё сообщение и запустить «живой» авто-ответ.
  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return; // пустое не отправляем

    // setState сообщает Flutter: «состояние изменилось, перерисуй экран».
    setState(() {
      _messages.add(Message(text: text, mine: true, time: _now()));
      _input.clear();
    });
    _scrollToBottom();

    // Через 750мс собеседник начинает «печатать» (как в оригинале MINI).
    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(milliseconds: 750), _startLiveReply);
  }

  /// _startLiveReply() — сначала точки, затем посимвольный набор ответа.
  void _startLiveReply() {
    if (!mounted) return; // экран уже закрыт — ничего не делаем
    final reply = _replies[_replyIx % _replies.length];
    _replyIx++;

    setState(() => _typing = true); // фаза 1: прыгающие точки
    _scrollToBottom();

    // Через 700мс точки сменяются набором «вживую».
    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _liveText = ''; // фаза 2: пустой «живой» пузырь, сейчас начнём набирать
      });

      int i = 0;
      _liveTimer?.cancel();
      // Каждые 45мс добавляем по одному символу — эффект живого набора.
      _liveTimer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        i++;
        if (i > reply.length) {
          // Набор закончен: превращаем «живой» текст в обычное сообщение.
          timer.cancel();
          setState(() {
            _liveText = null;
            _messages.add(Message(text: reply, mine: false, time: _now()));
          });
          _scrollToBottom();
        } else {
          setState(() => _liveText = reply.substring(0, i));
          _scrollToBottom();
        }
      });
    });
  }

  /// _stub() — заглушка для nudge/schedule/меню: показываем, что фича задумана.
  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Нужна ли дополнительная строка в конце ленты (точки ИЛИ живой пузырь)?
    final extra = (_typing || _liveText != null) ? 1 : 0;

    return Scaffold(
      appBar: _buildHeader(),
      body: Column(
        children: [
          // Лента сообщений.
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              itemCount: _messages.length + extra,
              itemBuilder: (context, index) {
                // Последняя «виртуальная» строка — точки или живой пузырь.
                if (index == _messages.length) {
                  if (_typing) return const TypingIndicator();
                  if (_liveText != null) return _LiveBubble(text: _liveText!);
                }
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),
          // Панель ввода.
          Composer(
            controller: _input,
            onSend: _send,
            onNudge: () => _stub('Мягкое напоминание — скоро'),
            onSchedule: () => _stub('Письмо в будущее — скоро'),
          ),
        ],
      ),
    );
  }

  /// _buildHeader() — верхняя панель: назад, аватар, имя и статус, меню «⋮».
  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: AppColors.paper,
      elevation: 0,
      foregroundColor: AppColors.ink, // цвет стрелки «назад»
      titleSpacing: 0,
      title: Row(
        children: [
          // Мини-аватар в шапке.
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
            child: Text(widget.chat.initials, style: AppText.sans(14, weight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.chat.name, style: AppText.sans(15.5, weight: FontWeight.w600)),
              // Статус: если онлайн — зелёным, иначе приглушённым серым.
              Text(widget.chat.status,
                  style: AppText.sans(12,
                      color: widget.chat.online ? AppColors.online : AppColors.inkFaint)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _stub('Меню чата — скоро'),
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

/// _LiveBubble — шалфейный пузырь с мигающим текстом: собеседник «печатает вживую».
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
            topLeft: Radius.circular(kRadius),
            topRight: Radius.circular(kRadius),
            bottomRight: Radius.circular(kRadius),
            bottomLeft: Radius.circular(4),
          ),
        ),
        // Пока текст пустой — показываем многоточие, чтобы пузырь не «схлопывался».
        child: Text(
          text.isEmpty ? '…' : text,
          style: AppText.sans(15, height: 1.42, color: AppColors.ink),
        ),
      ),
    );
  }
}
