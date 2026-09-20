import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DashboardSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry bodyPadding;
  final double? height;

  const DashboardSectionCard({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    required this.child,
    this.bodyPadding = const EdgeInsets.all(12),
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderCard, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: height != null ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Solid Dark Navy Header #12385C
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            color: AppColors.navyHeader,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: AppColors.tealAccent),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textOnNavy,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),

          // Card Body
          height != null
              ? Expanded(
                  child: Padding(
                    padding: bodyPadding,
                    child: child,
                  ),
                )
              : Padding(
                  padding: bodyPadding,
                  child: child,
                ),
        ],
      ),
    );
  }
}
