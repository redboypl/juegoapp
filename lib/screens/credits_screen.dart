// ============================================================
// credits_screen.dart — Pantalla de créditos
// Equivalente a screen-credits en index.html
// ============================================================

import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

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

                const SizedBox(height: 24),

                // --- Contenido centrado ---
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        const Text('⚾', style: TextStyle(fontSize: 64)),

                        const SizedBox(height: 16),

                        const Text(
                          'Créditos',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Este juego fue creado con pasión\npor el béisbol venezolano.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- Tarjeta 1 ---
                        _CreditCard(
                          role: 'Diseño y Desarrollo',
                          name: 'Francisco González',
                        ),

                        const SizedBox(height: 12),

                        // --- Tarjeta 2 ---
                        _CreditCard(
                          role: 'Contenido y Preguntas',
                          name: 'Francisco González',
                        ),

                        const SizedBox(height: 32),

                        const Text(
                          '🇻🇪 Hecho con orgullo venezolano',
                          style: TextStyle(
                            color: Color(0xFFFFD60A),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

// --- Widget reutilizable para cada tarjeta de crédito ---
class _CreditCard extends StatelessWidget {
  final String role;
  final String name;

  const _CreditCard({required this.role, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            role,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
