import 'package:flutter/material.dart';
import '../../theme.dart';

class _Notif {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final bool unread;
  const _Notif(this.icon, this.color, this.title, this.body, this.time, {this.unread = false});
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifs = [
      const _Notif(Icons.chat_bubble_outline, AppTheme.primary,
          'Nouveau message', 'Alphonse Nkemba vous a contacté pour votre annonce de cuivre.',
          'Il y a 5 min', unread: true),
      const _Notif(Icons.visibility_outlined, AppTheme.accent,
          '15 nouvelles vues', 'Votre annonce "Cuivre câbles" a été vue 15 fois aujourd\'hui.',
          'Il y a 1h', unread: true),
      const _Notif(Icons.local_offer_outlined, AppTheme.rust,
          'Nouvelle offre', 'Marie Fouda a fait une offre pour votre ferraille : 1600 CFA/kg.',
          'Il y a 3h'),
      const _Notif(Icons.star_outline, AppTheme.accent,
          'Nouveau avis', 'Paul Essomba vous a laissé un avis 5 étoiles !',
          'Hier'),
      const _Notif(Icons.recycling, AppTheme.primary,
          'Bienvenue sur MetalLink CM !', 'Votre compte a été créé avec succès. Publiez votre première annonce.',
          'Il y a 2 jours'),
    ];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Tout lire'),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: notifs.length,
        separatorBuilder: (_, __) => const Divider(height: 0, indent: 72),
        itemBuilder: (context, i) {
          final n = notifs[i];
          return Container(
            color: n.unread ? n.color.withOpacity(0.04) : null,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: n.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(n.icon, color: n.color, size: 22),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(n.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: n.unread ? FontWeight.w700 : FontWeight.w500,
                        )),
                  ),
                  if (n.unread)
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: n.color, shape: BoxShape.circle),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(n.body, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary, height: 1.4,
                  )),
                  const SizedBox(height: 4),
                  Text(n.time, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
