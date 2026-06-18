// ============================================================
// game_screen.dart — Pantalla principal del juego
// Equivalente a screen-game en index.html
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../models/game_state.dart';
import '../widgets/settings_button.dart';
import 'result_screen.dart';
import 'home_screen.dart';

class GameScreen extends StatefulWidget {
  final Categoria categoria;

  /// Si viene en true, la partida arranca con racha de 2
  /// (consumido el power-up streak_starter antes de llegar aquí).
  final bool startWithStreakBoost;

  const GameScreen({
    super.key,
    required this.categoria,
    this.startWithStreakBoost = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameState _state;
  late AnimationController _timerController;
  Timer? _timer;
  int? _selectedOption;
  bool _answered = false;
  Map<String, int> _inventory = {};

  @override
  void initState() {
    super.initState();
    _state = GameState();
    _state.categoriaSeleccionada = widget.categoria;
    _state.preguntas = List.from(widget.categoria.questions)..shuffle();

    if (widget.startWithStreakBoost) {
      _state.streak = 2;
      _state.bestStreak = 2;
    }

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _loadInventory();
    _startQuestion();
  }

  Future<void> _loadInventory() async {
    final inv = await StorageService.loadInventory();
    setState(() => _inventory = inv);
  }

  void _startQuestion() {
    _selectedOption = null;
    _answered = false;
    _state.hiddenOptions = {};
    _state.timeLeft = _state.activeExtraTime ? 20 : 15;
    _state.activeExtraTime = false;

    _timerController.duration = Duration(seconds: _state.timeLeft);
    _timerController.forward(from: 0);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _state.timeLeft--);
      if (_state.timeLeft <= 0) {
        t.cancel();
        _timerController.stop();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    setState(() {
      _answered = true;
      if (_state.streakShieldActive) {
        // El shield protege la racha una sola vez y se consume aquí.
        _state.streakShieldActive = false;
      } else {
        _state.streak = 0;
      }
    });
  }

  void _selectOption(int index) {
    if (_answered) return;
    _timer?.cancel();
    _timerController.stop();

    final q = _state.currentQuestion;
    final isCorrect = index == q.a;
    final elapsed = 15 - _state.timeLeft;

    // --- Calcular bonus por velocidad ---
    int bonus = 0;
    if (isCorrect) {
      if (elapsed < 5) bonus = 25;
      else if (elapsed < 10) bonus = 15;
      else if (elapsed < 15) bonus = 10;
    }

    // --- Puntos base ---
    int basePoints = isCorrect ? puntosPorDificultad[q.dif] ?? 10 : 0;

    // --- Racha ---
    if (isCorrect) {
      _state.streak++;
      _state.correct++;
      if (_state.streak > _state.bestStreak) {
        _state.bestStreak = _state.streak;
      }
    } else if (_state.streakShieldActive) {
      // El shield protege la racha una sola vez ante una respuesta
      // incorrecta y se consume en el acto, sin afectar el puntaje.
      _state.streakShieldActive = false;
    } else {
      _state.streak = 0;
    }

    // --- Multiplicador de racha ---
    double mult = 1.0;
    if (_state.streak >= 5) mult = 2.0;
    else if (_state.streak >= 3) mult = 1.5;

    // --- Multiplicador de categoría ---
    double catMult = widget.categoria.mult;

    // --- Total ---
    int total = ((basePoints + bonus) * mult * catMult).round();
    _state.score += total;
    _state.totalBonus += bonus;

    setState(() {
      _selectedOption = index;
      _answered = true;
    });
  }

  void _nextQuestion() {
    if (_state.isLastQuestion) {
      _goToResults();
      return;
    }
    setState(() => _state.current++);
    _startQuestion();
  }

  Future<void> _goToResults() async {
    _timer?.cancel();

    // --- Calcular monedas ---
    int earned = (_state.score / 10).floor();
    if (_state.correct == _state.preguntas.length) earned += 10;
    if (_state.bestStreak >= 5) earned += 5;

    int coins = await StorageService.loadCoins();
    coins += earned;
    await StorageService.saveCoins(coins);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          state: _state,
          coinsEarned: earned,
        ),
      ),
    );
  }

  Future<void> _usePowerup(String id) async {
    if (_answered) return;
    if ((_inventory[id] ?? 0) <= 0) return;

    if (id == 'extra_time') {
      setState(() {
        _inventory[id] = (_inventory[id] ?? 1) - 1;
        _state.timeLeft = (_state.timeLeft + 5).clamp(0, 20);
      });
      await StorageService.saveInventory(_inventory);
      return;
    }

    if (id == 'fifty_fifty') {
      if (_state.hiddenOptions.isNotEmpty) return; // ya usado en esta pregunta
      final q = _state.currentQuestion;
      final wrongIndices = List<int>.generate(q.opts.length, (i) => i)
        ..removeWhere((i) => i == q.a);
      wrongIndices.shuffle();
      final toHide = wrongIndices.take(2).toSet();

      setState(() {
        _inventory[id] = (_inventory[id] ?? 1) - 1;
        _state.hiddenOptions = toHide;
      });
      await StorageService.saveInventory(_inventory);
      return;
    }

    if (id == 'streak_shield') {
      if (_state.streakShieldActive) return; // ya activo, no acumula
      setState(() {
        _inventory[id] = (_inventory[id] ?? 1) - 1;
        _state.streakShieldActive = true;
      });
      await StorageService.saveInventory(_inventory);
      return;
    }

    // streak_starter no se maneja aquí: se consume antes de iniciar
    // la partida, desde HomeScreen (usableInGame: false).
  }

  void _confirmBack() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('¿Salir?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Seguro que quieres salir? Perderás el progreso actual.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (r) => false,
              );
            },
            child: const Text('Salir',
                style: TextStyle(color: Color(0xFFE63946))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerController.dispose();
    super.dispose();
  }

  Color _optionColor(int index) {
    if (!_answered) return Colors.white10;
    final q = _state.currentQuestion;
    if (index == q.a) return const Color(0xFF2D6A4F);
    if (index == _selectedOption) return const Color(0xFF9B2226);
    return Colors.white10;
  }

  String get _streakText {
    if (_state.streak >= 5) return '🔥 Racha ×2 — ${_state.streak} seguidas!';
    if (_state.streak >= 3) return '🔥 Racha ×1.5 — ${_state.streak} seguidas!';
    if (_state.streak > 0) return '⚡ Racha: ${_state.streak}';
    return '';
  }

  String get _diffLabel {
    final dif = _state.currentQuestion.dif;
    if (dif == 'facil') return '🟢 Fácil';
    if (dif == 'media') return '🟡 Media';
    return '🔴 Difícil';
  }

  @override
  Widget build(BuildContext context) {
    final q = _state.currentQuestion;

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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // --- Barra de progreso ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _state.progress,
                    backgroundColor: Colors.white12,
                    color: const Color(0xFFE63946),
                    minHeight: 6,
                  ),
                ),

                const SizedBox(height: 12),

                // --- Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _confirmBack,
                      child: const Text('← Menú',
                          style: TextStyle(color: Colors.white70)),
                    ),
                    Text(
                      'Pregunta ${_state.current + 1} de ${_state.preguntas.length}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '${_state.score} pts',
                      style: const TextStyle(
                        color: Color(0xFFFFD60A),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // --- Timer ---
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AnimatedBuilder(
                          animation: _timerController,
                          builder: (_, __) => LinearProgressIndicator(
                            value: 1 - _timerController.value,
                            backgroundColor: Colors.white12,
                            color: _state.timeLeft <= 5
                                ? const Color(0xFFE63946)
                                : const Color(0xFF2D6A4F),
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_state.timeLeft}',
                      style: TextStyle(
                        color: _state.timeLeft <= 5
                            ? const Color(0xFFE63946)
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // --- Racha ---
                if (_streakText.isNotEmpty || _state.streakShieldActive)
                  Wrap(
                    spacing: 10,
                    children: [
                      if (_streakText.isNotEmpty)
                        Text(
                          _streakText,
                          style: const TextStyle(
                            color: Color(0xFFFFD60A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (_state.streakShieldActive)
                        const Text(
                          '🛡️ Protegida',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),

                // --- Power-ups ---
                if (powerups.any((p) =>
                    p.usableInGame && (_inventory[p.id] ?? 0) > 0)) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: powerups
                        .where((p) =>
                            p.usableInGame && (_inventory[p.id] ?? 0) > 0)
                        .map((p) {
                      final usedUpForThisQuestion =
                          (p.id == 'fifty_fifty' &&
                              _state.hiddenOptions.isNotEmpty) ||
                          (p.id == 'streak_shield' &&
                              _state.streakShieldActive);
                      return GestureDetector(
                        onTap: usedUpForThisQuestion
                            ? null
                            : () => _usePowerup(p.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: usedUpForThisQuestion
                                ? Colors.white24
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: usedUpForThisQuestion
                                  ? const Color(0xFFFFC107)
                                  : Colors.white24,
                            ),
                          ),
                          child: Text(
                            usedUpForThisQuestion
                                ? '${p.icon} Activo'
                                : '${p.icon} ×${_inventory[p.id]}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 12),

                // --- Dificultad ---
                Text(
                  _diffLabel,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 13),
                ),

                const SizedBox(height: 8),

                // --- Pregunta ---
                Text(
                  q.q,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                // --- Opciones ---
                Expanded(
                  child: ListView.separated(
                    itemCount: q.opts.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final isHidden = _state.hiddenOptions.contains(i);
                      if (isHidden) {
                        return Opacity(
                          opacity: 0.25,
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(
                                q.opts[i],
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () => _selectOption(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _optionColor(i),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _answered && i == q.a
                                  ? const Color(0xFF2D6A4F)
                                  : Colors.white12,
                              width: _answered && i == q.a ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            q.opts[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // --- Feedback + botón siguiente ---
                if (_answered) ...[
                  const SizedBox(height: 12),
                  Text(
                    _selectedOption == q.a
                        ? '✅ ¡Correcto!'
                        : _selectedOption == null
                            ? '⏱ Tiempo agotado'
                            : '❌ Incorrecto',
                    style: TextStyle(
                      color: _selectedOption == q.a
                          ? const Color(0xFF2D6A4F)
                          : const Color(0xFFE63946),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    q.fact,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE63946),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _state.isLastQuestion
                            ? 'Ver resultados →'
                            : 'Siguiente →',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
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
