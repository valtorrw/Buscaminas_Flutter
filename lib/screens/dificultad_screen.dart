import 'package:flutter/material.dart';
import 'tablero_screen.dart';

class DificultadesScreen extends StatelessWidget {
  const DificultadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], 
      appBar: AppBar(
        title: const Text('Seleccionar Dificultad'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Permite volver al menú principal
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),


              // BOTÓN FÁCIL (6x6 - 10 Minas)
              _crearBotonDificultad(
                context: context,
                texto: 'Fácil (6x6)',
                subtitulo: '10 Minas — Para empezar',
                icono: Icons.sentiment_satisfied_alt,
                colorFondo: Colors.green[700]!,
                filas: 6,
                columnas: 6,
                minas: 10,
              ),

              // BOTÓN NORMAL (9x9 - 16 Minas)
              _crearBotonDificultad(
                context: context,
                texto: 'Normal (8x8)',
                subtitulo: '20 Minas — El clásico',
                icono: Icons.sentiment_neutral,
                colorFondo: Colors.orange[700]!,
                filas: 8,
                columnas: 8,
                minas: 20,
              ),

              // BOTÓN DIFÍCIL (12x12 - 28 Minas)
              _crearBotonDificultad(
                context: context,
                texto: 'Difícil (10x10)',
                subtitulo: '30 Minas — Modo experto',
                icono: Icons.sentiment_very_dissatisfied,
                colorFondo: Colors.red[800]!,
                filas: 10,
                columnas: 10,
                minas: 30,
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNCIÓN AUXILIAR PARA LOS BOTONES DE DIFICULTAD ---
  Widget _crearBotonDificultad({
    required BuildContext context,
    required String texto,
    required String subtitulo,
    required IconData icono,
    required Color colorFondo,
    required int filas,
    required int columnas,
    required int minas,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorFondo,
          minimumSize: const Size(280, 70), // Un poco más altos para el subtítulo
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onPressed: () {
          // Navegamos directamente al Tablero pasando la configuración elegida
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TableroScreen(
                filas: filas,
                columnas: columnas,
                numMinas: minas,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Icon(icono, color: Colors.white, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    texto,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}