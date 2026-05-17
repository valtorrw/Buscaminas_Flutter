import 'package:flutter/material.dart';
import '../logic.dart';
import '../celda.dart';

class TableroScreen extends StatefulWidget {
  const TableroScreen({super.key});

  @override
  State<TableroScreen> createState() => _TableroScreenState();
}

class _TableroScreenState extends State<TableroScreen> {
  // Instanciamos la lógica para nivel Fácil (6x6 con 10 minas) como pide el PDF
  late BuscaminasLogic _buscaminas;

  @override
  void initState() {
    super.initState() ;
    _buscaminas = BuscaminasLogic(filas: 6, columnas: 6, numMinas: 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Fondo oscuro de ejemplo para resaltar el tablero
      appBar: AppBar(
        title: const Text('Buscaminas Retro'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculo para que el tablero quede cuadrado
              double sizeTablero = constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight;

              return SizedBox(
                width: sizeTablero,
                height: sizeTablero,
                child: GridView.builder(
                  // Desactivamos el scroll interno para que actúe como un tablero fijo
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _buscaminas.columnas, // Número de columnas
                    crossAxisSpacing: 4.0, // Espacio entre celdas
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: _buscaminas.filas * _buscaminas.columnas,
                  itemBuilder: (context, index) {
                    // Convertimos el índice lineal (0 a 35) en coordenadas (fila, columna)
                    int fila = index ~/ _buscaminas.columnas;
                    int columna = index % _buscaminas.columnas;
                    Celda celda = _buscaminas.tablero[fila][columna];

                    return _construirBotonCelda(celda);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget para renderizar cada casilla de forma independiente
  Widget _construirBotonCelda(Celda celda) {
    return InkWell(
      onTap: () {
        // Ejecutamos la acción dentro de un setState para que la pantalla se actualice
        setState(() {
          celda.estaRevelada = true; // Simulación rápida de click
          if (celda.esMina) {
            // Aquí luego disparas la lógica de Game Over
            print("¡BOOM! Explotaste.");
          }
        });
      },
      onLongPress: () {
        // Click largo para poner banderas
        setState(() {
          celda.tieneBandera = !celda.tieneBandera;
        });
      },
      child: Ink(
        decoration: BoxDecoration(
          color: celda.estaRevelada ? Colors.grey[300] : Colors.grey[700],
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: Colors.black26),
        ),
        child: Center(
          child: _contenidoCelda(celda),
        ),
      ),
    );
  }

  // Determina qué se dibuja dentro del cuadrito
  Widget _contenidoCelda(Celda celda) {
    if (celda.tieneBandera) {
      return const Icon(Icons.flag, color: Colors.red, size: 20);
    }
    
    if (!celda.estaRevelada) {
      return const SizedBox(); // Vacío si está oculta
    }

    if (celda.esMina) {
      return const Icon(Icons.brightness_7, color: Colors.black, size: 20); // Icono temporal de mina
    }

    // Si tiene minas alrededor y es mayor a 0, muestra el número
    if (celda.minasAlrededor > 0) {
      return Text(
        '${celda.minasAlrededor}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: _obtenerColorNumero(celda.minasAlrededor),
        ),
      );
    }

    return const SizedBox(); // Vacío si es un "0"
  }

  // Estilo Clásico que pide el PDF (1=azul, 2=verde, 3=rojo...)
  Color _obtenerColorNumero(int numero) {
    switch (numero) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return const Color(0xFF000080); // Azul oscuro
      default: return Colors.purple;
    }
  }
}