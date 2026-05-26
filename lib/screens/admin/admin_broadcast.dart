import 'package:flutter/material.dart';

import 'core_shared.dart';

class AdminBroadcastView extends StatefulWidget {
  const AdminBroadcastView({super.key});

  @override
  State<AdminBroadcastView> createState() => _AdminBroadcastViewState();
}

class _AdminBroadcastViewState extends State<AdminBroadcastView> {
  bool _toAll = true;
  String? _selectedEmail;
  final _emailCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  if (!_toAll) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedEmail,
                      dropdownColor: AC.bg3,
                      style: const TextStyle(
                        color: AC.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: fieldDecor(
                        hint: 'Select a user',
                        icon: Icons.person_rounded,
                      ),
                      items: DB.users
                          .map(
                            (user) => DropdownMenuItem<String>(
                              value: user.email,
                              child: Text(
                                '${user.name} (${user.email})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedEmail = value;
                          _emailCtrl.text = value ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailCtrl,
                      style: const TextStyle(color: AC.textPrimary),
                      decoration: fieldDecor(
                        hint: 'Or type email manually',
                        icon: Icons.alternate_email_rounded,
                      ),
                      onChanged: (value) {
                        if (_selectedEmail != value) {
                          setState(() => _selectedEmail = null);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
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
            GradButton(
              label: 'SEND NOTIFICATION',
              width: double.infinity,
              icon: Icons.send_rounded,
              onTap: _sendBroadcast,
            ),
          ],
        ),
      ),
    );
  }

  void _sendBroadcast() {
    final message = _messageCtrl.text.trim();
    final target = _emailCtrl.text.trim();

    if (message.isEmpty) return;
    if (!_toAll && target.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _toAll
              ? 'Broadcast sent to all users'
              : 'Broadcast sent to ${target.isEmpty ? 'selected user' : target}',
        ),
        backgroundColor: AC.bg3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    _titleCtrl.clear();
    _messageCtrl.clear();
    if (!_toAll) {
      _emailCtrl.clear();
    }
    setState(() {
      if (!_toAll) {
        _selectedEmail = null;
      }
    });
  }
}

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
