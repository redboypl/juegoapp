// ============================================================
// result_screen.dart — Pantalla de resultados
// Equivalente a screen-result en index.html
// ============================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/game_state.dart';
import '../services/audio_service.dart';
import 'start_screen.dart';
import 'package:flutter/services.dart';

class ResultScreen extends StatefulWidget {
  final GameState state;
  final int coinsEarned;

  const ResultScreen({
    super.key,
    required this.state,
    required this.coinsEarned,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  int _totalCoins = 0;
  DailyStreakData? _dailyStreak;

  @override
  void initState() {
    super.initState();
    _loadCoins();
    _registerDailyStreak();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _animController.forward();
  }

  Future<void> _loadCoins() async {
    final c = await StorageService.loadCoins();
    setState(() => _totalCoins = c);
  }

  Future<void> _registerDailyStreak() async {
    final data = await DailyStreakService.registerPlay();
    setState(() => _dailyStreak = data);
    // Sonido solo si es la primera vez que juega hoy
    if (data.isNew) {
      if (data.streak >= 3) {
        AudioService.instance.playDailyStreak();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _trophy {
    final pct = widget.state.correct / widget.state.preguntas.length;
    if (pct == 1.0) return '🏆';
    if (pct >= 0.75) return '🥇';
    if (pct >= 0.5) return '🥈';
    return '🥉';
  }

  String get _title {
    final pct = widget.state.correct / widget.state.preguntas.length;
    if (pct == 1.0) return '¡Perfecto! ¡Eres una leyenda!';
    if (pct >= 0.75) return '¡Excelente resultado!';
    if (pct >= 0.5) return '¡Buen intento!';
    return 'Sigue practicando';
  }

  Future<void> _shareResult() async {
    final cat = widget.state.categoriaSeleccionada!.name;
    final rank = getRango(widget.state.score);
    final text =
        'Jugué la Trivia Beisbolera Venezolana ($cat) y saqué ${widget.state.score} pts '
        '(${rank.icon} ${rank.name}) con ${widget.state.correct}/${widget.state.preguntas.length} '
        'correctas y mejor racha de ${widget.state.bestStreak}! ⚾🇻🇪';

    try {
      final result = await Share.share(text, subject: 'Mi resultado en Trivia Beisbolera 🇻🇪');
      if (!mounted) return;
      // En algunas plataformas (p.ej. desktop) Share.share no abre una
      // hoja nativa de compartir; en ese caso copiamos al portapapeles
      // como respaldo para que el usuario no se quede sin feedback.
      if (result.status == ShareResultStatus.unavailable) {
        await _copyToClipboard(text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resultado copiado al portapapeles!'),
            backgroundColor: Color(0xFF2D6A4F),
          ),
        );
      }
    } catch (_) {
      // Si share_plus falla por cualquier razón (p.ej. plataforma no
      // soportada), recurrimos al portapapeles para no romper la UX.
      await _copyToClipboard(text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resultado copiado al portapapeles!'),
          backgroundColor: Color(0xFF2D6A4F),
        ),
      );
    }
  }

  Future<void> _copyToClipboard(String text) async {
    // ignore: deprecated_member_use
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final rank = getRango(state.score);
    final nextRankIndex = rangos.indexOf(rank) + 1;
    final nextRank = nextRankIndex < rangos.length ? rangos[nextRankIndex] : null;

    return Scaffold(
      body: Stack(
        children: [
          Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  children: [

                    const SizedBox(height: 16),

                    // --- Trofeo ---
                    Text(
                      _trophy,
                      style: const TextStyle(fontSize: 72),
                    ),

                    const SizedBox(height: 12),

                    // --- Título ---
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // --- Rango ---
                    Text(
                      '${rank.icon} Rango: ${rank.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFFFD60A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // --- Progreso al siguiente rango ---
                    Text(
                      nextRank != null
                          ? 'Te faltan ${nextRank.min - state.score} pts para ${nextRank.icon} ${nextRank.name}'
                          : '¡Alcanzaste el rango máximo! 🎉',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // --- Monedas ganadas ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Monedas ganadas: +${widget.coinsEarned} 🪙',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '🪙 $_totalCoins',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Stats ---
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.8,
                      children: [
                        _StatCard(
                            label: 'Puntaje',
                            value: '${state.score}'),
                        _StatCard(
                            label: 'Correctas',
                            value: '${state.correct}/${state.preguntas.length}'),
                        _StatCard(
                            label: 'Mejor racha',
                            value: '${state.bestStreak}'),
                        _StatCard(
                            label: 'Bonus total',
                            value: '${state.totalBonus}'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- Banner racha diaria ---
                    if (_dailyStreak != null && _dailyStreak!.isNew)
                      _DailyStreakResultBanner(data: _dailyStreak!),

                    if (_dailyStreak != null && _dailyStreak!.isNew)
                      const SizedBox(height: 16),

                    // --- Botón compartir ---
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _shareResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3460),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Colors.white24),
                          ),
                        ),
                        child: const Text(
                          'Compartir resultado',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // --- Botón jugar de nuevo ---
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StartScreen()),
                          (r) => false,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE63946),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Jugar de nuevo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          ),
          ),
        ],
      ),
    );
  }
}

// --- Tarjeta de estadística ---
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner que aparece en ResultScreen cuando el usuario juega por primera vez hoy
class _DailyStreakResultBanner extends StatelessWidget {
  final DailyStreakData data;
  const _DailyStreakResultBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    final streak = data.streak;
    final isNew = data.isNew;

    String titulo;
    String subtitulo;
    String emoji;

    if (streak == 1) {
      titulo = '¡Primer día!';
      subtitulo = 'Vuelve mañana para construir tu racha';
      emoji = '🔥';
    } else if (streak < 3) {
      titulo = '¡$streak días seguidos!';
      subtitulo = 'Sigue así, vas bien';
      emoji = '🔥';
    } else if (streak < 7) {
      titulo = '🔥 $streak días en racha';
      subtitulo = '¡Estás en fuego! No rompas la cadena';
      emoji = '🏅';
    } else {
      titulo = '🏆 $streak días seguidos';
      subtitulo = '¡Leyenda! Una semana completa';
      emoji = '🏆';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFC107).withValues(alpha: 0.2),
            const Color(0xFFFF9800).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFC107),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFC107), width: 1),
              ),
              child: const Text(
                'HOY ✓',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFC107),
                ),
              ),
            ),
        ],
      ),
    );
  }
}