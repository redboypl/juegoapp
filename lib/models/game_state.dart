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

  /// true: se consume con un tap durante la partida (extra_time, fifty_fifty,
  /// streak_shield). false: se aplica automáticamente al INICIAR la partida
  /// (streak_starter), por lo que no aparece como botón en game_screen.
  final bool usableInGame;

  const Powerup({
    required this.id,
    required this.icon,
    required this.name,
    required this.desc,
    required this.price,
    this.usableInGame = true,
  });
}

const List<Powerup> powerups = [
  Powerup(id: 'extra_time',     icon: '⏱️', name: 'Tiempo extra',       desc: '+5 segundos en tu próxima pregunta', price: 15),
  Powerup(id: 'fifty_fifty',    icon: '✂️', name: '50/50',               desc: 'Elimina dos opciones incorrectas',   price: 20),
  Powerup(id: 'streak_shield',  icon: '🛡️', name: 'Protector de racha', desc: 'Si fallas, no pierdes tu racha',     price: 25),
  Powerup(id: 'streak_starter', icon: '🔥', name: 'Racha instantánea',  desc: 'Empieza la partida con racha de 2',  price: 30, usableInGame: false),
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

  // --- Power-ups ---
  // extra_time: se activa para LA SIGUIENTE pregunta (+5 seg al límite).
  bool activeExtraTime = false;

  // fifty_fifty: índices de opciones a ocultar en la pregunta actual.
  // Se recalcula cada vez que se usa, y se limpia al pasar de pregunta.
  Set<int> hiddenOptions = {};

  // streak_shield: si está activo, la próxima respuesta incorrecta
  // NO resetea la racha (se consume una sola vez).
  bool streakShieldActive = false;

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
    hiddenOptions = {};
    streakShieldActive = false;
  }

  Pregunta get currentQuestion => preguntas[current];
  bool get isLastQuestion => current >= preguntas.length - 1;
  double get progress => preguntas.isEmpty ? 0 : (current + 1) / preguntas.length;
}

// --- Racha diaria ---
class DailyStreakService {
  static const String _lastPlayedKey = 'trivia_last_played';
  static const String _dailyStreakKey = 'trivia_daily_streak';
  static const String _longestStreakKey = 'trivia_longest_streak';

  /// Registra que el usuario jugó hoy. Devuelve el nuevo estado.
  /// Llama esto UNA VEZ al terminar cada partida.
  static Future<DailyStreakData> registerPlay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final lastPlayed = prefs.getString(_lastPlayedKey) ?? '';
    int streak = prefs.getInt(_dailyStreakKey) ?? 0;
    int longest = prefs.getInt(_longestStreakKey) ?? 0;

    if (lastPlayed == today) {
      // Ya jugó hoy, no cambia nada
      return DailyStreakData(streak: streak, longest: longest, isNew: false);
    }

    final yesterday = _yesterdayKey();
    if (lastPlayed == yesterday) {
      streak++; // Continuó la racha
    } else {
      streak = 1; // Racha rota o primer día
    }

    if (streak > longest) longest = streak;

    await prefs.setString(_lastPlayedKey, today);
    await prefs.setInt(_dailyStreakKey, streak);
    await prefs.setInt(_longestStreakKey, longest);

    return DailyStreakData(streak: streak, longest: longest, isNew: true);
  }

  /// Solo lee el estado actual sin modificarlo (para mostrar en HomeScreen).
  static Future<DailyStreakData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt(_dailyStreakKey) ?? 0;
    final longest = prefs.getInt(_longestStreakKey) ?? 0;
    final lastPlayed = prefs.getString(_lastPlayedKey) ?? '';
    final playedToday = lastPlayed == _todayKey();
    return DailyStreakData(
        streak: streak, longest: longest, isNew: false, playedToday: playedToday);
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _yesterdayKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }
}

class DailyStreakData {
  final int streak;
  final int longest;
  final bool isNew;
  final bool playedToday;

  const DailyStreakData({
    required this.streak,
    required this.longest,
    required this.isNew,
    this.playedToday = false,
  });
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
