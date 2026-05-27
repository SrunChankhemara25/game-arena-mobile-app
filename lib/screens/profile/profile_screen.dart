import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../widgets/common/widgets.dart';
import '../admin/admin_dashboard.dart' as admin_dashboard;
import '../auth/change_password_screen.dart';
import '../auth/login_screen.dart';

// ─── Profile Screen ───────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  final bool isAdmin;
  final bool scrollToAlerts; // ← NEW
  const ProfileScreen({
    super.key,
    this.isAdmin = false,
    this.scrollToAlerts = false, // ← NEW
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _pulseCtrl;

  final ScrollController _scrollController = ScrollController(); // ← NEW
  final GlobalKey _alertsSectionKey = GlobalKey(); // ← NEW

  // Mutable alerts state to handle read, archive, unarchive, and deletion live
  late List<Map<String, dynamic>> _alerts;

  final _user = const UserModel(
    id: 'u1',
    name: 'Srun Chankhemara',
    email: 'khemara@email.com',
    country: 'Cambodia',
    role: UserRole.user,
    bio: 'Competitive MLBB player and team captain. Love the grind. 🎮',
  );

  @override
  void initState() {
    super.initState();

    _alerts = [
      {
        'id': '1',
        'icon': Icons.check_circle_rounded,
        'color': AppColors.green,
        'title': 'Team Approved',
        'body': 'NEXUS GAMING is approved for MPL KH Season 8.',
        'time': '1h ago',
        'read': false,
        'archived': false,
      },
      {
        'id': '2',
        'icon': Icons.schedule_rounded,
        'color': AppColors.cyan,
        'title': 'Match Scheduled',
        'body': 'vs PHOENIX ESPORTS — Jun 22, 14:00 GMT+7.',
        'time': '2h ago',
        'read': false,
        'archived': false,
      },
      {
        'id': '3',
        'icon': Icons.notifications_rounded,
        'color': AppColors.gold,
        'title': 'Registration Closing',
        'body': 'PUBG Mobile Open KH closes in 3 days.',
        'time': '1d ago',
        'read': true,
        'archived': false,
      },
      {
        'id': '4',
        'icon': Icons.military_tech_rounded,
        'color': AppColors.magenta,
        'title': 'Match Result',
        'body': 'NEXUS GAMING won 2–0 vs PHOENIX ESPORTS.',
        'time': '3d ago',
        'read': true,
        'archived': false,
      },
    ];

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // ← NEW: scroll to alerts after first frame if requested
    if (widget.scrollToAlerts) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToAlerts());
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _scrollController.dispose(); // ← NEW
    super.dispose();
  }

  // ← NEW: scroll to the alerts section
  void _scrollToAlerts() {
    final ctx = _alertsSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Helper logic to view notification details
  void _showAlertDetails(Map<String, dynamic> alert) {
    HapticFeedback.lightImpact();
    // Automatically mark as read when opened
    setState(() {
      alert['read'] = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Icon(alert['icon'] as IconData,
                color: alert['color'] as Color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                alert['title'] as String,
                style: AppText.heading.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert['body'] as String,
              style: AppText.body
                  .copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Received ${alert['time']}',
              style: AppText.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: AppText.bodyMd.copyWith(color: AppColors.cyan)),
          ),
        ],
      ),
    );
  }

  // Double check modal before permanent deletion
  void _confirmDeleteAlert(Map<String, dynamic> alert) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Delete Notification',
            style: AppText.heading.copyWith(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to permanently delete this notification? This action cannot be undone.',
          style: AppText.body
              .copyWith(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppText.bodyMd.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _alerts.removeWhere((item) => item['id'] == alert['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification deleted.')),
              );
            },
            child: Text('Delete',
                style: AppText.bodyMd.copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeAlerts =
        _alerts.where((a) => !(a['archived'] as bool)).toList();
    final archivedAlerts = _alerts.where((a) => a['archived'] as bool).toList();

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        children: [
          // ── Ambient geometry background ──────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Opacity(
                opacity: 0.03 + _pulseCtrl.value * 0.02,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cyan, width: 80),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -60,
            child: Opacity(
              opacity: 0.025,
              child: Transform.rotate(
                angle: math.pi / 6,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.cyan, width: 40),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),

          // ── Main content (Edge-to-Edge scrolling) ───────────────────
          CustomScrollView(
            controller: _scrollController, // ← NEW
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _buildTopBar(context),
              ),

              // Identity Block
              SliverToBoxAdapter(
                child: _IdentityBlock(
                  user: _user,
                  isAdmin: widget.isAdmin,
                  pulseCtrl: _pulseCtrl,
                  entranceCtrl: _entranceCtrl,
                  onAdminTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const admin_dashboard.AdminDashboard()),
                    );
                  },
                ),
              ),

              // Section: Active Alerts ← key added here
              SliverToBoxAdapter(
                child: _SectionLabel(
                  key: _alertsSectionKey, // ← NEW
                  label: 'ALERTS',
                  tag: activeAlerts.length.toString(),
                  tagColor: AppColors.cyan,
                  entranceCtrl: _entranceCtrl,
                  delay: 0.4,
                ),
              ),
              if (activeAlerts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 24),
                    child: Center(
                      child: Text('No active notifications',
                          style: AppText.caption
                              .copyWith(color: AppColors.textMuted)),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final alert = activeAlerts[i];
                      return _AlertRow(
                        key: ValueKey(alert['id']),
                        data: alert,
                        index: i,
                        entranceCtrl: _entranceCtrl,
                        onTap: () => _showAlertDetails(alert),
                        onMenuSelected: (action) {
                          if (action == 'read') {
                            setState(() => alert['read'] = true);
                          } else if (action == 'archive') {
                            setState(() => alert['archived'] = true);
                          } else if (action == 'delete') {
                            _confirmDeleteAlert(alert);
                          }
                        },
                      );
                    },
                    childCount: activeAlerts.length,
                  ),
                ),

              // Section: Archived Alerts
              if (archivedAlerts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionLabel(
                    label: 'ARCHIVED',
                    tag: archivedAlerts.length.toString(),
                    tagColor: AppColors.textMuted,
                    entranceCtrl: _entranceCtrl,
                    delay: 0.6,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final alert = archivedAlerts[i];
                      return _AlertRow(
                        key: ValueKey(alert['id']),
                        data: alert,
                        index: i + activeAlerts.length,
                        entranceCtrl: _entranceCtrl,
                        onTap: () => _showAlertDetails(alert),
                        onMenuSelected: (action) {
                          if (action == 'unarchive') {
                            setState(() => alert['archived'] = false);
                          } else if (action == 'delete') {
                            _confirmDeleteAlert(alert);
                          }
                        },
                      );
                    },
                    childCount: archivedAlerts.length,
                  ),
                ),
              ],

              SliverToBoxAdapter(
                child: SizedBox(
                    height: 120 + MediaQuery.of(context).padding.bottom),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final canPop = Navigator.canPop(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, topPad + 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (canPop)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bg1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textSecondary, size: 18),
              ),
            ),
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.cyan,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'PROFILE',
            style: AppText.heading.copyWith(
              fontSize: 22,
              letterSpacing: 4,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          _IconBtn(
            icon: Icons.settings_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(user: _user),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Identity Block ───────────────────────────────────────────────────────────
class _IdentityBlock extends StatelessWidget {
  final UserModel user;
  final bool isAdmin;
  final AnimationController pulseCtrl;
  final AnimationController entranceCtrl;
  final VoidCallback onAdminTap;

  const _IdentityBlock({
    required this.user,
    required this.isAdmin,
    required this.pulseCtrl,
    required this.entranceCtrl,
    required this.onAdminTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entranceCtrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, 30 * (1 - entranceCtrl.value)),
        child:
            Opacity(opacity: entranceCtrl.value.clamp(0.0, 1.0), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.bg1,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.cyan,
                          AppColors.cyan.withOpacity(0.0),
                        ],
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedBuilder(
                              animation: pulseCtrl,
                              builder: (_, __) => Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.bg3,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.cyan.withOpacity(
                                        0.4 + pulseCtrl.value * 0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cyan.withOpacity(
                                          0.08 + pulseCtrl.value * 0.08),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: ShaderMask(
                                        shaderCallback: (b) => AppColors
                                            .gradientCyan
                                            .createShader(b),
                                        child: Text(
                                          user.name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: AppText.displaySm.copyWith(
                                            color: Colors.white,
                                            fontSize: 36,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 6,
                                      right: 6,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: AppColors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppColors.bg1, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.cyan.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color:
                                              AppColors.cyan.withOpacity(0.2)),
                                    ),
                                    child: Text(
                                      'ID · ${user.id.toUpperCase()}',
                                      style: AppText.label.copyWith(
                                        color: AppColors.cyan,
                                        fontSize: 9,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    user.name,
                                    style: AppText.heading.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: AppText.caption.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _MiniTag(
                                        label: 'PLAYER',
                                        color: AppColors.cyan,
                                      ),
                                      const SizedBox(width: 8),
                                      _MiniTag(
                                        label: user.country ?? 'GLOBAL',
                                        color: AppColors.textMuted,
                                        icon: Icons.location_on_rounded,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (user.bio != null && user.bio!.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.bg0.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.border.withOpacity(0.5)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 2,
                                  height: 40,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.cyan,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    user.bio!,
                                    style: AppText.body.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      height: 1.55,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (isAdmin) ...[
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: onAdminTap,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.gold.withOpacity(0.35)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.admin_panel_settings_rounded,
                                      color: AppColors.gold, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'COMMAND CENTER',
                                    style: AppText.label
                                        .copyWith(color: AppColors.gold),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}

// ─── Alert Row ────────────────────────────────────────────────────────────────
class _AlertRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  final AnimationController entranceCtrl;
  final VoidCallback onTap;
  final ValueChanged<String> onMenuSelected;

  const _AlertRow({
    super.key,
    required this.data,
    required this.index,
    required this.entranceCtrl,
    required this.onTap,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = data['read'] as bool;
    final isArchived = data['archived'] as bool;
    final color = data['color'] as Color;
    final delay = 0.5 + index * 0.07;

    return AnimatedBuilder(
      animation: entranceCtrl,
      builder: (_, child) {
        final progress =
            ((entranceCtrl.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(24 * (1 - progress), 0),
          child: Opacity(opacity: progress, child: child),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
          decoration: BoxDecoration(
            color: isRead
                ? AppColors.bg1.withOpacity(0.5)
                : AppColors.bg2.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead
                  ? AppColors.border.withOpacity(0.4)
                  : color.withOpacity(0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 64,
                decoration: BoxDecoration(
                  color: isRead ? AppColors.border : color,
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(data['icon'] as IconData, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] as String,
                        style: AppText.bodyMd.copyWith(
                          color: isRead
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data['body'] as String,
                        style: AppText.body
                            .copyWith(color: AppColors.textMuted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: color.withOpacity(0.5), blurRadius: 6)
                            ],
                          ),
                        ),
                      Text(
                        data['time'] as String,
                        style: AppText.caption
                            .copyWith(fontSize: 10, color: AppColors.textMuted),
                      ),

                      // ── Three Dot Menu Container (Neutral Styling) ──
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded,
                            color: AppColors.textMuted, size: 18),
                        padding: EdgeInsets.zero,
                        color: AppColors.bg1,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        onSelected: onMenuSelected,
                        itemBuilder: (context) => [
                          if (!isRead)
                            PopupMenuItem(
                              value: 'read',
                              child: Text('Mark as read',
                                  style: AppText.body
                                      .copyWith(color: AppColors.textPrimary)),
                            ),
                          PopupMenuItem(
                            value: isArchived ? 'unarchive' : 'archive',
                            child: Text(isArchived ? 'Unarchive' : 'Archive',
                                style: AppText.body
                                    .copyWith(color: AppColors.textPrimary)),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete',
                                style: AppText.body
                                    .copyWith(color: AppColors.textPrimary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Mini Tag ─────────────────────────────────────────────────────────────────
class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _MiniTag({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppText.label.copyWith(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Icon Button ─────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}

// ─── Settings Screen ─────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  final UserModel user;
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailUpdatesEnabled = true;

  void _confirmLogout() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Confirm Sign Out',
            style: AppText.heading.copyWith(color: AppColors.textPrimary)),
        content: Text(
          'Securely disconnect your session from this device?',
          style: AppText.body
              .copyWith(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text('Cancel',
                style: AppText.bodyMd.copyWith(color: AppColors.textSecondary)),
          ),
          GlowButton(
            label: 'SIGN OUT',
            width: 110,
            height: 40,
            small: true,
            color: AppColors.red,
            gradient: LinearGradient(
                colors: [AppColors.red, AppColors.red.withOpacity(0.7)]),
            onTap: () {
              HapticFeedback.heavyImpact();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'SETTINGS'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(24, topPad + 24, 24, 24),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          _SettingsSection(
            title: 'ACCOUNT',
            items: [
              _SettingsTile(
                icon: Icons.person_rounded,
                label: 'Edit Profile',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditProfileScreen(user: widget.user)),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.lock_rounded,
                label: 'Security & Password',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen()),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.mail_rounded,
                label: 'Email Configuration',
                onTap: () => HapticFeedback.lightImpact(),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _SettingsSection(
            title: 'PREFERENCES',
            items: [
              _SettingsTile(
                icon: Icons.notifications_rounded,
                label: 'Push Notifications',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (v) {
                    HapticFeedback.lightImpact();
                    setState(() => _notificationsEnabled = v);
                  },
                  activeColor: AppColors.cyan,
                  activeTrackColor: AppColors.cyan.withOpacity(0.3),
                  inactiveThumbColor: AppColors.textMuted,
                  inactiveTrackColor: AppColors.bg3,
                ),
                onTap: null,
              ),
              _SettingsTile(
                icon: Icons.email_rounded,
                label: 'Marketing Updates',
                trailing: Switch(
                  value: _emailUpdatesEnabled,
                  onChanged: (v) {
                    HapticFeedback.lightImpact();
                    setState(() => _emailUpdatesEnabled = v);
                  },
                  activeColor: AppColors.cyan,
                  activeTrackColor: AppColors.cyan.withOpacity(0.3),
                  inactiveThumbColor: AppColors.textMuted,
                  inactiveTrackColor: AppColors.bg3,
                ),
                onTap: null,
              ),
              _SettingsTile(
                icon: Icons.language_rounded,
                label: 'Localization',
                trailing: Text('ENGLISH',
                    style: AppText.label.copyWith(color: AppColors.cyan)),
                onTap: () => HapticFeedback.lightImpact(),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _SettingsSection(
            title: 'LEGAL & SUPPORT',
            items: [
              _SettingsTile(
                icon: Icons.info_rounded,
                label: 'Client Version',
                trailing: Text('v2.4.0 PRO',
                    style: AppText.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold)),
                onTap: null,
              ),
              _SettingsTile(
                  icon: Icons.privacy_tip_rounded,
                  label: 'Privacy Policy',
                  onTap: () => HapticFeedback.lightImpact()),
              _SettingsTile(
                  icon: Icons.description_rounded,
                  label: 'Terms of Service',
                  onTap: () => HapticFeedback.lightImpact()),
              _SettingsTile(
                  icon: Icons.bug_report_rounded,
                  label: 'Submit Bug Report',
                  onTap: () => HapticFeedback.lightImpact()),
            ],
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _confirmLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.power_settings_new_rounded,
                      color: AppColors.red, size: 20),
                  const SizedBox(width: 16),
                  Text('SIGN OUT',
                      style: AppText.label.copyWith(color: AppColors.red)),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.red, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(title,
              style: AppText.label.copyWith(
                  color: AppColors.textMuted, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.glassCard(radius: 20),
          child: Column(
            children: items.asMap().entries.map((e) {
              return Column(
                children: [
                  e.value,
                  if (e.key < items.length - 1)
                    Divider(
                        color: AppColors.border.withOpacity(0.5),
                        height: 1,
                        indent: 48),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label,
          style: AppText.bodyMd.copyWith(color: AppColors.textPrimary)),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20)
              : null),
      onTap: onTap,
    );
  }
}

// ─── Edit Profile Screen ──────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _countryController = TextEditingController(text: widget.user.country);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'EDIT IDENTITY',
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('SAVE',
                  style: AppText.label
                      .copyWith(color: AppColors.cyan, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, topPad + 24, 24, 24),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.bg3.withOpacity(0.5),
                          border: Border.all(color: AppColors.cyan, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.cyan.withOpacity(0.2),
                                blurRadius: 16)
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.user.name.isNotEmpty
                                ? widget.user.name.substring(0, 1).toUpperCase()
                                : 'U',
                            style: AppText.displaySm
                                .copyWith(color: AppColors.cyan, fontSize: 40),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.cyan,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.bg0, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: AppDecorations.glassCard(radius: 24),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('DISPLAY NAME'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      style:
                          AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_rounded,
                            color: AppColors.textMuted, size: 20),
                        hintText: 'Your public alias',
                      ),
                    ),
                    const SizedBox(height: 24),
                    _label('BIOGRAPHY'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 4,
                      style:
                          AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Tell the community about yourself...',
                      ),
                    ),
                    const SizedBox(height: 24),
                    _label('REGION / COUNTRY'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _countryController,
                      style:
                          AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_on_rounded,
                            color: AppColors.textMuted, size: 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GlowButton(
                      label: 'CONFIRM CHANGES',
                      width: double.infinity,
                      icon: Icons.check_circle_outline_rounded,
                      onTap: _saveProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppText.label.copyWith(
            color: AppColors.textSecondary, fontWeight: FontWeight.bold),
      );
}

// ─── Profile Helpers (Section label) ──────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final String? tag;
  final Color? tagColor;
  final AnimationController entranceCtrl;
  final double delay;

  const _SectionLabel({
    super.key, // ← accepts key from parent (used by _alertsSectionKey)
    required this.label,
    this.tag,
    this.tagColor,
    required this.entranceCtrl,
    this.delay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entranceCtrl,
      builder: (_, child) {
        final progress =
            ((entranceCtrl.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(24 * (1 - progress), 0),
          child: Opacity(opacity: progress, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        child: Row(
          children: [
            Text(label,
                style: AppText.label.copyWith(
                    color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (tag != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (tagColor ?? AppColors.cyan).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: (tagColor ?? AppColors.cyan).withOpacity(0.25)),
                ),
                child: Text(tag!,
                    style: AppText.label
                        .copyWith(color: tagColor ?? AppColors.cyan)),
              ),
          ],
        ),
      ),
    );
  }
}
