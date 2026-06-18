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
