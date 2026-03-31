import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+237 ');
  final _passCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bizCtrl = TextEditingController();
  UserType _userType = UserType.seller;
  bool _obscurePass = true;
  int _step = 0;

  final List<String> _cameroonCities = [
    'Yaoundé', 'Douala', 'Bafoussam', 'Bamenda', 'Garoua',
    'Maroua', 'Ngaoundéré', 'Bertoua', 'Ebolowa', 'Kumba',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _cityCtrl.dispose();
    _bizCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final ok = await auth.register(
      fullName: _nameCtrl.text,
      phone: _phoneCtrl.text,
      password: _passCtrl.text,
      userType: _userType,
      city: _cityCtrl.text,
      businessName: _bizCtrl.text.isNotEmpty ? _bizCtrl.text : null,
    );
    if (ok && mounted) context.go('/home');
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Votre rôle', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Comment allez-vous utiliser MetalLink CM ?',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        ...UserType.values.map((type) => _RoleCard(
          userType: type,
          selected: _userType == type,
          onTap: () => setState(() => _userType = type),
        )),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text('Continuer'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vos informations', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        _label('Nom complet'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Jean-Baptiste Mbida',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
        ),
        const SizedBox(height: 16),
        _label('Téléphone'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: '+237 6 XX XX XX XX',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (v) => v == null || v.length < 9 ? 'Numéro invalide' : null,
        ),
        const SizedBox(height: 16),
        _label('Ville'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _cityCtrl.text.isEmpty ? null : _cityCtrl.text,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.location_city_outlined)),
          hint: const Text('Sélectionner votre ville'),
          items: _cameroonCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => _cityCtrl.text = v ?? '',
          validator: (v) => v == null || v.isEmpty ? 'Ville requise' : null,
        ),
        if (_userType != UserType.seller) ...[
          const SizedBox(height: 16),
          _label('Nom de l\'entreprise (optionnel)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bizCtrl,
            decoration: const InputDecoration(
              hintText: 'Fonderie du Centre SARL',
              prefixIcon: Icon(Icons.business_outlined),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _label('Mot de passe'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passCtrl,
          obscureText: _obscurePass,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
          validator: (v) => v == null || v.length < 6 ? 'Min. 6 caractères' : null,
        ),
        const SizedBox(height: 32),
        Consumer<AuthService>(
          builder: (context, auth, _) => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _register,
              child: auth.isLoading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Créer mon compte'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(text, style: Theme.of(context).textTheme.titleMedium);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: _step == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => setState(() => _step = 0),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => context.go('/onboarding'),
              ),
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: _step == 0 ? _buildStep0() : _buildStep1(),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserType userType;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({required this.userType, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.07) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                userType == UserType.seller
                    ? Icons.recycling
                    : userType == UserType.buyer
                        ? Icons.factory_outlined
                        : Icons.swap_horiz,
                color: selected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userType.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selected ? AppTheme.primary : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text(userType.description,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}
