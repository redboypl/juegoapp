// ============================================================
// result_screen.dart — Pantalla de resultados
// Equivalente a screen-result en index.html
// ============================================================

import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'home_screen.dart';
import 'start_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCoins();

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

    // Copiar al portapapeles
    await _copyToClipboard(text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resultado copiado al portapapeles!'),
        backgroundColor: Color(0xFF2D6A4F),
      ),
    );
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
      body: Container(
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
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.amber.withOpacity(0.3)),
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
