// ============================================================
// home_screen.dart — Selección de categoría
// Equivalente a screen-home en index.html
// ============================================================

import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../models/game_state.dart';
import '../widgets/settings_button.dart';
import 'game_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _coins = 0;
  String? _selectedCatId;
  DailyStreakData? _dailyStreak;

  @override
  void initState() {
    super.initState();
    _loadCoins();
    _loadDailyStreak();
  }

  Future<void> _loadDailyStreak() async {
    final data = await DailyStreakService.load();
    setState(() => _dailyStreak = data);
  }

  Future<void> _loadCoins() async {
    final c = await StorageService.loadCoins();
    setState(() => _coins = c);
  }

  void _startGame() async {
    if (_selectedCatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una categoría primero'),
          backgroundColor: Color(0xFFE63946),
        ),
      );
      return;
    }
    final cat = todasLasCategorias.firstWhere((c) => c.id == _selectedCatId);

    bool useStreakStarter = false;
    final inventory = await StorageService.loadInventory();
    final ownedStarters = inventory['streak_starter'] ?? 0;

    if (ownedStarters > 0 && mounted) {
      useStreakStarter = await _confirmUseStreakStarter(ownedStarters) ?? false;
      if (useStreakStarter) {
        inventory['streak_starter'] = ownedStarters - 1;
        await StorageService.saveInventory(inventory);
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          categoria: cat,
          startWithStreakBoost: useStreakStarter,
        ),
      ),
    );
  }

  Future<bool?> _confirmUseStreakStarter(int owned) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🔥 Racha instantánea',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Tienes $owned. ¿Quieres usar una para empezar esta partida '
          'con una racha de 2 (te acerca al multiplicador ×1.5)?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No usar',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usar ahora',
                style: TextStyle(color: Color(0xFFFFC107))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // --- Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚾ Trivia Beisbolera',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '¿Cuánto sabes del béisbol venezolano?',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ShopScreen()),
                      ).then((_) => _loadCoins()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🪙 $_coins',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- Banner racha diaria ---
                if (_dailyStreak != null)
                  _DailyStreakBanner(data: _dailyStreak!),

                const SizedBox(height: 16),

                // --- Leyenda de puntos ---
                const _LegendCard(
                  title: 'Puntos base por dificultad',
                  rows: [
                    ['🟢 Fácil', '10 pts'],
                    ['🟡 Media', '20 pts'],
                    ['🔴 Difícil', '30 pts'],
                  ],
                ),

                const SizedBox(height: 12),

                const _LegendCard(
                  title: 'Bonus por velocidad',
                  rows: [
                    ['⚡ Menos de 5 seg', '+25 pts'],
                    ['🟢 5 a 10 seg', '+15 pts'],
                    ['🟡 10 a 15 seg', '+10 pts'],
                    ['🔥 Racha 3-4', '×1.5 al total'],
                    ['🔥 Racha 5+', '×2 al total'],
                    ['⏱ Sin responder', '0 pts'],
                  ],
                ),

                const SizedBox(height: 12),

                const _LegendCard(
                  title: '🪙 Cómo ganar monedas',
                  rows: [
                    ['Cada 10 pts de puntaje', '+1 🪙'],
                    ['Partida perfecta (8/8)', '+10 🪙'],
                    ['Racha máxima (×2)', '+5 🪙'],
                  ],
                ),

                const SizedBox(height: 24),

                // --- Grid de categorías ---
                // Equivalente a #cat-grid construido por buildCatGrid()
                // en el script.js original.
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.92,
                  children: todasLasCategorias.map((cat) {
                    final seleccionada = _selectedCatId == cat.id;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCatId = cat.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: seleccionada
                              ? const Color(0xFFE6F1FB)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: seleccionada
                                ? const Color(0xFF185FA5)
                                : Colors.white24,
                            width: seleccionada ? 2 : 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.icon,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: seleccionada
                                    ? const Color(0xFF185FA5)
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                cat.desc,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: seleccionada
                                      ? const Color(0xFF185FA5)
                                      : Colors.white60,
                                ),
                              ),
                            ),
                            if (cat.mult != 1)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAEEDA),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '×${cat.mult} puntos',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF854F0B),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // --- Botón Jugar ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF185FA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Jugar ↗',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
          ),
          const SettingsButton(),
        ],
      ),
    );
  }
}

/// Banner de racha diaria en HomeScreen
class _DailyStreakBanner extends StatelessWidget {
  final DailyStreakData data;
  const _DailyStreakBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    final streak = data.streak;
    final playedToday = data.playedToday;

    // Color según estado
    final Color borderColor = playedToday
        ? const Color(0xFFFFC107)   // dorado: ya jugó hoy
        : const Color(0xFF444466);  // gris: aún no jugó

    final Color iconBg = playedToday
        ? const Color(0xFFFFC107).withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.05);

    final String mensaje = streak == 0
        ? 'Juega hoy para iniciar tu racha 🔥'
        : playedToday
            ? '¡Ya jugaste hoy! Vuelve mañana para mantenerla'
            : 'Juega hoy para no perder tu racha';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          // Ícono de fuego con fondo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                streak == 0 ? '🔥' : '🔥',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      streak == 0 ? 'Sin racha' : '$streak ${streak == 1 ? 'día' : 'días'} seguidos',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: playedToday
                            ? const Color(0xFFFFC107)
                            : Colors.white,
                      ),
                    ),
                    if (data.longest > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        'máx: ${data.longest}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  mensaje,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          // Indicador de días (últimos 7)
          _StreakDots(streak: streak, playedToday: playedToday),
        ],
      ),
    );
  }
}

/// 7 puntos que representan los últimos 7 días
class _StreakDots extends StatelessWidget {
  final int streak;
  final bool playedToday;
  const _StreakDots({required this.streak, required this.playedToday});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        // i=6 es hoy, i=5 es ayer, etc.
        final daysAgo = 6 - i;
        bool filled;
        if (daysAgo == 0) {
          filled = playedToday;
        } else {
          filled = streak > daysAgo;
        }
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? const Color(0xFFFFC107)
                : Colors.white.withValues(alpha: 0.15),
          ),
        );
      }),
    );
  }
}
/// Equivalente a .bonus-legend / .bonus-row del CSS original.
class _LegendCard extends StatelessWidget {
  final String title;
  final List<List<String>> rows;

  const _LegendCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          ...rows.map(
            (fila) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fila[0],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    fila[1],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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
}