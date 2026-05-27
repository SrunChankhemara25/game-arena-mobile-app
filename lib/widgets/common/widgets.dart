import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/media_service.dart';

// ─── Premium Tactile Glow Button ─────────────────────────────────────────────
class GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final LinearGradient? gradient;
  final Color? color;
  final double? width;
  final double height;
  final bool outline;
  final IconData? icon;
  final bool small;

  const GlowButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradient,
    this.color,
    this.width,
    this.height = 52.0,
    this.outline = false,
    this.icon,
    this.small = false,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.small ? 38.0 : widget.height;

    // Default to solid Cyan unless the brand gradient is explicitly passed
    final grad = widget.gradient;
    final isBrand = grad == AppColors.gradientBrand;
    final accentColor =
        widget.color ?? (isBrand ? AppColors.pink : AppColors.cyan);

    // High-contrast text color based on background
    final contentColor =
        widget.outline ? accentColor : (isBrand ? Colors.white : AppColors.bg0);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width,
          height: h,
          decoration: widget.outline
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                      color: accentColor.withOpacity(0.6), width: 1.5),
                  color: accentColor.withOpacity(0.04),
                )
              : BoxDecoration(
                  color: grad == null ? accentColor : null,
                  gradient: grad,
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.24),
                      blurRadius: 20.0,
                      offset: const Offset(0, 6.0),
                    )
                  ],
                ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon,
                      size: widget.small ? 14.0 : 18.0, color: contentColor),
                  const SizedBox(width: 8.0),
                ],
                Text(
                  widget.label,
                  style:
                      (widget.small ? AppText.btnSm : AppText.btnLg).copyWith(
                    color: contentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Frosted Cyber Status Badge ──────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final TournamentStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    bool pulse = false;

    // Strict mapping to the 4-color professional brand palette
    switch (status) {
      case TournamentStatus.ongoing:
        color = AppColors.red; // Live/Urgent
        pulse = true;
        break;
      case TournamentStatus.registration:
        color = AppColors.cyan; // Primary actionable state
        break;
      case TournamentStatus.upcoming:
        color = AppColors.purple; // Brand alignment for future
        break;
      case TournamentStatus.ended:
        color = AppColors.textMuted; // Inactive
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.35), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulse) ...[
            const _PulseDot(color: AppColors.red),
            const SizedBox(width: 6.0),
          ],
          Text(
            status.label,
            style: AppText.label.copyWith(
                color: color, fontSize: 10.0, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.35, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _a,
        child: Container(
          width: 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: widget.color.withOpacity(0.6),
                  blurRadius: 6.0,
                  spreadRadius: 1.0)
            ],
          ),
        ),
      );
}

// ─── Translucent Capsule Game Badge ──────────────────────────────────────────
class GameBadge extends StatelessWidget {
  final GameTitle game;
  final bool small;
  const GameBadge({super.key, required this.game, this.small = false});

  // Replaced random rainbow colors with brand-aligned categorization
  Color get _color {
    switch (game) {
      case GameTitle.mlbb:
        return AppColors.cyan;
      case GameTitle.pubg:
        return AppColors.purple;
      case GameTitle.freeFire:
        return AppColors.red;
      case GameTitle.valorant:
        return AppColors.pink;
      case GameTitle.cod:
        return AppColors.textSecondary;
      default:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: small ? 8.0 : 10.0, vertical: small ? 3.0 : 4.0),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: _color.withOpacity(0.3), width: 1.0),
        ),
        child: Text(
          '${game.emoji}  ${game.label.toUpperCase()}',
          style: AppText.label.copyWith(
              color: _color,
              fontSize: small ? 9.0 : 11.0,
              fontWeight: FontWeight.w700),
        ),
      );
}

// ─── Kinetic Section Header ──────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader(
      {super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            Container(
              width: 4.0,
              height: 18.0,
              decoration: BoxDecoration(
                color:
                    AppColors.cyan, // Replaced gradient with solid brand cyan
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const SizedBox(width: 12.0),
            Text(
              title.toUpperCase(),
              style: AppText.heading.copyWith(letterSpacing: 0.8),
            ),
            const Spacer(),
            if (actionLabel != null)
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionLabel!.toUpperCase(),
                  style: AppText.label
                      .copyWith(color: AppColors.cyan, fontSize: 11.0),
                ),
              ),
          ],
        ),
      );
}

// ─── Esports Team Crest Frame ────────────────────────────────────────────────
class TeamAvatar extends StatelessWidget {
  final TeamModel team;
  final double size;
  const TeamAvatar({super.key, required this.team, this.size = 48.0});

  @override
  Widget build(BuildContext context) {
    final image = MediaService.imageProviderFor(team.logoUrl);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: AppColors.cyan.withOpacity(0.2), width: 1.2),
        image: image == null
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
      ),
      child: image == null
          ? Center(
              child: Text(
                team.name.length >= 2
                    ? team.name.substring(0, 2).toUpperCase()
                    : team.name.toUpperCase(),
                style: AppText.displaySm.copyWith(
                    fontSize: size * 0.32,
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }
}

// ─── Halo-Ring Player Profile Ring ───────────────────────────────────────────
class PlayerAvatar extends StatelessWidget {
  final PlayerModel player;
  final double size;
  const PlayerAvatar({super.key, required this.player, this.size = 44.0});

  @override
  Widget build(BuildContext context) {
    final ringColor = _typeColor(player.type);
    final image = MediaService.imageProviderFor(player.avatarUrl);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.bg3,
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2.0),
        image: image == null
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(
            color: ringColor.withOpacity(0.15),
            blurRadius: 8.0,
          )
        ],
      ),
      child: image == null
          ? Center(
              child: Text(
                player.ign.isNotEmpty
                    ? player.ign.substring(0, 1).toUpperCase()
                    : 'P',
                style: AppText.heading.copyWith(
                    fontSize: size * 0.38,
                    color: ringColor,
                    fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }

  // Strictly brand-aligned colors
  Color _typeColor(PlayerType t) {
    switch (t) {
      case PlayerType.main:
        return AppColors.cyan;
      case PlayerType.substitute:
        return AppColors.pink;
      case PlayerType.coach:
        return AppColors.purple;
      case PlayerType.assistantCoach:
        return AppColors.textSecondary;
      default:
        return AppColors.textMuted;
    }
  }
}

// ─── High-Atmosphere Empty Placeholder ───────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.bg1,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon,
                    size: 48.0, color: AppColors.textMuted.withOpacity(0.7)),
              ),
              const SizedBox(height: 24.0),
              Text(
                title,
                style: AppText.heading
                    .copyWith(color: AppColors.textPrimary, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Text(
                subtitle,
                style: AppText.body.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

// ─── True Frosted Glass Navigation Bar ───────────────────────────────────────
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  const GlassAppBar(
      {super.key, required this.title, this.actions, this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        leading: showBack
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      size: 18.0, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,
        title: Text(title.toUpperCase(),
            style:
                AppText.heading.copyWith(fontSize: 18.0, letterSpacing: 1.0)),
        actions: actions,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(
              color: AppColors.bg0.withOpacity(0.75),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      height: 1.0, color: AppColors.border.withOpacity(0.6)),
                ],
              ),
            ),
          ),
        ),
      );
}

// ─── Obsidian Glass Stat Metric Dashboard Badge ──────────────────────────────
class StatCard extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const StatCard(
      {super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: AppDecorations.glassCard(radius: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppText.displaySm.copyWith(
                color: valueColor ?? AppColors.cyan,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              label.toUpperCase(),
              style: AppText.label
                  .copyWith(fontSize: 10.0, color: AppColors.textMuted),
            ),
          ],
        ),
      );
}

// ─── Wireframe Architectural Label Divider ───────────────────────────────────
class LabeledDivider extends StatelessWidget {
  final String label;
  const LabeledDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
              child: Divider(
                  color: AppColors.border.withOpacity(0.5), thickness: 1.0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              label.toUpperCase(),
              style: AppText.label
                  .copyWith(color: AppColors.textMuted, fontSize: 11.0),
            ),
          ),
          Expanded(
              child: Divider(
                  color: AppColors.border.withOpacity(0.5), thickness: 1.0)),
        ],
      );
}

// ─── Premium Integrated Search Conduit ────────────────────────────────────────
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  const AppSearchBar(
      {super.key,
      required this.controller,
      required this.hint,
      this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        height: 52.0,
        decoration: BoxDecoration(
          color: AppColors.bg3, // Solid fill, no border (matches your inputs)
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
          cursorColor: AppColors.cyan,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.body.copyWith(color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textSecondary, size: 20.0),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
            filled: false, // Background handled by outer container
          ),
        ),
      );
}

// ─── Structured Ledger Key-Value Matrix Row ─────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const InfoRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, size: 16.0, color: AppColors.cyan),
            const SizedBox(width: 12.0),
            Text(
              label,
              style: AppText.body.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            Text(
              value ?? '—',
              style: AppText.bodyMd.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}
