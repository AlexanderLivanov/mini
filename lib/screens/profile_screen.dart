import 'package:flutter/material.dart';
import '../theme.dart';
import '../state/app_state.dart';
import 'edit_profile_screen.dart';

/// ProfileScreen — «Мой профиль»: аватар, имя, @ник, «о себе», кнопка редактирования.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Профиль', style: AppText.sans(17, weight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.rule),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 72, height: 72, alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
                    child: Text(app.initials, style: AppText.sans(30, weight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.userName, style: AppText.sans(22, weight: FontWeight.w700)),
                      Text(app.userHandle, style: AppText.sans(14, color: AppColors.inkFaint)),
                      if (app.isPlus)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.ink, borderRadius: BorderRadius.circular(999)),
                          child: Text('MINI+',
                              style: AppText.sans(11, color: Colors.white, weight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text('О СЕБЕ',
                  style: AppText.sans(11, color: AppColors.inkFaint, weight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(app.userAbout, style: AppText.sans(15, color: AppColors.ink, height: 1.5)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.ink),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Редактировать профиль',
                      style: AppText.sans(15, weight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
