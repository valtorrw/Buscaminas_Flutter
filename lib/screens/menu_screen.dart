import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Mismo tono retro del tablero
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // 1. EL TÍTULO GIGANTE
              const Text(
                'BuscaMinas',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber, // Un amarillo retro
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(3.0, 3.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // 2. LOS BOTONES DEL MENÚ
              _crearBoton('Jugar', Icons.play_arrow, Colors.green[600]!, () {
                Navigator.of(context).pushReplacementNamed('/juego');
              }),
              
              // --- AQUÍ ESTÁN LOS CAMBIOS DE NAVEGACIÓN ---
              _crearBoton('Configuración', Icons.settings, Colors.blueGrey, () {
                Navigator.of(context).pushNamed('/config');
              }),
              _crearBoton('Cómo jugar', Icons.help_outline, Colors.blueGrey, () {
                Navigator.of(context).pushNamed('/instrucciones');
              }),
              // --------------------------------------------

              _crearBoton('Créditos', Icons.info_outline, Colors.blueGrey, () {
                // Como aún no tenemos pantalla de créditos, mostramos un aviso rápido
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Desarrollado por Valeria T. y Alejandro H.')),
                );
              }),
              
              // Botón de Salir (con la protección para Web)
              _crearBoton('Salir del Juego', Icons.exit_to_app, Colors.red[700]!, () {
                if (kIsWeb) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Juega desde la versión instalada para salir.')),
                  );
                } else if (Platform.isAndroid || Platform.isIOS) {
                  SystemNavigator.pop();
                } else {
                  exit(0);
                }
              }),

              const Spacer(flex: 2),

              // 3. SECCIÓN DE HIGH SCORES (Top 3)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🏆 MEJORES PUNTUACIONES 🏆',
                      style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                    Divider(color: Colors.amber),
                    SizedBox(height: 8),
                    // Datos de prueba (Luego los puedes leer de una base de datos o SharedPreferences)
                    Text('1. AAA - 00:45', style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text('2. JUG - 01:12', style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text('3. DEV - 01:30', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNCIÓN AUXILIAR PARA CREAR BOTONES RÁPIDO ---
  Widget _crearBoton(String texto, IconData icono, Color colorFondo, VoidCallback alPresionar) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icono, color: Colors.white),
        label: Text(
          texto,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorFondo,
          minimumSize: const Size(250, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: alPresionar,
      ),
    );
  }
}