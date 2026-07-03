import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_shell.dart';

/// OnboardingScreen — приветствие: логотип MINI, короткое описание, «Начать».
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MINI', style: AppText.logo(64)),
              const SizedBox(height: 14),
              Text(
                'Минималистичный мессенджер. Тихие чаты, реакции, профили и каналы — без лишнего.',
                style: AppText.sans(16, color: AppColors.inkSoft, height: 1.5),
              ),
              const SizedBox(height: 40),
              // Кнопка «Начать» — тёмная «таблетка» на всю ширину.
              GestureDetector(
                onTap: () {
                  // pushReplacement — заменяем онбординг домашним экраном
                  // (назад к онбордингу возвращаться не нужно).
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeShell()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Начать',
                      style: AppText.sans(16, color: Colors.white, weight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
