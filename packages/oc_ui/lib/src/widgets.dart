import 'package:flutter/material.dart';
import 'tokens.dart';

/// Primary full-width button — crimson with loader support.
class OcButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;

  const OcButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: OcColors.textOnPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    if (outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );
  }
}

/// Gold accent chip for tags/categories.
class OcChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  const OcChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: icon != null ? Icon(icon, size: 16) : null,
      selectedColor: OcColors.primary,
      checkmarkColor: OcColors.textOnPrimary,
      labelStyle: TextStyle(
        color: selected ? OcColors.textOnPrimary : OcColors.textPrimary,
        fontSize: 13,
      ),
    );
  }
}

/// Star rating display widget.
class OcRating extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double starSize;

  const OcRating({
    super.key,
    required this.rating,
    this.totalReviews = 0,
    this.starSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final filled = index < rating.floor();
          final half = index == rating.floor() && rating % 1 >= 0.5;
          return Icon(
            filled
                ? Icons.star_rounded
                : half
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            color: OcColors.secondary,
            size: starSize,
          );
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: OcColors.textSecondary,
            fontSize: starSize - 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (totalReviews > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($totalReviews)',
            style: TextStyle(
              color: OcColors.textSecondary,
              fontSize: starSize - 4,
            ),
          ),
        ],
      ],
    );
  }
}

/// Badge counter for nav items / notifications.
class OcBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const OcBadge({super.key, required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: OcColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: OcColors.textOnPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Status badge — colored pill for order/approval statuses.
class OcStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const OcStatusBadge({
    super.key,
    required this.label,
    this.color = OcColors.info,
  });

  factory OcStatusBadge.fromOrderStatus(String status) {
    final color = switch (status) {
      'pending' => OcColors.warning,
      'confirmed' || 'preparing' => OcColors.info,
      'ready_for_pickup' || 'picked_up' || 'in_transit' => OcColors.secondary,
      'delivered' || 'completed' => OcColors.success,
      'cancelled' => OcColors.error,
      'disputed' => OcColors.error,
      _ => OcColors.textSecondary,
    };
    return OcStatusBadge(label: status, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(OcRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Shimmer loading card placeholder.
class OcShimmerCard extends StatelessWidget {
  final double height;
  final double? width;

  const OcShimmerCard({super.key, this.height = 120, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: OcColors.surfaceLight,
        borderRadius: BorderRadius.circular(OcRadius.lg),
      ),
    );
  }
}

/// Empty state widget with icon + message.
class OcEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const OcEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OcSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: OcColors.textSecondary),
            const SizedBox(height: OcSpacing.lg),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: OcColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: OcSpacing.lg),
              OcButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget with retry.
class OcErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const OcErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OcSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: OcColors.error),
            const SizedBox(height: OcSpacing.lg),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: OcColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: OcSpacing.lg),
              OcButton(
                label: 'إعادة المحاولة',
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
