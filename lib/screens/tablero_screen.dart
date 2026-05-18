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
        title: const Text('Buscaminas'),
        //centerTitle: true,
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

// 1. Modificamos el diseño exterior de la casilla para usar tus imágenes de fondo
  Widget _construirBotonCelda(Celda celda) {
    return InkWell(
      onTap: () {
        setState(() {
          celda.estaRevelada = true;
          if (celda.esMina) {
            print("¡BOOM! Explotaste.");
            // Aquí luego revelarás todas las minas del tablero
          }
        });
      },
      onLongPress: () {
        setState(() {
          celda.tieneBandera = !celda.tieneBandera;
        });
      },
      child: Ink(
        decoration: BoxDecoration(
          color: celda.estaRevelada ? Colors.grey[300] : Colors.grey[700], // Color de respaldo por seguridad
          borderRadius: BorderRadius.circular(4.0),
          image: DecorationImage(
            // Cambiado a BoxFit.fill para que el fondo ocupe obligatoriamente todo el cuadro
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

  // 2. Modificamos el interior para pintar tus imágenes encima del fondo
  Widget _contenidoCelda(Celda celda) {
    // REGLA 1: Si tiene bandera (y no está revelada), muestra tu imagen de bandera
    if (celda.tieneBandera && !celda.estaRevelada) {
      return Image.asset(
        'assets/imagenes/masked_tile_flag.png',
        fit: BoxFit.fill, // Ocupa todo el contenedor
      );
    }
    
    // REGLA 2: Si está oculta y no tiene bandera, no se dibuja nada adentro
    if (!celda.estaRevelada) {
      return const SizedBox();
    }

    // REGLA 3: Si está revelada y es una mina, muestra tu imagen de bomba
    if (celda.esMina) {
      return Image.asset(
        'assets/imagenes/revealed_tile_bomb.png',
        fit: BoxFit.fill, // Ocupa todo el contenedor
      );
    }

    // REGLA 4: Si tiene minas alrededor (del 1 al 8), cargamos dinámicamente tu imagen del número
    if (celda.minasAlrededor > 0) {
      return Image.asset(
        'assets/imagenes/revealed_tile_${celda.minasAlrededor}.png', 
        fit: BoxFit.fill, // Ocupa todo el contenedor
      );
    }

    // Si es un "0", queda vacío mostrando solo el fondo de cuadro_revelado
    return const SizedBox();
  }
}