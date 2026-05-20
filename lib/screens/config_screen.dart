import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  // Variables temporales para mantener el estado visual de la pantalla
  bool _modoOscuro = true;
  bool _efectosSonido = true;
  double _volumenMusica = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // SECCIÓN 1: APARIENCIA
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Apariencia',
              style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Modo Oscuro', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Cambiar entre tema oscuro y claro', style: TextStyle(color: Colors.grey)),
            activeColor: Colors.amber,
            value: _modoOscuro,
            onChanged: (bool value) {
              setState(() {
                _modoOscuro = value;
                // TODO: Conectar esto con la lógica real de Theming (Provider, Bloc, etc.)
              });
            },
            secondary: Icon(_modoOscuro ? Icons.dark_mode : Icons.light_mode, color: Colors.white),
          ),
          const Divider(color: Colors.white24),

          // SECCIÓN 2: AUDIO
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Audio',
              style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Efectos de Sonido', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Explosiones y clics', style: TextStyle(color: Colors.grey)),
            activeColor: Colors.amber,
            value: _efectosSonido,
            onChanged: (bool value) {
              setState(() {
                _efectosSonido = value;
              });
            },
            secondary: const Icon(Icons.volume_up, color: Colors.white),
          ),
          
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text('Volumen de Música', style: TextStyle(color: Colors.white)),
          ),
          Slider(
            value: _volumenMusica,
            activeColor: Colors.amber,
            inactiveColor: Colors.grey,
            onChanged: (double value) {
              setState(() {
                _volumenMusica = value;
              });
            },
          ),
        ],
      ),
    );
  }
}