import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import '../../services/voice_note_service.dart';
import '../../services/voice_note_service.dart';
import '../../widgets/voice_note_player.dart';

class _Message {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;
  final bool isVoiceNote;
  final String? voiceUrl;
  _Message({
    required this.id, required this.text, required this.isMe,
    required this.time, this.isVoiceNote = false, this.voiceUrl,
  });
}

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String recipientName;

  const ChatScreen({super.key, required this.chatId, required this.recipientName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late VoiceNoteService _voice;
  bool _showVoiceRecord = false;

  final List<_Message> _messages = [
    _Message(id: 'm1', text: 'Bonjour ! J\'ai vu votre annonce pour le cuivre. Est-il encore disponible ?',
        isMe: false, time: DateTime.now().subtract(const Duration(minutes: 30))),
    _Message(id: 'm2', text: 'Oui, il est toujours disponible ! Je peux vous le mettre de côté.',
        isMe: true, time: DateTime.now().subtract(const Duration(minutes: 28))),
    _Message(id: 'm3', text: 'Parfait. Quel est le poids exact ? Et pouvez-vous descendre le prix à 1600 CFA/kg ?',
        isMe: false, time: DateTime.now().subtract(const Duration(minutes: 25))),
    _Message(id: 'm4', text: 'Le poids est de 45 kg environ. Pour le prix, c\'est difficile, mais je peux faire 1700 CFA/kg.',
        isMe: true, time: DateTime.now().subtract(const Duration(minutes: 20))),
    _Message(id: 'm5', text: '🎤 Note vocale',
        isMe: false, time: DateTime.now().subtract(const Duration(minutes: 10)),
        isVoiceNote: true,
        voiceUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
  ];

  @override
  void initState() {
    super.initState();
    _voice = VoiceNoteService();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _voice.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(
        id: DateTime.now().toIso8601String(),
        text: text,
        isMe: true,
        time: DateTime.now(),
      ));
    });
    _textCtrl.clear();
    _scrollToBottom();
  }

  Future<void> _sendVoiceNote() async {
    final path = await _voice.stopRecording();
    if (path != null) {
      setState(() {
        _messages.add(_Message(
          id: DateTime.now().toIso8601String(),
          text: '🎤 Note vocale',
          isMe: true,
          time: DateTime.now(),
          isVoiceNote: true,
          voiceUrl: path,
        ));
        _showVoiceRecord = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            _Avatar(name: widget.recipientName),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.recipientName,
                    style: Theme.of(context).textTheme.titleMedium),
                const Text('En ligne', style: TextStyle(fontSize: 11, color: AppTheme.success)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _MessageBubble(message: _messages[i]),
            ),
          ),

          // Voice recording UI
          if (_showVoiceRecord)
            ListenableBuilder(
              listenable: _voice,
              builder: (context, _) => Container(
                color: AppTheme.cardBg,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const _PulsingDot(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _voice.formatDuration(_voice.recordingDuration),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.rust),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _voice.stopRecording();
                        setState(() => _showVoiceRecord = false);
                      },
                      child: const Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendVoiceNote,
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Input bar
          if (!_showVoiceRecord)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
              ),
              child: Row(
                children: [
                  // Mic button
                  GestureDetector(
                    onTap: () async {
                      setState(() => _showVoiceRecord = true);
                      await _voice.startRecording();
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_outlined, color: AppTheme.primary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        filled: true,
                        fillColor: AppTheme.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendText(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Send button
                  GestureDetector(
                    onTap: _sendText,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          SafeArea(child: const SizedBox()),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('A', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary))),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
            child: Container(
              padding: message.isVoiceNote
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primary : AppTheme.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: AppTheme.divider, width: 0.5),
              ),
              child: message.isVoiceNote && message.voiceUrl != null
                  ? SizedBox(
                      width: 200,
                      child: VoiceNotePlayer(audioUrl: message.voiceUrl!),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: isMe ? Colors.white : AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fmt(message.time),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white60 : AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});
  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').take(2).map((s) => s.isNotEmpty ? s[0] : '').join();
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), shape: BoxShape.circle),
      child: Center(child: Text(initials.toUpperCase(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary))),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override State<_PulsingDot> createState() => _PDS();
}
class _PDS extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Opacity(opacity: 0.5 + _c.value * 0.5,
      child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppTheme.rust, shape: BoxShape.circle))),
  );
}
