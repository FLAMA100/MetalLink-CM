import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Unified voice note service — works on both web and mobile.
/// On web: record_web uses the browser MediaRecorder API.
/// On mobile: record uses native mic (Android/iOS).
/// No JS interop needed — the record package handles everything.
class VoiceNoteService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedPath;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _timer;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get recordedPath => _recordedPath;
  Duration get recordingDuration => _recordingDuration;
  Duration get playbackPosition => _playbackPosition;
  Duration get totalDuration => _totalDuration;

  VoiceNoteService() {
    _player.onPlayerStateChanged.listen((s) {
      _isPlaying = s == PlayerState.playing;
      notifyListeners();
    });
    _player.onPositionChanged.listen((p) {
      _playbackPosition = p;
      notifyListeners();
    });
    _player.onDurationChanged.listen((d) {
      _totalDuration = d;
      notifyListeners();
    });
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _playbackPosition = Duration.zero;
      notifyListeners();
    });
  }

  Future<bool> startRecording() async {
    // Request mic permission on mobile; web handles it via browser prompt
    if (!kIsWeb) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) return false;
    }

    // Check if the recorder itself reports having permission
    if (!await _recorder.hasPermission()) return false;

    try {
      String path;
      if (kIsWeb) {
        // Web: record_web uses an in-memory blob, path is a blob: URL after stop
        path = 'recording_${DateTime.now().millisecondsSinceEpoch}.webm';
      } else {
        final dir = await getTemporaryDirectory();
        path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _isRecording = true;
      _recordingDuration = Duration.zero;
      _recordedPath = null;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _recordingDuration += const Duration(seconds: 1);
        notifyListeners();
      });
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('startRecording error: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    _timer?.cancel();

    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _recordedPath = path;
      notifyListeners();
      return path;
    } catch (e) {
      debugPrint('stopRecording error: $e');
      _isRecording = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> playRecording(String path) async {
    try {
      if (_isPlaying) await _player.stop();
      if (kIsWeb || path.startsWith('blob:') || path.startsWith('http')) {
        await _player.play(UrlSource(path));
      } else {
        await _player.play(DeviceFileSource(path));
      }
    } catch (e) {
      debugPrint('playRecording error: $e');
    }
  }

  Future<void> stopPlayback() async {
    await _player.stop();
    _isPlaying = false;
    _playbackPosition = Duration.zero;
    notifyListeners();
  }

  void clearRecording() {
    _recordedPath = null;
    _recordingDuration = Duration.zero;
    notifyListeners();
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
