import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Maps our string icon keys (kept in models to stay backend-agnostic) to
/// concrete Material icons.
IconData iconFor(String key) {
  switch (key) {
    case 'computer':
      return Icons.computer_rounded;
    case 'assignment':
      return Icons.assignment_rounded;
    case 'cart':
      return Icons.shopping_cart_rounded;
    case 'call':
      return Icons.call_rounded;
    case 'check':
      return Icons.check_rounded;
    case 'school':
      return Icons.school_rounded;
    case 'medal':
      return Icons.emoji_events_rounded;
    case 'certificate':
      return Icons.workspace_premium_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'alarm':
      return Icons.alarm_rounded;
    case 'mic':
      return Icons.mic_rounded;
    default:
      return Icons.circle;
  }
}

Color colorFor(String key) {
  switch (key) {
    case 'navy':
      return AppColors.navy;
    case 'purple':
      return AppColors.purple;
    case 'teal':
      return AppColors.teal;
    case 'orange':
      return AppColors.orange;
    default:
      return AppColors.navy;
  }
}

/// Onboarding-style progress dots (small pill for active, dot for inactive).
class DotsIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  const DotsIndicator({super.key, required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.navy : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// A rounded selectable chip used across the registration + skills screens.
class SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  const SelectableChip({super.key, required this.label, required this.selected, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? AppColors.navy : Colors.grey.shade300, width: 1.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17, color: selected ? AppColors.navy : AppColors.textMuted),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(
                  color: selected ? AppColors.navy : AppColors.textDark,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13.5,
                )),
          ],
        ),
      ),
    );
  }
}

/// Small badge, e.g. "Free (GIA Funded)" or "Level 3".
class TagBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  const TagBadge({super.key, required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: textColor ?? Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Color eyebrowColor;
  final Color titleColor;
  const SectionTitle({super.key, required this.eyebrow, required this.title, this.eyebrowColor = AppColors.tealLight, this.titleColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(),
            style: TextStyle(color: eyebrowColor, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.6)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 22)),
      ],
    );
  }
}
