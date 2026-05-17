import 'dart:math';
import 'celda.dart';

class BuscaminasLogic {
  final int filas;
  final int columnas;
  final int numMinas;
  
  late List<List<Celda>> tablero;
  bool juegoTerminado = false;
  bool victoria = false;

  BuscaminasLogic({
    required this.filas,
    required this.columnas,
    required this.numMinas,
  }) {
    _inicializarTablero();
  }

  // 1. Crea la cuadrícula vacía
  void _inicializarTablero() {
    tablero = List.generate(filas, (f) {
      return List.generate(columnas, (c) => Celda(fila: f, columna: c));
    });
    _colocarMinas();
    _calcularNumeros();
  }

  // 2. Coloca las minas aleatoriamente
  void _colocarMinas() {
    int minasColocadas = 0;
    Random random = Random();

    while (minasColocadas < numMinas) {
      int f = random.nextInt(filas);
      int c = random.nextInt(columnas);

      if (!tablero[f][c].esMina) {
        tablero[f][c].esMina = true;
        minasColocadas++;
      }
    }
  }

  // 3. Calcula cuántas minas tiene cada casilla alrededor
  void _calcularNumeros() {
    for (int f = 0; f < filas; f++) {
      for (int c = 0; c < columnas; c++) {
        if (tablero[f][c].esMina) continue;

        int contador = 0;
        // Revisa las 8 casillas vecinas
        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {
            int nuevaF = f + i;
            int nuevaC = c + j;

            // Verifica que no se salga de los límites de la matriz
            if (nuevaF >= 0 && nuevaF < filas && nuevaC >= 0 && nuevaC < columnas) {
              if (tablero[nuevaF][nuevaC].esMina) {
                contador++;
              }
            }
          }
        }
        tablero[f][c].minasAlrededor = contador;
      }
    }
  }
}