import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../data/mock_data.dart';
import '../state/app_state.dart';

/// CommentsScreen — комментарии под постом канала. Открывается тапом на пост.
/// Stateful: можно оставить свой комментарий (локально, без сервера).
class CommentsScreen extends StatefulWidget {
  final String postText; // текст поста, к которому комментарии
  const CommentsScreen({super.key, required this.postText});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late final List<Comment> _comments;
  final TextEditingController _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    _comments = List.of(channelComments); // изменяемая копия мок-комментариев
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  /// _send() — добавить свой комментарий от имени текущего профиля.
  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final app = AppScope.of(context);
    setState(() {
      _comments.add(Comment(
        author: app.userName,
        initials: app.initials,
        text: text,
        time: _now(),
      ));
      _input.clear();
    });
  }

  String _now() {
    final t = TimeOfDay.now();
    return '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Комментарии', style: AppText.sans(17, weight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.rule),
        ),
      ),
      body: Column(
        children: [
          // Пост, к которому комментарии (шапка).
          Container(
            width: double.infinity,
            color: AppColors.field,
            padding: const EdgeInsets.all(16),
            child: Text(widget.postText, style: AppText.sans(14, height: 1.4)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _comments.length,
              itemBuilder: (context, i) => _CommentTile(comment: _comments[i]),
            ),
          ),
          _CommentInput(controller: _input, onSend: _send),
        ],
      ),
    );
  }
}

/// _CommentTile — один комментарий: аватар-инициал, автор, время, текст.
class _CommentTile extends StatelessWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36, alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
            child: Text(comment.initials, style: AppText.sans(14, weight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.author, style: AppText.sans(13.5, weight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Text(comment.time, style: AppText.sans(11, color: AppColors.inkFaint)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.text, style: AppText.sans(14, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// _CommentInput — строка ввода комментария.
class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _CommentInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.rule)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppText.sans(15),
                  cursorColor: AppColors.ink,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'Комментарий',
                    hintStyle: AppText.sans(15, color: AppColors.hint),
                    filled: true,
                    fillColor: AppColors.field,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onSend,
                child: Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_upward, size: 19, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
