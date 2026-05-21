import 'package:flutter/material.dart';

class InstruccionesScreen extends StatelessWidget {
  const InstruccionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Cómo Jugar'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Regresa al menú
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reglas Básicas:',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            //Aqui es donde se coloca el texto
            const SizedBox(height: 20),
            _construirRegla(
              Icons.format_list_numbered,
              'Escoge la dificultad deseada antes de empezar.',
            ),
            const SizedBox(height: 16),
            _construirRegla(
              Icons.touch_app,
              'Dale clic (o toque) a una casilla para revelarla.',
            ),
            const SizedBox(height: 16),
            _construirRegla(
              Icons.flag,
              'Para colocar una bandera, mantén presionado el clic o toque sobre la casilla.',
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('¡Entendido!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Función para dar formato bonito a cada instrucción
  Widget _construirRegla(IconData icono, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: Colors.white, size: 30),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    );
  }
}