import 'package:flutter/material.dart';
import '../theme.dart';
import '../state/app_state.dart';

/// EditProfileScreen — редактирование профиля. Stateful: держит контроллеры полей.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _handle;
  late final TextEditingController _about;
  bool _inited = false;

  // Читать InheritedWidget (AppScope) в initState нельзя — зависимости ещё не
  // установлены. Поэтому инициализируем поля в didChangeDependencies (один раз).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    final app = AppScope.of(context);
    _name = TextEditingController(text: app.userName);
    _handle = TextEditingController(text: app.userHandle);
    _about = TextEditingController(text: app.userAbout);
    _inited = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _handle.dispose();
    _about.dispose();
    super.dispose();
  }

  /// _save() — записать изменения в AppState и вернуться назад.
  void _save() {
    AppScope.of(context).setProfile(
      name: _name.text.trim().isEmpty ? null : _name.text.trim(),
      handle: _handle.text.trim(),
      about: _about.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Редактирование', style: AppText.sans(17, weight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Сохранить',
                style: AppText.sans(15, color: AppColors.ink, weight: FontWeight.w700)),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.rule),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Field(label: 'ИМЯ', controller: _name),
            const SizedBox(height: 18),
            _Field(label: 'НИК', controller: _handle),
            const SizedBox(height: 18),
            _Field(label: 'О СЕБЕ', controller: _about, maxLines: 3),
          ],
        ),
      ),
    );
  }
}

/// _Field — подпись + поле ввода в едином стиле MINI.
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  const _Field({required this.label, required this.controller, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.sans(11, color: AppColors.inkFaint, weight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: AppText.sans(15),
          cursorColor: AppColors.ink,
          minLines: maxLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.field,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
