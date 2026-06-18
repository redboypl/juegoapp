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

  final AudioPlayer _player = AudioPlayer();

  double _volume = 0.6;
  bool _muted = false;
  bool _initialized = false;
  bool _started = false;

  double get volume => _volume;
  bool get muted => _muted;

  /// Carga preferencias guardadas. Llamar una vez al inicio de la app.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble(_volumeKey) ?? 0.6;
    _muted = prefs.getBool(_mutedKey) ?? false;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(_muted ? 0 : _volume);
  }

  /// Inicia la música de fondo si aún no se ha iniciado.
  /// Seguro de llamar múltiples veces (p.ej. desde varias pantallas).
  Future<void> ensurePlaying() async {
    if (!_initialized) await init();
    if (_started) return;
    _started = true;
    try {
      await _player.play(AssetSource(_musicAsset));
    } catch (_) {
      // Si el asset no existe o el dispositivo no soporta el formato,
      // fallamos en silencio para no romper la UI.
      _started = false;
    }
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    if (!_muted) {
      await _player.setVolume(_volume);
    }
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
  }
}
