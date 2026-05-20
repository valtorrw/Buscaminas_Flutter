import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VictoryScreen extends StatelessWidget {
  final int score;
  final String tiempo;
  final bool esTop3; // Pasamos este flag desde el tablero
  final VoidCallback onReiniciar;
  final VoidCallback onIrAlMenu;

  const VictoryScreen({
    super.key,
    required this.score,
    required this.tiempo,
    required this.esTop3,
    required this.onReiniciar,
    required this.onIrAlMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- ICONO CORONA/COPA ---
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 100,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),

                // --- TÍTULO PRINCIPAL ---
                const Text(
                  '¡VICTORIA!',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),

                // --- CONTADOR DE SCORE ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'PUNTUACIÓN FINAL',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: 'Courier',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${score.toString().padLeft(6, '0')} PTS',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TIEMPO: $tiempo',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- ANUNCIO DE TOP 3 (PREPARADO PARA EL FUTURO) ---
                if (esTop3)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.local_fire_department, color: Colors.amber, size: 24),
                        SizedBox(width: 8),
                        Text(
                          '¡NUEVO RÉCORD! ENTRASTE AL TOP 3',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 50),

                // --- BOTONES DE CONTROL DE FLUJO ---
                
               // 1. Volver a Jugar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra la pantalla de victoria
                      onReiniciar(); // Ejecuta el reinicio en el tablero
                    },
                    child: const Text(
                      'VOLVER A JUGAR',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Menú Principal
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: onIrAlMenu,
                    child: const Text(
                      'MENÚ PRINCIPAL',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Salir del Juego
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      // Cierra la aplicación de forma limpia tanto en Android como iOS
                      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    },
                    child: Text(
                      'SALIR DEL JUEGO',
                      style: TextStyle(fontSize: 16, color: Colors.red[400]),
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