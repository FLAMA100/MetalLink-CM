import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/auth_service.dart';
import '../../services/listing_service.dart';
import '../../models/user.dart';
import '../../models/scrap_listing.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final listings = context.watch<ListingService>();
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(body: Center(child: ElevatedButton(
        onPressed: () => context.go('/login'),
        child: const Text('Se connecter'),
      )));
    }

    final myListings = listings.activeListings.where((l) => l.sellerId == user.id).toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppTheme.cardBg,
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        user.fullName.split(' ').take(2).map((s) => s.isNotEmpty ? s[0] : '').join().toUpperCase(),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(user.fullName, style: Theme.of(context).textTheme.headlineMedium),
                  if (user.businessName != null) ...[
                    const SizedBox(height: 4),
                    Text(user.businessName!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 8),
                  // Tags
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Tag(label: user.userType.displayName, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      _Tag(label: user.city, color: AppTheme.rust),
                      if (user.isVerified) ...[
                        const SizedBox(width: 8),
                        _Tag(label: '✓ Vérifié', color: AppTheme.success),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(value: '${user.totalListings}', label: 'Annonces'),
                      Container(width: 1, height: 32, color: AppTheme.divider),
                      _Stat(value: '${user.totalSales}', label: 'Ventes'),
                      Container(width: 1, height: 32, color: AppTheme.divider),
                      _Stat(
                        value: user.rating > 0 ? user.rating.toStringAsFixed(1) : '—',
                        label: 'Note',
                        icon: user.rating > 0 ? Icons.star : null,
                        iconColor: AppTheme.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Info
            Container(
              color: AppTheme.cardBg,
              child: Column(
                children: [
                  _InfoRow(icon: Icons.phone_outlined, label: 'Téléphone', value: user.phone),
                  if (user.email != null)
                    _InfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email!),
                  _InfoRow(icon: Icons.calendar_today_outlined, label: 'Membre depuis',
                      value: '${user.joinedAt.day}/${user.joinedAt.month}/${user.joinedAt.year}'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // My listings
            Container(
              color: AppTheme.cardBg,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mes annonces actives', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (myListings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.textHint),
                            const SizedBox(height: 8),
                            Text('Aucune annonce pour l\'instant',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Publier une annonce'),
                              onPressed: () => context.go('/create-listing'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...myListings.take(3).map((l) => _MyListingRow(listing: l)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Settings
            Container(
              color: AppTheme.cardBg,
              child: Column(
                children: [
                  _SettingRow(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
                  _SettingRow(icon: Icons.privacy_tip_outlined, label: 'Confidentialité', onTap: () {}),
                  _SettingRow(icon: Icons.help_outline, label: 'Aide & Support', onTap: () {}),
                  _SettingRow(icon: Icons.info_outline, label: 'À propos', onTap: () {}),
                  _SettingRow(
                    icon: Icons.logout_outlined,
                    label: 'Déconnexion',
                    color: AppTheme.rust,
                    onTap: () async {
                      await auth.logout();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
  );
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;
  const _Stat({required this.value, required this.label, this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: iconColor), const SizedBox(width: 3)],
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
      const SizedBox(height: 2),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 14),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textPrimary, fontWeight: FontWeight.w500,
        )),
      ],
    ),
  );
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _SettingRow({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppTheme.textSecondary),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(fontSize: 15, color: color ?? AppTheme.textPrimary))),
          Icon(Icons.chevron_right, size: 18, color: color ?? AppTheme.textHint),
        ],
      ),
    ),
  );
}

class _MyListingRow extends StatelessWidget {
  final ScrapListing listing;
  const _MyListingRow({required this.listing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(listing.metalType.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${listing.weightKg}kg · ${listing.pricePerKg.toStringAsFixed(0)} CFA/kg',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: AppTheme.textHint),
        ],
      ),
    ),
  );
}
