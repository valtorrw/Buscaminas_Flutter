import 'package:flutter/material.dart';
import 'tablero_screen.dart';

class DificultadesScreen extends StatefulWidget {
  const DificultadesScreen({super.key});

  @override
  State<DificultadesScreen> createState() => _DificultadesScreenState();
}

class _DificultadesScreenState extends State<DificultadesScreen> {
  // Controlador para capturar el texto del nombre
  final TextEditingController _nombreController = TextEditingController();
  
  // Variable para verificar en tiempo real si el campo está vacío
  bool _botoHabilitado = false;

  @override
  void initState() {
    super.initState(); {
      // Escuchamos los cambios del input para activar/desactivar botones
      _nombreController.addListener(_validarInput);
    }
  }

  void _validarInput() {
    setState(() {
      _botoHabilitado = _nombreController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], 
      appBar: AppBar(
        title: const Text('Seleccionar Dificultad'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( // Evita problemas de desbordamiento con el teclado
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // --- CAMPO DE TEXTO PARA EL NOMBRE ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Introduce tu nombre de jugador:',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nombreController,
                        maxLength: 15, // Evita nombres gigantes en la tabla de puntajes
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ej. Proplayer01',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          counterStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.black,
                          prefixIcon: const Icon(Icons.person, color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

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

                // BOTÓN NORMAL (8x8 - 20 Minas)
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

                // BOTÓN DIFÍCIL (10x10 - 30 Minas)
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

                const SizedBox(height: 20),
              ],
            ),
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
          // Si el botón está deshabilitado, Flutter reduce automáticamente la opacidad o usa color gris
          backgroundColor: _botoHabilitado ? colorFondo : Colors.grey[700],
          minimumSize: const Size(280, 70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        // Si _botoHabilitado es falso, onPressed es null, lo que deshabilita el botón por completo
        onPressed: _botoHabilitado 
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TableroScreen(
                    filas: filas,
                    columnas: columnas,
                    numMinas: minas,
                    nombreUsuario: _nombreController.text.trim(), // Enviamos el nombre
                  ),
                ),
              );
            }
          : null, 
        child: Row(
          children: [
            Icon(icono, color: _botoHabilitado ? Colors.white : Colors.white30, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    texto,
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: _botoHabilitado ? Colors.white : Colors.white30,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 13, 
                      color: _botoHabilitado ? Colors.white.withOpacity(0.85) : Colors.white30,
                    ),
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