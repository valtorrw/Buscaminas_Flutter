import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'gameover_screen.dart';
import 'victoria_screen.dart';
import '../logic.dart';
import '../celda.dart';
import 'dart:convert';
import 'dart:async';


class TableroScreen extends StatefulWidget {
  final int filas;
  final int columnas;
  final int numMinas;
  final String nombreUsuario;

  const TableroScreen({
    super.key,
    required this.filas,
    required this.columnas,
    required this.numMinas,
    required this.nombreUsuario,
  });

  @override
  State<TableroScreen> createState() => _TableroScreenState();
}

class _TableroScreenState extends State<TableroScreen> {
  late BuscaminasLogic _buscaminas;
  
  Timer? _timer;
  int _segundosActivos = 0;
  int _score = 0;
  bool _partidaTerminada = false;
  bool _modoDiosActivo = false; 

  @override
  void initState() {
    super.initState();
    _iniciarNuevaPartida();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarNuevaPartida() {
    _buscaminas = BuscaminasLogic(
      filas: widget.filas,
      columnas: widget.columnas,
      numMinas: widget.numMinas,
    );
    _segundosActivos = 0;
    _score = 0;
    _partidaTerminada = false;
    _timer?.cancel();
    _arrancarCronometro();
  }

  void _arrancarCronometro() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_partidaTerminada) {
        setState(() {
          _segundosActivos++;
          _actualizarPuntaje(esBonoVictoria: false);
        });
      }
    });
  }

  // --- CONTROL DEL SCORE ---
  void _actualizarPuntaje({required bool esBonoVictoria}) {
    int celdasReveladas = 0;
    for (var fila in _buscaminas.tablero) {
      for (var celda in fila) {
        if (celda.estaRevelada && !celda.esMina) {
          celdasReveladas++;
        }
      }
    }

    int multiplicadorDificultad = widget.numMinas; 
    int puntosCasillas = celdasReveladas * 10 * multiplicadorDificultad;
    int penalizacionTiempo = _segundosActivos * 2;

    int puntajeCalculado = puntosCasillas - penalizacionTiempo;

    if (esBonoVictoria) {
      int bonoVelocidad = 5000 - (_segundosActivos * 20);
      puntajeCalculado += bonoVelocidad > 0 ? bonoVelocidad : 500;
    }

    _score = puntajeCalculado < 0 ? 0 : puntajeCalculado;
  }

  // --- PERSISTENCIA LOCAL (SHARED PREFERENCES) ---
  
  // 1. Ahora leemos la memoria buscando el JSON en 'top_scores_v2'
  Future<List<Map<String, dynamic>>> _obtenerTopScores() async {
    final prefs = await SharedPreferences.getInstance();
    final String? scoresJson = prefs.getString('top_scores_v2'); 
    
    if (scoresJson == null) return [];
    
    // Decodificamos el JSON a una lista de mapas
    List<dynamic> decodificado = jsonDecode(scoresJson);
    return decodificado.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // 2. Modificamos el guardado para recibir también el nombre
  Future<bool> _guardarPuntajeSiEsTop(int nuevoScore, String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> actuales = await _obtenerTopScores();

    // Añadimos el nuevo registro como un Mapa (Diccionario)
    actuales.add({
      'nombre': nombre,
      'score': nuevoScore,
    });
    
    // Ordenamos. 
    // Nota: Si en tu Buscaminas el score es TIEMPO, el menor es mejor: a['score'].compareTo(b['score'])
    // Como tu código anterior usaba b.compareTo(a) (mayor es mejor), lo mantengo así:
    actuales.sort((a, b) => b['score'].compareTo(a['score']));

    // Mantenemos únicamente el Top 3 histórico
    if (actuales.length > 3) {
      actuales = actuales.sublist(0, 3);
    }

    // Convertimos la lista de mapas a un String JSON y lo guardamos
    final String jsonParaGuardar = jsonEncode(actuales);
    await prefs.setString('top_scores_v2', jsonParaGuardar); // Usamos setString, no setStringList

    // Comprobamos si el score recién guardado quedó entre los 3 primeros
    return actuales.any((registro) => registro['score'] == nuevoScore && registro['nombre'] == nombre);
  }

  // --- COMPROBACIÓN DE VICTORIA ---
  void _verificarCondicionVictoria() {
    int celdasReveladas = 0;
    for (var fila in _buscaminas.tablero) {
      for (var celda in fila) {
        if (celda.estaRevelada && !celda.esMina) {
          celdasReveladas++;
        }
      }
    }

    int celdasParaGanar = (widget.filas * widget.columnas) - widget.numMinas;

    if (celdasReveladas == celdasParaGanar) {
      _partidaTerminada = true;
      _timer?.cancel(); 
      _actualizarPuntaje(esBonoVictoria: true); 

      _mostrarPantallaVictoria();
    }
  }

  // Cambiamos a función asíncrona para esperar la respuesta de SharedPreferences
  void _mostrarPantallaVictoria() async {
    bool comprobarSiEsTop3 = await _guardarPuntajeSiEsTop(_score, widget.nombreUsuario);
    if (!mounted) return; // Control por si destruyen el Widget durante el "await"

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VictoryScreen( 
          score: _score,
          tiempo: _formatearTiempo(_segundosActivos),
          esTop3: comprobarSiEsTop3, // Valor dinámico e histórico real
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

  String _formatearTiempo(int segundosTotales) {
    int minutes = segundosTotales ~/ 60;
    int segundos = segundosTotales % 60;
    return '${minutes.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
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
        title: const Text('Buscaminas Retro'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              _modoDiosActivo ? Icons.bolt : Icons.bolt_outlined,
              color: _modoDiosActivo ? Colors.amber : Colors.white54,
            ),
            tooltip: 'Modo Dios',
            onPressed: () {
              setState(() {
                _modoDiosActivo = !_modoDiosActivo;
              });
            },
          ),
        if (_modoDiosActivo && !_partidaTerminada)
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.greenAccent),
            tooltip: 'Forzar Victoria',
            onPressed: () {
              setState(() {
                for (var fila in _buscaminas.tablero) {
                  for (var celda in fila) {
                    if (!celda.esMina) celda.estaRevelada = true;
                  }
                }
                _verificarCondicionVictoria(); 
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _crearDisplayMarcador(
                    icono: Icons.brightness_low_sharp,
                    colorIcono: Colors.redAccent,
                    valor: _calcularMinasRestantes().toString().padLeft(2, '0'),
                  ),
                  IconButton(
                    icon: Icon(
                      _partidaTerminada ? Icons.sentiment_very_satisfied : Icons.sentiment_satisfied, 
                      size: 38, 
                      color: Colors.amber
                    ),
                    onPressed: () {
                      setState(() {
                        _iniciarNuevaPartida();
                      });
                    },
                  ),
                  _crearDisplayMarcador(
                    icono: Icons.timer,
                    colorIcono: Colors.amber,
                    valor: _formatearTiempo(_segundosActivos),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[800]!, width: 2),
                ),
                child: Text(
                  'SCORE: ${_score.toString().padLeft(6, '0')}', 
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.greenAccent, 
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double sizeTablero = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight;

                    return Center(
                      child: SizedBox(
                        width: sizeTablero,
                        height: sizeTablero,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _crearDisplayMarcador({required IconData icono, required Color colorIcono, required String valor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
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
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBotonCelda(Celda celda, int fila, int columna) {
    return InkWell(
      onTap: () {
        if (celda.tieneBandera || celda.estaRevelada || _partidaTerminada) return;

        setState(() {
          _revelarCeldaRecursivo(fila, columna);
          _actualizarPuntaje(esBonoVictoria: false);
          _verificarCondicionVictoria(); 
          
          if (celda.esMina) {
            _partidaTerminada = true;
            _timer?.cancel(); 

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
        if (celda.estaRevelada || _partidaTerminada) return;
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
      if (_modoDiosActivo && celda.esMina) {
        return Opacity(
          opacity: 0.35, 
          child: Image.asset(
            'assets/imagenes/revealed_tile_bomb.png',
            fit: BoxFit.fill,
          ),
        );
      }
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