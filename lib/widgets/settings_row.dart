import 'package:flutter/material.dart';
import '../theme.dart';

/// SettingsRow — строка настроек: заголовок, необязательный подзаголовок и справа
/// либо переключатель (если задан toggleValue), либо стрелка-шеврон (иначе).
class SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool? toggleValue;             // задан → рисуем Switch
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;           // задан (и не toggle) → строка кликабельна
  final String? trailingText;          // напр. статус MINI+

  const SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.toggleValue,
    this.onToggle,
    this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final isToggle = toggleValue != null;
    return InkWell(
      onTap: isToggle ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.sans(15, weight: FontWeight.w700)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: AppText.sans(13, color: AppColors.inkSoft, height: 1.35)),
                  ],
                ],
              ),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(trailingText!, style: AppText.sans(13, color: AppColors.inkFaint)),
              ),
            if (isToggle)
              Switch(
                value: toggleValue!,
                onChanged: onToggle,
                activeColor: Colors.white,
                activeTrackColor: AppColors.ink,
                inactiveColor: Colors.white,
                inactiveTrackColor: AppColors.rule,
              )
            else if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.inkFaint, size: 22),
          ],
        ),
      ),
    );
  }
}
