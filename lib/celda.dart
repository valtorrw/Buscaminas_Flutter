class Celda {
  final int fila;
  final int columna;
  
  bool esMina;
  bool estaRevelada;
  bool tieneBandera;
  int minasAlrededor; // Guarda el número (0 si está vacía, 1, 2, etc.)

  Celda({
    required this.fila,
    required this.columna,
    this.esMina = false,
    this.estaRevelada = false,
    this.tieneBandera = false,
    this.minasAlrededor = 0,
  });
}