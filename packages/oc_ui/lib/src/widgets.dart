import 'package:flutter/material.dart';
import 'tokens.dart';

// ────────────────────────────────────────────────────────
// 1. OcButton — Lime green primary button
// ────────────────────────────────────────────────────────

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
            height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: OcColors.onAccent),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    if (outlined) {
      return OutlinedButton(onPressed: isLoading ? null : onPressed, child: child);
    }
    return ElevatedButton(onPressed: isLoading ? null : onPressed, child: child);
  }
}

// ────────────────────────────────────────────────────────
// 2. OcFloatingNavBar — Dark pill floating bottom nav
// ────────────────────────────────────────────────────────

class OcNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const OcNavItem({required this.icon, required this.label, IconData? activeIcon})
      : activeIcon = activeIcon ?? icon;
}

class OcFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<OcNavItem> items;

  const OcFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: OcSpacing.xl,
        right: OcSpacing.xl,
        bottom: OcSizes.navBarBottomMargin,
      ),
      height: OcSizes.navBarHeight,
      decoration: BoxDecoration(
        color: OcColors.navBar,
        borderRadius: BorderRadius.circular(OcRadius.navBar),
        boxShadow: OcShadows.navBar,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isActive = i == currentIndex;

          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 14 : 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isActive ? OcColors.navActive : Colors.transparent,
                borderRadius: BorderRadius.circular(OcRadius.lg),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: OcSizes.iconSize,
                    color: isActive ? OcColors.onAccent : OcColors.navIcon,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: OcColors.onAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 3. OcSearchBar — Light gray pill search input
// ────────────────────────────────────────────────────────

class OcSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const OcSearchBar({
    super.key,
    this.hint = 'بحث...',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: OcSizes.searchBarHeight,
        padding: const EdgeInsets.symmetric(horizontal: OcSpacing.lg),
        decoration: BoxDecoration(
          color: OcColors.surfaceLight,
          borderRadius: BorderRadius.circular(OcRadius.searchBar),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: OcColors.textMuted, size: 20),
            const SizedBox(width: OcSpacing.sm),
            Expanded(
              child: readOnly
                  ? Text(hint, style: const TextStyle(color: OcColors.textMuted, fontSize: 15))
                  : TextField(
                      onChanged: onChanged,
                      style: const TextStyle(fontSize: 15, color: OcColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        hintStyle: const TextStyle(color: OcColors.textMuted),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 4. OcSectionHeader — "Title" + "See all" pattern
// ────────────────────────────────────────────────────────

class OcSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const OcSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: OcColors.textPrimary,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 14,
                  color: OcColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 5. OcCategoryChip — Active: dark fill, Inactive: bordered
// ────────────────────────────────────────────────────────

class OcCategoryChips extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const OcCategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: OcSizes.chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: OcSpacing.sm),
        itemBuilder: (_, i) {
          final isActive = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? OcColors.chipActive : OcColors.chipInactive,
                borderRadius: BorderRadius.circular(OcRadius.chip),
                border: isActive ? null : Border.all(color: OcColors.chipBorder),
              ),
              child: Text(
                categories[i],
                style: TextStyle(
                  color: isActive ? Colors.white : OcColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 6. OcHeroBanner — Carousel card with text overlay
// ────────────────────────────────────────────────────────

class OcHeroBanner extends StatelessWidget {
  final List<OcBannerItem> items;
  final double height;
  final PageController? controller;

  const OcHeroBanner({
    super.key,
    required this.items,
    this.height = OcSizes.bannerHeight,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: controller ?? PageController(viewportFraction: 0.92),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(OcRadius.banner),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  Container(
                    decoration: BoxDecoration(
                      color: OcColors.surfaceCard,
                      image: item.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(item.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Text content
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 2,
                          ),
                        ],
                        if (item.buttonLabel != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: OcColors.accent,
                              borderRadius: BorderRadius.circular(OcRadius.lg),
                            ),
                            child: Text(
                              item.buttonLabel!,
                              style: const TextStyle(
                                color: OcColors.onAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class OcBannerItem {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? buttonLabel;
  final VoidCallback? onTap;

  const OcBannerItem({
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.buttonLabel,
    this.onTap,
  });
}

// ────────────────────────────────────────────────────────
// 7. OcProductCard — Grid card with discount badge + rating
// ────────────────────────────────────────────────────────

class OcProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String? imageUrl;
  final String? category;
  final double? rating;
  final int? discount;
  final int? stockLeft;
  final VoidCallback? onTap;

  const OcProductCard({
    super.key,
    required this.name,
    required this.price,
    this.imageUrl,
    this.category,
    this.rating,
    this.discount,
    this.stockLeft,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container — expands to fill available space
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: OcColors.surfaceCard,
                borderRadius: BorderRadius.circular(OcRadius.card),
                image: imageUrl != null
                    ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: Stack(
                children: [
                  if (discount != null && discount! > 0)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: OcColors.accent,
                          borderRadius: BorderRadius.circular(OcRadius.sm),
                        ),
                        child: Text(
                          '-$discount%',
                          style: const TextStyle(color: OcColors.onAccent, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Category pill
          if (category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: OcColors.accent,
                borderRadius: BorderRadius.circular(OcRadius.sm),
              ),
              child: Text(
                category!,
                style: const TextStyle(color: OcColors.onAccent, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),

          // Stock count
          if (stockLeft != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('$stockLeft متبقي', style: const TextStyle(color: OcColors.textMuted, fontSize: 11)),
            ),

          // Product name
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              name,
              style: const TextStyle(color: OcColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Price + Rating row
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                if (rating != null) ...[
                  Icon(Icons.star_rounded, size: 14, color: OcColors.starAmber),
                  const SizedBox(width: 2),
                  Text(rating!.toStringAsFixed(1), style: const TextStyle(color: OcColors.textSecondary, fontSize: 12)),
                  const Spacer(),
                ],
                Text(price, style: const TextStyle(color: OcColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                if (rating == null) const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 8. OcChip — Legacy filter chip
// ────────────────────────────────────────────────────────

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
      selectedColor: OcColors.chipActive,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : OcColors.textPrimary,
        fontSize: 13,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 9. OcRating — Star rating display
// ────────────────────────────────────────────────────────

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
            filled ? Icons.star_rounded : half ? Icons.star_half_rounded : Icons.star_outline_rounded,
            color: OcColors.starAmber,
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
            style: TextStyle(color: OcColors.textSecondary, fontSize: starSize - 4),
          ),
        ],
      ],
    );
  }
}

// ────────────────────────────────────────────────────────
// 10. OcBadge — Count badge for nav/cart
// ────────────────────────────────────────────────────────

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
            right: -6, top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: OcColors.accent, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: OcColors.onAccent, fontSize: 10, fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────
// 11. OcStatusBadge — Order/approval status pill
// ────────────────────────────────────────────────────────

class OcStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const OcStatusBadge({super.key, required this.label, this.color = OcColors.info});

  factory OcStatusBadge.fromOrderStatus(String status) {
    final color = switch (status) {
      'pending' => OcColors.warning,
      'confirmed' || 'preparing' => OcColors.info,
      'ready_for_pickup' || 'picked_up' || 'in_transit' => OcColors.accent,
      'delivered' || 'completed' => OcColors.success,
      'cancelled' || 'disputed' => OcColors.error,
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
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 12. OcShimmerCard — Loading placeholder
// ────────────────────────────────────────────────────────

class OcShimmerCard extends StatelessWidget {
  final double height;
  final double? width;

  const OcShimmerCard({super.key, this.height = 120, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height, width: width,
      decoration: BoxDecoration(
        color: OcColors.surfaceLight,
        borderRadius: BorderRadius.circular(OcRadius.lg),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 13. OcEmptyState — Empty icon + message
// ────────────────────────────────────────────────────────

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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: OcColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: OcSpacing.lg),
              OcButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 14. OcErrorState — Error with retry
// ────────────────────────────────────────────────────────

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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: OcColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: OcSpacing.lg),
              OcButton(label: 'إعادة المحاولة', onPressed: onRetry, icon: Icons.refresh_rounded),
            ],
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 15. OcDiscountBanner — Sale countdown timer
// ────────────────────────────────────────────────────────

class OcCountdownBadge extends StatelessWidget {
  final String time;

  const OcCountdownBadge({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: OcColors.saleRed,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            time,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 16. OcLogo — OnlyCars brand logo (wing+checkmark)
// ────────────────────────────────────────────────────────

/// OnlyCars logo — wing speed lines + lime checkmark.
/// Use [showText] to include "OnlyCars" text beside the icon.
class OcLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool darkBackground;

  const OcLogo({
    super.key,
    this.size = 32,
    this.showText = false,
    this.darkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _LogoPainter(darkBackground: darkBackground)),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.2),
          Text(
            'OnlyCars',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w800,
              color: darkBackground ? Colors.white : OcColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  final bool darkBackground;
  _LogoPainter({this.darkBackground = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wing/speed lines (dark or white)
    final wingPaint = Paint()
      ..color = darkBackground ? Colors.white : const Color(0xFF1A1A1A)
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Three speed lines
    final line1 = Path()
      ..moveTo(w * 0.05, h * 0.35)
      ..quadraticBezierTo(w * 0.25, h * 0.2, w * 0.5, h * 0.25);
    canvas.drawPath(line1, wingPaint);

    final line2 = Path()
      ..moveTo(w * 0.08, h * 0.48)
      ..quadraticBezierTo(w * 0.3, h * 0.35, w * 0.55, h * 0.38);
    canvas.drawPath(line2, wingPaint);

    final line3 = Path()
      ..moveTo(w * 0.12, h * 0.6)
      ..quadraticBezierTo(w * 0.3, h * 0.5, w * 0.52, h * 0.5);
    canvas.drawPath(line3, wingPaint);

    // Checkmark (lime green)
    final checkPaint = Paint()
      ..color = OcColors.accent
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final check = Path()
      ..moveTo(w * 0.38, h * 0.58)
      ..lineTo(w * 0.55, h * 0.78)
      ..lineTo(w * 0.92, h * 0.22);
    canvas.drawPath(check, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
