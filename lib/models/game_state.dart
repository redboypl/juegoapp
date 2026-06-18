// ============================================================
// game_state.dart — Estado del juego y sistema de rangos
// Equivalente a las variables globales y RANKS en script.js
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';
import '../data/questions.dart';

// --- Puntos base por dificultad ---
const Map<String, int> puntosPorDificultad = {
  'facil': 10,
  'media': 20,
  'dificil': 30,
};

// --- Rangos ---
class Rango {
  final String name;
  final String icon;
  final int min;
  const Rango({required this.name, required this.icon, required this.min});
}

const List<Rango> rangos = [
  Rango(name: 'Novato',       icon: '⚾',  min: 0),
  Rango(name: 'Pelotero',     icon: '🧢',  min: 50),
  Rango(name: 'Prospecto',    icon: '🌟',  min: 120),
  Rango(name: 'Profesional',  icon: '🏅',  min: 220),
  Rango(name: 'Crack',        icon: '🔥',  min: 350),
  Rango(name: 'Leyenda',      icon: '🏆',  min: 500),
];

Rango getRango(int score) {
  Rango resultado = rangos.first;
  for (final r in rangos) {
    if (score >= r.min) resultado = r;
  }
  return resultado;
}

// --- Power-ups ---
class Powerup {
  final String id;
  final String icon;
  final String name;
  final String desc;
  final int price;
  const Powerup({
    required this.id,
    required this.icon,
    required this.name,
    required this.desc,
    required this.price,
  });
}

const List<Powerup> powerups = [
  Powerup(id: 'extra_time',     icon: '⏱️', name: 'Tiempo extra',       desc: '+5 segundos en tu próxima pregunta', price: 15),
  Powerup(id: 'fifty_fifty',    icon: '✂️', name: '50/50',               desc: 'Elimina dos opciones incorrectas',   price: 20),
  Powerup(id: 'streak_shield',  icon: '🛡️', name: 'Protector de racha', desc: 'Si fallas, no pierdes tu racha',     price: 25),
  Powerup(id: 'streak_starter', icon: '🔥', name: 'Racha instantánea',  desc: 'Empieza la partida con racha de 2',  price: 30),
];

// --- Estado de una partida activa ---
class GameState {
  Categoria? categoriaSeleccionada;
  List<Pregunta> preguntas = [];
  int current = 0;
  int score = 0;
  int correct = 0;
  int streak = 0;
  int bestStreak = 0;
  int totalBonus = 0;
  int timeLeft = 15;
  bool answered = false;
  bool activeExtraTime = false;

  void reset() {
    current = 0;
    score = 0;
    correct = 0;
    streak = 0;
    bestStreak = 0;
    totalBonus = 0;
    timeLeft = 15;
    answered = false;
    activeExtraTime = false;
  }

  Pregunta get currentQuestion => preguntas[current];
  bool get isLastQuestion => current >= preguntas.length - 1;
  double get progress => preguntas.isEmpty ? 0 : (current + 1) / preguntas.length;
}

// --- Persistencia: monedas e inventario ---
class StorageService {
  static const String _coinsKey = 'trivia_coins';
  static const String _inventoryPrefix = 'trivia_inv_';

  static Future<int> loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 0;
  }

  static Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
  }

  static Future<Map<String, int>> loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> inv = {};
    for (final p in powerups) {
      inv[p.id] = prefs.getInt('$_inventoryPrefix${p.id}') ?? 0;
    }
    return inv;
  }

  static Future<void> saveInventory(Map<String, int> inventory) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in inventory.entries) {
      await prefs.setInt('$_inventoryPrefix${entry.key}', entry.value);
    }
  }
}
