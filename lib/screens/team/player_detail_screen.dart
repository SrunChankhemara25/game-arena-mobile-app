import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common/widgets.dart';

// ─── Player Detail Screen ─────────────────────────────────────────────────────
class PlayerDetailScreen extends StatefulWidget {
  final PlayerModel player;
  const PlayerDetailScreen({super.key, required this.player});

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  Color get _typeColor {
    switch (widget.player.type) {
      case PlayerType.main:
        return AppColors.cyan;
      case PlayerType.substitute:
        return AppColors.gold;
      case PlayerType.coach:
        return AppColors.purple;
      case PlayerType.assistantCoach:
        return AppColors.magenta;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _entranceController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final themeColor = _typeColor;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        children: [
          // Ambient role lighting
          Positioned(
            top: -100,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColor.withOpacity(0.08),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bg3.withOpacity(0.2),
                ),
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: AppColors.bg0.withOpacity(0.85),
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppColors.textPrimary),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        _PlayerHero(player: player, typeColor: themeColor),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Bar
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: themeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: themeColor.withOpacity(0.4)),
                                ),
                                child: Text(
                                  player.type.label.toUpperCase(),
                                  style: AppText.label.copyWith(
                                      color: themeColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.green.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_user_rounded,
                                        size: 14, color: AppColors.green),
                                    const SizedBox(width: 6),
                                    Text('IDENTITY SECURED',
                                        style: AppText.label
                                            .copyWith(color: AppColors.green)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 36),

                          // Identity & Clearance
                          const _SectionTitle(title: 'IDENTITY & CLEARANCE'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: AppDecorations.glassCard(
                                radius: 20,
                                customBorderColor: themeColor.withOpacity(0.2)),
                            child: Column(
                              children: [
                                InfoRow(
                                    icon: Icons.badge_rounded,
                                    label: 'Legal Name',
                                    value: player.fullName ?? '—'),
                                _Divider(),
                                InfoRow(
                                    icon: Icons.sports_esports_rounded,
                                    label: 'In-Game Alias',
                                    value: player.ign),
                                _Divider(),
                                InfoRow(
                                    icon: Icons.shield_rounded,
                                    label: 'Combat Role',
                                    value: player.role ?? '—'),
                                _Divider(),
                                InfoRow(
                                    icon: Icons.public_rounded,
                                    label: 'Region',
                                    value: player.nationality ?? '—'),
                                if (player.dob != null) ...[
                                  _Divider(),
                                  InfoRow(
                                      icon: Icons.cake_rounded,
                                      label: 'Date of Birth',
                                      value: player.dob!),
                                ],
                                if (player.jerseyNumber != null) ...[
                                  _Divider(),
                                  InfoRow(
                                      icon: Icons.numbers_rounded,
                                      label: 'Jersey No.',
                                      value: '#${player.jerseyNumber}'),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Platform Protocols
                          const _SectionTitle(title: 'PLATFORM PROTOCOLS'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: AppDecorations.glassCard(radius: 20),
                            child: Column(
                              children: [
                                InfoRow(
                                    icon: Icons.memory_rounded,
                                    label: 'Game UID Mapping',
                                    value: player.gameUID ?? 'Pending'),
                                _Divider(),
                                InfoRow(
                                    icon: Icons.folder_shared_rounded,
                                    label: 'Document Ledger',
                                    value: player.idType ?? 'Not specified'),
                                _Divider(),
                                Row(
                                  children: [
                                    const Icon(Icons.lock_rounded,
                                        size: 16, color: AppColors.cyan),
                                    const SizedBox(width: 12),
                                    Text('Encryption Status',
                                        style: AppText.body.copyWith(
                                            color: AppColors.textSecondary)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color:
                                              AppColors.cyan.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Text('VERIFIED',
                                          style: AppText.label.copyWith(
                                              color: AppColors.cyan,
                                              fontSize: 10)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Local Helpers ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: AppText.label.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ));
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
        color: AppColors.border.withOpacity(0.5), height: 24, thickness: 1);
  }
}

// ─── Player Hero ──────────────────────────────────────────────────────────────
class _PlayerHero extends StatelessWidget {
  final PlayerModel player;
  final Color typeColor;

  const _PlayerHero({required this.player, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.bg0.withOpacity(0.6),
                  AppColors.bg0,
                ],
                stops: const [0.4, 0.8, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          right: -20,
          bottom: 20,
          child: Opacity(
            opacity: 0.03,
            child: Text(
              player.ign.split('.').last.toUpperCase(),
              style: const TextStyle(
                fontSize: 100,
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -2,
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bg3.withOpacity(0.6),
                        border: Border.all(color: typeColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: typeColor.withOpacity(0.25),
                              blurRadius: 24,
                              spreadRadius: 2)
                        ],
                      ),
                      child: Center(
                        child: Text(
                          player.ign.isNotEmpty
                              ? player.ign.substring(0, 1).toUpperCase()
                              : 'P',
                          style: AppText.displaySm.copyWith(
                              color: typeColor,
                              fontSize: 36,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.ign,
                            style: AppText.displaySm.copyWith(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            player.fullName ?? 'Identity Hidden',
                            style: AppText.body.copyWith(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: typeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: typeColor.withOpacity(0.4)),
                                ),
                                child: Text(
                                  (player.role ?? 'FLEX').toUpperCase(),
                                  style: AppText.label
                                      .copyWith(color: typeColor, fontSize: 10),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.location_on_rounded,
                                  size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                player.nationality ?? 'Earth',
                                style: AppText.caption
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
