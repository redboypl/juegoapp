// ============================================================
// audio_service.dart — Reproductor de música global (singleton)
// Mantiene una sola instancia de AudioPlayer viva durante toda
// la sesión de la app, independiente de la pantalla activa.
// Persiste mute/volumen en SharedPreferences.
// ============================================================

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  static const String _volumeKey = 'trivia_audio_volume';
  static const String _mutedKey = 'trivia_audio_muted';
  static const String _musicAsset = 'audio/cita_de_bases.mp3';

  // Música de fondo
  final AudioPlayer _player = AudioPlayer();

  // Efectos de sonido (players separados para no interrumpir la música)
  final AudioPlayer _sfxCorrect = AudioPlayer();
  final AudioPlayer _sfxWrong = AudioPlayer();
  final AudioPlayer _sfxStreak = AudioPlayer();
  final AudioPlayer _sfxDailyStreak = AudioPlayer();

  double _volume = 0.6;
  bool _muted = false;
  bool _initialized = false;
  bool _started = false;

  double get volume => _volume;
  bool get muted => _muted;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble(_volumeKey) ?? 0.6;
    _muted = prefs.getBool(_mutedKey) ?? false;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(_muted ? 0 : _volume);
  }

  Future<void> ensurePlaying() async {
    if (!_initialized) await init();
    if (_started) return;
    _started = true;
    try {
      await _player.play(AssetSource(_musicAsset));
    } catch (_) {
      _started = false;
    }
  }

  // --- Efectos de sonido ---

  /// Respuesta correcta — tono positivo corto
  Future<void> playCorrect() async {
    if (_muted) return;
    try {
      await _sfxCorrect.stop();
      await _sfxCorrect.setVolume((_volume * 1.2).clamp(0.0, 1.0));
      await _sfxCorrect.play(AssetSource('audio/sfx_correct.mp3'));
    } catch (_) {}
  }

  /// Respuesta incorrecta — tono negativo corto
  Future<void> playWrong() async {
    if (_muted) return;
    try {
      await _sfxWrong.stop();
      await _sfxWrong.setVolume((_volume * 1.0).clamp(0.0, 1.0));
      await _sfxWrong.play(AssetSource('audio/sfx_wrong.mp3'));
    } catch (_) {}
  }

  /// Racha en juego alcanzada (×1.5 o ×2) — fanfarria corta
  Future<void> playStreakMilestone() async {
    if (_muted) return;
    try {
      await _sfxStreak.stop();
      await _sfxStreak.setVolume((_volume * 1.3).clamp(0.0, 1.0));
      await _sfxStreak.play(AssetSource('audio/sfx_streak.mp3'));
    } catch (_) {}
  }

  /// Racha diaria nueva (se llama desde ResultScreen)
  Future<void> playDailyStreak() async {
    if (_muted) return;
    try {
      await _sfxDailyStreak.stop();
      await _sfxDailyStreak.setVolume((_volume * 1.4).clamp(0.0, 1.0));
      await _sfxDailyStreak.play(AssetSource('audio/sfx_daily_streak.mp3'));
    } catch (_) {}
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    if (!_muted) await _player.setVolume(_volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, _volume);
  }

  Future<void> setMuted(bool value) async {
    _muted = value;
    await _player.setVolume(_muted ? 0 : _volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mutedKey, _muted);
  }

  Future<void> toggleMuted() => setMuted(!_muted);

  Future<void> dispose() async {
    await _player.dispose();
    await _sfxCorrect.dispose();
    await _sfxWrong.dispose();
    await _sfxStreak.dispose();
    await _sfxDailyStreak.dispose();
  }
}
