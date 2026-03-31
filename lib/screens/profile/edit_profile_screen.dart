import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bizCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _nameCtrl = TextEditingController(text: user?.fullName);
    _phoneCtrl = TextEditingController(text: user?.phone);
    _bizCtrl = TextEditingController(text: user?.businessName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bizCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 40, color: AppTheme.primary),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Nom complet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(controller: _nameCtrl,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 16),
            Text('Téléphone', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(controller: _phoneCtrl,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 16),
            Text('Nom de l\'entreprise (optionnel)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(controller: _bizCtrl,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.business_outlined))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Enregistrer les modifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
