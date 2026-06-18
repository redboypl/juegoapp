// ============================================================
// settings_button.dart — Ícono flotante de ajustes ⚙️
// Se coloca en la esquina superior izquierda de cada pantalla.
// Abre un diálogo con control de mute y volumen de la música
// de fondo (AudioService), persistente entre pantallas.
// ============================================================

import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';

/// Botón flotante reutilizable. Usar dentro de un [Stack] que
/// envuelva el contenido de la pantalla:
///
/// ```dart
/// Stack(
///   children: [
///     // ...contenido de la pantalla...
///     const SettingsButton(),
///   ],
/// )
/// ```
class SettingsButton extends StatelessWidget {
  /// Por defecto se ancla a la esquina superior izquierda. Pásese
  /// `alignRight: true` en pantallas donde ese rincón ya está ocupado
  /// (p.ej. CreditsScreen tiene un botón "← Volver" ahí).
  final bool alignRight;

  const SettingsButton({super.key, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: alignRight ? null : 8,
      right: alignRight ? 8 : null,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _openSettingsDialog(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Text('⚙️', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }

  void _openSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _SettingsDialog(),
    );
  }
}

class _SettingsDialog extends StatefulWidget {
  const _SettingsDialog();

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late double _volume;
  late bool _muted;

  @override
  void initState() {
    super.initState();
    _volume = AudioService.instance.volume;
    _muted = AudioService.instance.muted;
  }

  Future<void> _onMutedChanged(bool value) async {
    setState(() => _muted = value);
    await AudioService.instance.setMuted(value);
  }

  Future<void> _onVolumeChanged(double value) async {
    setState(() => _volume = value);
    await AudioService.instance.setVolume(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceTop,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(
        children: [
          Text('⚙️ ', style: TextStyle(fontSize: 20)),
          Text('Ajustes', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Música de fondo',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              Switch(
                value: !_muted,
                activeColor: AppColors.acentoDorado,
                onChanged: (v) => _onMutedChanged(!v),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                _muted || _volume == 0
                    ? Icons.volume_off
                    : _volume < 0.5
                        ? Icons.volume_down
                        : Icons.volume_up,
                color: Colors.white54,
                size: 20,
              ),
              Expanded(
                child: Slider(
                  value: _volume,
                  min: 0,
                  max: 1,
                  activeColor: AppColors.acentoDorado,
                  inactiveColor: Colors.white24,
                  onChanged: _muted ? null : _onVolumeChanged,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar',
              style: TextStyle(color: AppColors.rojoVenezolano)),
        ),
      ],
    );
  }
}
