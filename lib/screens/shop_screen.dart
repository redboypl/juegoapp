// ============================================================
// shop_screen.dart — Tienda de power-ups
// Equivalente a screen-shop en index.html
// ============================================================

import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../widgets/settings_button.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _coins = 0;
  Map<String, int> _inventory = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final coins = await StorageService.loadCoins();
    final inventory = await StorageService.loadInventory();
    setState(() {
      _coins = coins;
      _inventory = inventory;
      _loading = false;
    });
  }

  Future<void> _buyPowerup(Powerup p) async {
    if (_coins < p.price) return;
    setState(() {
      _coins -= p.price;
      _inventory[p.id] = (_inventory[p.id] ?? 0) + 1;
    });
    await StorageService.saveCoins(_coins);
    await StorageService.saveInventory(_inventory);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p.icon} ${p.name} comprado!'),
        backgroundColor: const Color(0xFF2D6A4F),
        duration: const Duration(seconds: 2),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // --- Botón volver ---
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  label: const Text(
                    'Volver',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 8),

                // --- Título y monedas ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🛒 Tienda',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
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
                  ],
                ),

                const SizedBox(height: 6),

                const Text(
                  'Usa tus monedas para comprar potenciadores',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),

                const SizedBox(height: 24),

                // --- Lista de power-ups ---
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: ListView.separated(
                          itemCount: powerups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final p = powerups[i];
                            final canBuy = _coins >= p.price;
                            final owned = _inventory[p.id] ?? 0;
                            return _ShopCard(
                              powerup: p,
                              owned: owned,
                              canBuy: canBuy,
                              onBuy: () => _buyPowerup(p),
                            );
                          },
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

// --- Tarjeta individual de power-up ---
class _ShopCard extends StatelessWidget {
  final Powerup powerup;
  final int owned;
  final bool canBuy;
  final VoidCallback onBuy;

  const _ShopCard({
    required this.powerup,
    required this.owned,
    required this.canBuy,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canBuy ? Colors.white24 : Colors.white12,
        ),
      ),
      child: Row(
        children: [

          // --- Ícono ---
          Text(powerup.icon, style: const TextStyle(fontSize: 36)),

          const SizedBox(width: 16),

          // --- Info ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  powerup.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  powerup.desc,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tienes: $owned',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // --- Botón comprar ---
          ElevatedButton(
            onPressed: canBuy ? onBuy : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canBuy
                  ? const Color(0xFFE63946)
                  : Colors.white12,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
            ),
            child: Text(
              '🪙 ${powerup.price}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
