import 'dart:io';
import 'dart:convert'; // Para decodificar el JSON de los puntajes
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart'; // Para leer la memoria local


final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();

}

// 2. Agregamos el mixin 'RouteAware' al estado para poder escuchar los eventos de navegación
class _MenuScreenState extends State<MenuScreen> with RouteAware {
  // Lista local para guardar los puntajes cargados de la memoria
  List<Map<String, dynamic>> _topScores = [];

  @override
  void initState() {
    super.initState();
    _cargarHighScores(); // Carga inicial al arrancar el menú por primera vez
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 3. Suscribimos esta pantalla al observador de rutas de Flutter
    final ModalRoute<void>? modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    // 4. Siempre cancelamos la suscripción al destruir la pantalla para evitar fugas de memoria
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // 5. ¡ESTA ES LA MAGIA DEL ROUTEAWARE! 
  // Se ejecuta automáticamente cuando volvemos a esta pantalla desde el Tablero o Victoria
  @override
  void didPopNext() {
    _cargarHighScores(); 
  }

  // Lee el JSON almacenado por el Tablero en 'top_scores_v2'
  Future<void> _cargarHighScores() async {
    // Pequeño retraso de seguridad para asegurar que el almacenamiento físico en disco termine de escribir en Windows
    await Future.delayed(const Duration(milliseconds: 50));
    
    final prefs = await SharedPreferences.getInstance();
    final String? scoresJson = prefs.getString('top_scores_v2');
    
    if (scoresJson != null) {
      List<dynamic> decodificado = jsonDecode(scoresJson);
      setState(() {
        _topScores = decodificado.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], 
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
                  color: Colors.amber, 
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
              const SizedBox(height: 40),

              // 2. LOS BOTONES DEL MENÚ
              _crearBoton('Jugar', Icons.play_arrow, Colors.green[600]!, () {
                // Al usar pushNamed en vez de pushReplacementNamed, la pantalla del menú no se destruye, 
                // se queda de fondo esperando que el juego termine para reactivarse con didPopNext()
                Navigator.of(context).pushNamed('/juego');
              }),
              
              _crearBoton('Configuración', Icons.settings, Colors.blueGrey, () {
                Navigator.of(context).pushNamed('/config');
              }),
              _crearBoton('Cómo jugar', Icons.help_outline, Colors.blueGrey, () {
                Navigator.of(context).pushNamed('/instrucciones');
              }),

              _crearBoton('Créditos', Icons.info_outline, Colors.blueGrey, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Desarrollado por Valeria T. y Alejandro H.')),
                );
              }),
              
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

              // 3. SECCIÓN DE HIGH SCORES DINÁMICA (Lee el Top 3 real)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🏆 MEJORES PUNTUACIONES 🏆',
                      style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontFamily: 'Courier', fontSize: 16),
                    ),
                    const Divider(color: Colors.amber),
                    const SizedBox(height: 8),
                    
                    // Si la memoria está vacía, mostramos guiones estilo arcade vacíos
                    if (_topScores.isEmpty) ...[
                      _filaPuntaje(1, '---', 0),
                      _filaPuntaje(2, '---', 0),
                      _filaPuntaje(3, '---', 0),
                    ] else ...[
                      // Recorremos los datos reales mapeados e imprimimos las posiciones existentes
                      for (int i = 0; i < 3; i++)
                        if (i < _topScores.length)
                          _filaPuntaje(i + 1, _topScores[i]['nombre'], _topScores[i]['score'])
                        else
                          _filaPuntaje(i + 1, '---', 0) // Relleno si hay menos de 3 guardados
                    ],
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

  // Componente estético para alinear perfectamente los nombres y los puntajes en columnas estables
  Widget _filaPuntaje(int posicion, String nombre, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$posicion. $nombre',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Courier', fontWeight: FontWeight.bold),
          ),
          Text(
            score.toString().padLeft(6, '0'), // Rellena con ceros a la izquierda para el look retro
            style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontFamily: 'Courier', fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- FUNCIÓN AUXILIAR PARA CREAR BOTONES RÁPIDO ---
  Widget _crearBoton(String texto, IconData icono, Color colorFondo, VoidCallback alPresionar) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton.icon(
        icon: Icon(icono, color: Colors.white),
        label: Text(
          texto,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorFondo,
          minimumSize: const Size(250, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: alPresionar,
      ),
    );
  }
}