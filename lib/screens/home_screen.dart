// ============================================================
// home_screen.dart — Selección de categoría
// Equivalente a screen-home en index.html
// ============================================================

import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../models/game_state.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final c = await StorageService.loadCoins();
    setState(() => _coins = c);
  }

  void _startGame() {
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(categoria: cat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

                // --- Leyenda de puntos ---
                _LegendCard(
                  title: 'Puntos base por dificultad',
                  rows: const [
                    ['🟢 Fácil', '10 pts'],
                    ['🟡 Media', '20 pts'],
                    ['🔴 Difícil', '30 pts'],
                  ],
                ),

                const SizedBox(height: 12),

                _LegendCard(
                  title: 'Bonus por velocidad',
                  rows: const [
                    ['⚡ Menos de 5 seg', '+25 pts'],
                    ['🟢 5 a 10 seg', '+15 pts'],
                    ['🟡 10 a 15 seg', '+10 pts'],
                    ['🔥 Racha 3-4', '×1.5 al total'],
                    ['🔥 Racha 5+', '×2 al total'],
                    ['⏱ Sin responder', '0 pts'],
                  ],
                ),

                const SizedBox(height: 12),

                _LegendCard(
                  title: '🪙 Cómo ganar monedas',
                  rows: const [
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
                              : Colors.white.withOpacity(0.06),
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
    );
  }
}

/// Tarjeta reutilizable de leyenda (puntos, bonus, monedas).
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
        color: Colors.white.withOpacity(0.06),
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
