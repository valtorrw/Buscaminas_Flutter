import 'package:flutter/material.dart';
import 'gameover_screen.dart';
import '../logic.dart';
import '../celda.dart';
import 'dart:async';

class TableroScreen extends StatefulWidget {
  final int filas;
  final int columnas;
  final int numMinas;

  const TableroScreen({
    super.key,
    required this.filas,
    required this.columnas,
    required this.numMinas,
  });

  @override
  State<TableroScreen> createState() => _TableroScreenState();
}

class _TableroScreenState extends State<TableroScreen> {
  late BuscaminasLogic _buscaminas;
  
  // Variables para el control del tiempo
  Timer? _timer;
  int _segundosActivos = 0;

  @override
  void initState() {
    super.initState();
    _iniciarNuevaPartida();
  }

  // Limpiamos el timer cuando el jugador salga de esta pantalla para evitar fugas de memoria
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Reinicia tanto la matriz de juego como el reloj
  void _iniciarNuevaPartida() {
    _buscaminas = BuscaminasLogic(
      filas: widget.filas,
      columnas: widget.columnas,
      numMinas: widget.numMinas,
    );
    _segundosActivos = 0;
    _timer?.cancel(); // Reseteamos cualquier timer viejo activo
    _arrancarCronometro();
  }

  void _arrancarCronometro() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _segundosActivos++;
      });
    });
  }

  // Cuenta cuántas banderas activas hay en el tablero para restar al marcador
  int _calcularMinasRestantes() {
    int banderasColocadas = 0;
    for (var fila in _buscaminas.tablero) {
      for (var celda in fila) {
        if (celda.tieneBandera && !celda.estaRevelada) {
          banderasColocadas++;
        }
      }
    }
    return widget.numMinas - banderasColocadas;
  }

  // Convierte los segundos a formato MM:SS
  String _formatearTiempo(int segundosTotales) {
    int minutos = segundosTotales ~/ 60;
    int segundos = segundosTotales % 60;
    String minStr = minutos.toString().padLeft(2, '0');
    String segStr = segundos.toString().padLeft(2, '0');
    return '$minStr:$segStr';
  }

  void _revelarCeldaRecursivo(int fila, int columna) {
    if (fila < 0 || fila >= _buscaminas.filas || columna < 0 || columna >= _buscaminas.columnas) {
      return;
    }

    Celda celda = _buscaminas.tablero[fila][columna];
    if (celda.estaRevelada || celda.tieneBandera) return;

    celda.estaRevelada = true;

    if (!celda.esMina && celda.minasAlrededor == 0) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (i != 0 || j != 0) {
            _revelarCeldaRecursivo(fila + i, columna + j);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Buscaminas'),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        // Quitamos el scroll para que la pantalla sea fija y el tablero se vea forzado a estirarse
        child: Column(
          children: [
            const SizedBox(height: 16),

            // --- PANEL SUPERIOR DE MARCADORES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Marcador de Bombas Restantes
                  _crearDisplayMarcador(
                    icono: Icons.brightness_low_sharp,
                    colorIcono: Colors.redAccent,
                    valor: _calcularMinasRestantes().toString(),
                  ),

                  // Botón rápido de reinicio en medio
                  IconButton(
                    icon: const Icon(Icons.sentiment_satisfied, size: 36, color: Colors.amber),
                    onPressed: () {
                      setState(() {
                        _iniciarNuevaPartida();
                      });
                    },
                  ),

                  // Marcador del Cronómetro
                  _crearDisplayMarcador(
                    icono: Icons.timer,
                    colorIcono: Colors.amber,
                    valor: _formatearTiempo(_segundosActivos),
                  ),
                ],
              ),
            ),

            // --- EL TABLERO DE JUEGO (Expandido y Autoajustable) ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Tomamos el espacio real sobrante de la pantalla y elegimos el menor 
                    // para asegurar que el tablero sea un cuadrado perfecto sin desbordar.
                    double sizeTablero = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight;

                    return Center(
                      child: SizedBox(
                        width: sizeTablero,
                        height: sizeTablero,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(), // Evita scroll interno cruzado
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _buscaminas.columnas,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemCount: _buscaminas.filas * _buscaminas.columnas,
                          itemBuilder: (context, index) {
                            int fila = index ~/ _buscaminas.columnas;
                            int columna = index % _buscaminas.columnas;
                            Celda celda = _buscaminas.tablero[fila][columna];

                            return _construirBotonCelda(celda, fila, columna);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- WIDGET ESTILIZADO PARA LOS MARCADORES ---
  Widget _crearDisplayMarcador({required IconData icono, required Color colorIcono, required String valor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black, // Fondo negro estilo pantalla digital
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[800]!, width: 2),
      ),
      child: Row(
        children: [
          Icon(icono, color: colorIcono, size: 22),
          const SizedBox(width: 8),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.red, // Letras rojas estilo marcador digital antiguo
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier', // Fuente monoespaciada para toque retro
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBotonCelda(Celda celda, int fila, int columna) {
    return InkWell(
      onTap: () {
        if (celda.tieneBandera || celda.estaRevelada) return;

        setState(() {
          _revelarCeldaRecursivo(fila, columna);
          
          if (celda.esMina) {
            _timer?.cancel(); // se congela el temporizador 

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => GameOverScreen(
                  onReiniciar: () {
                    setState(() {
                      _iniciarNuevaPartida();
                    });
                  },
                  onIrAlMenu: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),
              ),
            );
          }
        });
      },
      onLongPress: () {
        if (celda.estaRevelada) return;
        setState(() {
          celda.tieneBandera = !celda.tieneBandera;
        });
      },
      child: Ink(
        decoration: BoxDecoration(
          color: celda.estaRevelada ? Colors.grey[300] : Colors.grey[700],
          borderRadius: BorderRadius.circular(4.0),
          image: DecorationImage(
            image: AssetImage(
              celda.estaRevelada 
                  ? 'assets/imagenes/masked_tile.png' 
                  : 'assets/imagenes/revealed_tile.png'
            ),
            fit: BoxFit.fill, 
          ),
        ),
        child: Center(
          child: _contenidoCelda(celda),
        ),
      ),
    );
  }

  Widget _contenidoCelda(Celda celda) {
    if (celda.tieneBandera && !celda.estaRevelada) {
      return Image.asset(
        'assets/imagenes/masked_tile_flag.png',
        fit: BoxFit.fill,
      );
    }
    
    if (!celda.estaRevelada) {
      return const SizedBox();
    }

    if (celda.esMina) {
      return Image.asset(
        'assets/imagenes/revealed_tile_bomb.png',
        fit: BoxFit.fill,
      );
    }

    if (celda.minasAlrededor > 0) {
      return Image.asset(
        'assets/imagenes/revealed_tile_${celda.minasAlrededor}.png', 
        fit: BoxFit.fill,
      );
    }

    return const SizedBox();
  }
}