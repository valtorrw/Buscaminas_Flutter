import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Una pantalla completa dedicada al estado de Game Over (Derrota).
/// Recibe funciones callback para que el botón de reiniciar o ir al menú
/// puedan ejecutar la lógica que ya tienes definida en otras partes de tu app.
class GameOverScreen extends StatelessWidget {
  final VoidCallback onReiniciar;
  final VoidCallback onIrAlMenu;

  const GameOverScreen({
    super.key,
    required this.onReiniciar,
    required this.onIrAlMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Un fondo oscuro y dramático para la pantalla de muerte
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Un icono grande y dramático de advertencia/derrota
              const Icon(
                Icons.dangerous_outlined,
                color: Colors.redAccent,
                size: 100,
              ),
              const SizedBox(height: 20),

              // Título de la pantalla
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 10),

              // Subtítulo con mensaje al jugador
              const Text(
                'Has detonado una mina. Tu partida ha terminado.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 50),

              // Contenedor de los botones de acción
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. BOTÓN REINICIAR
                    ElevatedButton.icon(
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('REINICIAR JUEGO'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Primero ejecutamos tu lógica de reinicio
                        onReiniciar();
                        // Luego cerramos esta pantalla para volver al tablero limpio
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. BOTÓN MENÚ PRINCIPAL
                    ElevatedButton.icon(
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('MENÚ PRINCIPAL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Ejecutamos la acción de ir al menú
                        onIrAlMenu();
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. BOTÓN SALIR Y CERRAR APLICACIÓN
                    OutlinedButton.icon(
                      icon: const Icon(Icons.exit_to_app_rounded),
                      label: const Text('SALIR DEL JUEGO'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                      // 1. Primero verificamos si estamos en la Web
                      if (kIsWeb) {
                        // En la web no se puede cerrar la pestaña por seguridad.
                        // Lo devolvemos al menú principal de forma segura.
                        Navigator.of(context).pushReplacementNamed('/');
                      } 
                      // 2. Si NO es web, entonces sí evaluamos el sistema operativo
                      else if (Platform.isAndroid || Platform.isIOS) {
                        SystemNavigator.pop(); // Cierre en móviles
                      } else {
                        exit(0); // Cierre en Windows/Mac/Linux
                      }
                    },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}