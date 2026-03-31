import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class _MockConversation {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastTime;
  final int unread;
  final bool hasVoiceNote;
  _MockConversation(this.id, this.name, this.lastMessage, this.lastTime, this.unread, {this.hasVoiceNote = false});
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final convos = [
      _MockConversation('c001', 'Alphonse Nkemba', 'Bonjour, est-ce que le cuivre est encore disponible ?',
          DateTime.now().subtract(const Duration(minutes: 5)), 2),
      _MockConversation('c002', 'Marie-Claire Fouda', '🎤 Note vocale',
          DateTime.now().subtract(const Duration(hours: 1)), 0, hasVoiceNote: true),
      _MockConversation('c003', 'Paul Essomba', 'Quel est le prix minimum que vous acceptez ?',
          DateTime.now().subtract(const Duration(hours: 3)), 1),
      _MockConversation('c004', 'Ibrahim Adamou', 'D\'accord, je passe demain matin.',
          DateTime.now().subtract(const Duration(days: 1)), 0),
      _MockConversation('c005', 'Christelle Bello', 'Merci beaucoup pour la transaction !',
          DateTime.now().subtract(const Duration(days: 2)), 0),
    ];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Messages')),
      body: convos.isEmpty
          ? const _EmptyMessages()
          : ListView.separated(
              itemCount: convos.length,
              separatorBuilder: (_, __) => const Divider(height: 0, indent: 76),
              itemBuilder: (context, i) {
                final c = convos[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: _Avatar(name: c.name, unread: c.unread),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(c.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: c.unread > 0 ? FontWeight.w700 : FontWeight.w500,
                            )),
                      ),
                      Text(
                        _formatTime(c.lastTime),
                        style: TextStyle(
                          fontSize: 11,
                          color: c.unread > 0 ? AppTheme.primary : AppTheme.textHint,
                          fontWeight: c.unread > 0 ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        if (c.hasVoiceNote)
                          const Icon(Icons.mic, size: 14, color: AppTheme.primary),
                        Expanded(
                          child: Text(
                            c.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: c.unread > 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                              fontWeight: c.unread > 0 ? FontWeight.w500 : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (c.unread > 0)
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                            child: Center(
                              child: Text('${c.unread}',
                                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  onTap: () => context.go('/messages/${c.id}', extra: c.name),
                );
              },
            ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final int unread;
  const _Avatar({required this.name, required this.unread});

  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').take(2).map((s) => s.isNotEmpty ? s[0] : '').join();
    return Stack(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary),
            ),
          ),
        ),
        if (unread > 0)
          Positioned(
            right: 0, top: 0,
            child: Container(
              width: 14, height: 14,
              decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2)),
            ),
          ),
      ],
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          Text('Aucun message', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('Vos conversations apparaîtront ici', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
