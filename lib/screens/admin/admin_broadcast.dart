import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/backend_service.dart';
import 'core_shared.dart';

class AdminBroadcastView extends StatefulWidget {
  const AdminBroadcastView({super.key});

  @override
  State<AdminBroadcastView> createState() => _AdminBroadcastViewState();
}

class _AdminBroadcastViewState extends State<AdminBroadcastView> {
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _toAll = true;

  List<BroadcastRecord> _history = [];
  StreamSubscription<List<BroadcastRecord>>? _historySub;

  @override
  void initState() {
    super.initState();
    DB.initialize().then((_) {
      if (mounted) setState(() {});
    });
    // Subscribe to real-time broadcast history from Firestore
    _historySub = DB.watchBroadcastHistory().listen((records) {
      if (mounted) setState(() => _history = records);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    _emailCtrl.dispose();
    _historySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: cardDecor(
                radius: 26,
                border: AC.cyan.withOpacity(0.16),
                elevated: true,
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AC.gradPrimaryVert,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AC.bg0,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Broadcast Center', style: AT.heading),
                        const SizedBox(height: 6),
                        Text(
                          'Send announcements to every user or target a single account.',
                          style: AT.body.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Target ───────────────────────────────────────────────────
            const SectionHdr(title: 'TARGET'),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: cardDecor(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AC.bg3,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AC.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TargetToggle(
                            label: 'All Users',
                            isActive: _toAll,
                            onTap: () => setState(() => _toAll = true),
                          ),
                        ),
                        Expanded(
                          child: _TargetToggle(
                            label: 'Specific User',
                            isActive: !_toAll,
                            onTap: () => setState(() => _toAll = false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Specific user — type email manually only
                  if (!_toAll) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailCtrl,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: AC.textPrimary),
                      keyboardType: TextInputType.emailAddress,
                      decoration: fieldDecor(
                        hint: 'Enter user email',
                        icon: Icons.alternate_email_rounded,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Message ──────────────────────────────────────────────────
            const SectionHdr(title: 'MESSAGE'),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: cardDecor(),
              child: Column(
                children: [
                  TextField(
                    controller: _titleCtrl,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                      hint: 'Notification title',
                      icon: Icons.title_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageCtrl,
                    maxLines: 6,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: AC.textPrimary),
                    decoration: fieldDecor(
                      hint: 'Type your notification message...',
                      icon: Icons.message_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Preview ──────────────────────────────────────────────────
            const SectionHdr(title: 'PREVIEW'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: cardDecor(border: AC.borderStrong),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AC.cyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_rounded,
                            color: AC.cyan, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _titleCtrl.text.trim().isEmpty
                              ? 'GameArena Update'
                              : _titleCtrl.text.trim(),
                          style: AT.subheading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _messageCtrl.text.trim().isEmpty
                        ? 'Your announcement preview will appear here.'
                        : _messageCtrl.text.trim(),
                    style: AT.body,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _toAll
                        ? 'Recipient: all users'
                        : 'Recipient: ${_emailCtrl.text.trim().isEmpty ? 'not selected' : _emailCtrl.text.trim()}',
                    style: AT.caption.copyWith(color: AC.cyan),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // ── Send button ──────────────────────────────────────────────
            GradButton(
              label: 'SEND NOTIFICATION',
              width: double.infinity,
              icon: Icons.send_rounded,
              onTap: _sendBroadcast,
            ),
            const SizedBox(height: 32),

            // ── History ──────────────────────────────────────────────────
            if (_history.isNotEmpty) ...[
              const SectionHdr(title: 'HISTORY'),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final record =
                      _history[index]; // sorted newest-first by stream
                  return _BroadcastHistoryTile(
                    record: record,
                    onDelete: () => _confirmDelete(record),
                    onTap: () => _showDetail(record),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _sendBroadcast() async {
    final message = _messageCtrl.text.trim();
    final target = _emailCtrl.text.trim();

    if (message.isEmpty) return;
    if (!_toAll && target.isEmpty) return;

    final now = DateTime.now();
    final resolvedTitle = _titleCtrl.text.trim().isEmpty
        ? 'GameArena Update'
        : _titleCtrl.text.trim();

    await DB.sendBroadcast(
      title: resolvedTitle,
      message: message,
      email: _toAll ? null : target,
    );

    // Persist the broadcast record to Firestore so history survives sessions
    await DB.saveBroadcastRecord(
      BroadcastRecord(
        id: 'broadcast_${now.millisecondsSinceEpoch}',
        title: resolvedTitle,
        message: message,
        recipient: _toAll ? 'All users' : target,
        sentAt: now,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _toAll ? 'Broadcast sent to all users' : 'Broadcast sent to $target',
        ),
        backgroundColor: AC.bg3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    _titleCtrl.clear();
    _messageCtrl.clear();
    if (!_toAll) _emailCtrl.clear();
  }

  void _confirmDelete(BroadcastRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AC.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Broadcast?', style: AT.subheading),
        content: Text(
          'Are you sure you want to delete "${record.title}"? This cannot be undone.',
          style: AT.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AT.body.copyWith(color: AC.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await DB.deleteBroadcastRecord(record.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Broadcast deleted'),
                  backgroundColor: AC.bg3,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              );
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showDetail(BroadcastRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BroadcastDetailSheet(record: record),
    );
  }
}

// ── Detail bottom sheet ───────────────────────────────────────────────────────

class _BroadcastDetailSheet extends StatelessWidget {
  final BroadcastRecord record;

  const _BroadcastDetailSheet({required this.record});

  String _formatFull(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AC.bg1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AC.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AC.cyan.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.campaign_rounded,
                    color: AC.cyan, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(record.title, style: AT.heading)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _InfoChip(
                icon: Icons.people_rounded,
                label: record.recipient,
              ),
              const SizedBox(width: 10),
              _InfoChip(
                icon: Icons.access_time_rounded,
                label: _formatFull(record.sentAt),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AC.border, thickness: 1),
          const SizedBox(height: 16),
          Text('MESSAGE', style: AT.caption.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: cardDecor(),
            child: Text(record.message, style: AT.body),
          ),
          const SizedBox(height: 24),
          GradButton(
            label: 'CLOSE',
            width: double.infinity,
            icon: Icons.close_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AC.bg3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AC.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AC.cyan, size: 13),
          const SizedBox(width: 6),
          Text(label,
              style: AT.caption.copyWith(color: AC.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── History tile ──────────────────────────────────────────────────────────────

class _BroadcastHistoryTile extends StatelessWidget {
  final BroadcastRecord record;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _BroadcastHistoryTile({
    required this.record,
    required this.onDelete,
    required this.onTap,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        decoration: cardDecor(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AC.cyan.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.campaign_rounded, color: AC.cyan, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.title, style: AT.subheading),
                  const SizedBox(height: 2),
                  Text(
                    record.message,
                    style: AT.body.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people_rounded,
                          color: AC.textMuted, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          record.recipient,
                          style: AT.caption.copyWith(color: AC.cyan),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time_rounded,
                          color: AC.textMuted, size: 12),
                      const SizedBox(width: 4),
                      Text(_formatDate(record.sentAt), style: AT.caption),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              color: AC.bg3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              icon: const Icon(Icons.more_vert_rounded,
                  color: AC.textMuted, size: 20),
              onSelected: (value) {
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent, size: 18),
                      const SizedBox(width: 10),
                      Text('Delete',
                          style: AT.body.copyWith(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Target toggle ─────────────────────────────────────────────────────────────

class _TargetToggle extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TargetToggle({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive ? AC.gradPrimary : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AC.bg0 : AC.textMuted,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
