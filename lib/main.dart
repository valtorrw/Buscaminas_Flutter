import 'package:busca_mina/screens/config_screen.dart';
//import 'package:busca_mina/screens/tablero_screen.dart';
import 'package:busca_mina/screens/menu_screen.dart';
import 'package:busca_mina/screens/dificultad_screen.dart';
import 'package:busca_mina/screens/instruciones_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscaminas Flutter',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData.dark(),
      
      // Primera palabra que se abre
      initialRoute: '/',
      
      //Mapa de navegacion
      routes: {
        '/': (context) => const MenuScreen(),
        '/juego': (context) => const DificultadesScreen(),
        '/config': (context) => const ConfiguracionScreen(),    
        '/instrucciones': (context) => const InstruccionesScreen(),
      },
    );
  }
}