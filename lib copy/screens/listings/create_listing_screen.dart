import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../theme.dart';
import '../../models/scrap_listing.dart';
import '../../services/listing_service.dart';
import '../../services/location_service.dart';
import '../../services/camera_service.dart';
import '../../services/voice_note_service.dart';
import '../../services/auth_service.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  MetalType _metalType = MetalType.iron;
  bool _isUrgent = false;
  bool _isSubmitting = false;

  final List<XFile> _photos = [];
  final CameraService _cameraService = CameraService();
  final VoiceNoteService _voiceService = VoiceNoteService();
  

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationService>().getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _weightCtrl.dispose();
    _priceCtrl.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text('Ajouter une photo', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (!kIsWeb) ...[
                ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppTheme.primary),
                  ),
                  title: const Text('Prendre une photo'),
                  subtitle: const Text('Utiliser l\'appareil photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    final img = await _cameraService.takePhoto();
                    if (img != null) setState(() => _photos.add(img));
                  },
                ),
              ],
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AppTheme.accent),
                ),
                title: const Text('Choisir depuis la galerie'),
                subtitle: const Text('Sélectionner plusieurs photos'),
                onTap: () async {
                  Navigator.pop(context);
                  final imgs = await _cameraService.pickMultipleImages();
                  if (imgs.isNotEmpty) setState(() => _photos.addAll(imgs));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins une photo de votre ferraille'),
          backgroundColor: AppTheme.rust,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthService>();
    final location = context.read<LocationService>();
    final listingService = context.read<ListingService>();
    final user = auth.currentUser!;

    // In production: upload photos to cloud storage and get URLs
    // For demo: use placeholder URLs
    final photoUrls = _photos.map((f) =>
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600'
    ).toList();

    final listing = ScrapListing(
      id: const Uuid().v4(),
      sellerId: user.id,
      sellerName: user.fullName,
      sellerPhone: user.phone,
      sellerRating: user.rating,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      metalType: _metalType,
      weightKg: double.parse(_weightCtrl.text),
      pricePerKg: double.parse(_priceCtrl.text),
      photoUrls: photoUrls,
      voiceNoteUrl: _voiceService.recordedPath,
      latitude: location.latitude ?? 3.8667,
      longitude: location.longitude ?? 11.5167,
      locationName: location.locationName,
      city: location.city.isEmpty ? 'Yaoundé' : location.city,
      isUrgent: _isUrgent,
      createdAt: DateTime.now(),
    );

    await listingService.addListing(listing);
    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annonce publiée avec succès ! ✅'),
          backgroundColor: AppTheme.success,
        ),
      );
      context.go('/listings/${listing.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Publier une annonce'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_currentStep == 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitListing,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20)),
                child: _isSubmitting
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Publier'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Step indicator
          _StepIndicator(currentStep: _currentStep),

          Expanded(
            child: Form(
              key: _formKey,
              child: [
                _buildStep0Metal(),
                _buildStep1Details(),
                _buildStep2Media(),
              ][_currentStep],
            ),
          ),

          // Navigation buttons
          _buildNavButtons(),
        ],
      ),
    );
  }

  Widget _buildStep0Metal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type de métal', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('Sélectionnez le type de ferraille que vous vendez',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          ...MetalType.values.map((t) => _MetalCard(
            metalType: t,
            selected: _metalType == t,
            onTap: () => setState(() => _metalType = t),
          )),
          const SizedBox(height: 16),
          // Urgent toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _isUrgent ? AppTheme.rust : AppTheme.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.rust.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt, color: AppTheme.rust),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vente urgente', style: Theme.of(context).textTheme.titleMedium),
                      Text('Priorité dans les résultats',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Switch(
                  value: _isUrgent,
                  activeColor: AppTheme.rust,
                  onChanged: (v) => setState(() => _isUrgent = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Details() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Détails de l\'annonce', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),

          _label('Titre de l\'annonce'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Ex: Gros lot de cuivre — câbles usagés',
            ),
            validator: (v) => v == null || v.isEmpty ? 'Titre requis' : null,
          ),
          const SizedBox(height: 16),

          _label('Description'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descCtrl,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Décrivez votre ferraille : état, origine, quantité approximative...',
              alignLabelWithHint: true,
            ),
            validator: (v) => v == null || v.isEmpty ? 'Description requise' : null,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Poids (kg)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: '25.5',
                        suffixText: 'kg',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (double.tryParse(v) == null) return 'Invalide';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Prix / kg (CFA)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '500',
                        suffixText: 'CFA',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (double.tryParse(v) == null) return 'Invalide';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Price hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: AppTheme.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prix suggéré pour ${_metalType.displayName} : ${_metalType.priceRangeCFA}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.rust),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // Location
          _label('Localisation'),
          const SizedBox(height: 8),
          Consumer<LocationService>(
            builder: (context, loc, _) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  Icon(
                    loc.isLoading ? Icons.location_searching : Icons.location_on,
                    color: loc.hasLocation ? AppTheme.rust : AppTheme.textHint,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.isLoading ? 'Localisation en cours...' : loc.locationName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (loc.isLoading)
                    const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton(
                      onPressed: () => loc.getCurrentLocation(),
                      child: const Text('Actualiser'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Media() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Photos & Note vocale', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('Les photos augmentent vos chances de vente de 3×',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),

          // Photos grid
          _label('Photos (${_photos.length}/6)'),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _photos.length < 6 ? _photos.length + 1 : _photos.length,
            itemBuilder: (context, i) {
              if (i == _photos.length) {
                return GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider, style: BorderStyle.solid),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: AppTheme.primary, size: 28),
                        SizedBox(height: 6),
                        Text('Ajouter', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(
                            _photos[i].path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.file(
                            File(_photos[i].path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _photos.removeAt(i)),
                      child: Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                  if (i == 0)
                    Positioned(
                      bottom: 4, left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Principale', style: TextStyle(fontSize: 9, color: Colors.white)),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),
          // Voice note section
          _label('Note vocale (optionnel)'),
          const SizedBox(height: 6),
          Text(
            'Enregistrez un message audio pour décrire votre ferraille',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: _voiceService,
            builder: (context, _) {
              if (_voiceService.isRecording) {
                return _VoiceRecordingInProgress(service: _voiceService);
              }
              if (_voiceService.recordedPath != null) {
                return _VoiceRecorded(service: _voiceService);
              }
              return _VoiceRecordButton(onStart: () async {
                final ok = await _voiceService.startRecording();
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enregistrement disponible sur le navigateur web uniquement pour le moment.')),
                  );
                }
              });
            },
          ),

          const SizedBox(height: 20),
          // Tips
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined, size: 16, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text('Conseils pour de meilleures ventes',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                  ],
                ),
                const SizedBox(height: 10),
                ...[
                  'Prenez des photos à la lumière naturelle',
                  'Montrez le métal de près et de loin',
                  'Enregistrez une note vocale pour instaurer la confiance',
                  'Indiquez le poids approximatif dans la description',
                ].map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: AppTheme.primary)),
                      Expanded(child: Text(tip, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Précédent'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          if (_currentStep < 2)
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep == 1 && !_formKey.currentState!.validate()) return;
                  setState(() => _currentStep++);
                },
                child: Text(_currentStep == 0 ? 'Continuer' : 'Suivant'),
              ),
            ),
          if (_currentStep == 2)
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitListing,
                child: _isSubmitting
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Publier l\'annonce'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _label(String text) =>
      Text(text, style: Theme.of(context).textTheme.titleMedium);
}

// ──────────────────────────────────────────────
// Supporting widgets
// ──────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Type de métal', 'Détails', 'Photos & Audio'];
    return Container(
      color: AppTheme.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: i ~/ 2 < currentStep ? AppTheme.primary : AppTheme.divider,
              ),
            );
          }
          final step = i ~/ 2;
          final active = step == currentStep;
          final done = step < currentStep;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: done || active ? AppTheme.primary : AppTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done || active ? AppTheme.primary : AppTheme.divider,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${step + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : AppTheme.textHint,
                          )),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[step],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? AppTheme.primary : AppTheme.textHint,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _MetalCard extends StatelessWidget {
  final MetalType metalType;
  final bool selected;
  final VoidCallback onTap;
  const _MetalCard({required this.metalType, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.07) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.divider,
            width: selected ? 2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(metalType.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(metalType.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selected ? AppTheme.primary : AppTheme.textPrimary,
                      )),
                  Text(metalType.priceRangeCFA,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: AppTheme.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _VoiceRecordButton extends StatelessWidget {
  final VoidCallback onStart;
  const _VoiceRecordButton({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStart,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_none, size: 28, color: AppTheme.primary),
            SizedBox(width: 12),
            Text(
              'Appuyez pour enregistrer',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceRecordingInProgress extends StatelessWidget {
  final VoiceNoteService service;
  const _VoiceRecordingInProgress({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.rust.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.rust.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const _PulsingDot(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enregistrement en cours...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.rust)),
                Text(
                  service.formatDuration(service.recordingDuration),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.rust),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => service.stopRecording(),
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppTheme.rust, shape: BoxShape.circle),
              child: const Icon(Icons.stop, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceRecorded extends StatelessWidget {
  final VoiceNoteService service;
  const _VoiceRecorded({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (service.isPlaying) {
                service.stopPlayback();
              } else {
                service.playRecording(service.recordedPath!);
              }
            },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              child: Icon(
                service.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white, size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Note vocale enregistrée ✓',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                Text(service.formatDuration(service.recordingDuration),
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => service.clearRecording(),
            child: const Text('Supprimer', style: TextStyle(color: AppTheme.rust, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.5, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppTheme.rust, shape: BoxShape.circle)),
      ),
    );
  }
}
