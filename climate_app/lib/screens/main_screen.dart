import 'package:flutter/material.dart';
import 'home_screen.dart';
// Asegúrate de importar tus otras pantallas
// import 'detail_screen.dart';
// import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Aquí pones las 3 pantallas que diseñaste
  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Pantalla de Detalle (En construcción)', style: TextStyle(color: Colors.white))), // Reemplaza con tu DetailScreen()
    const Center(child: Text('Pantalla de Ajustes (En construcción)', style: TextStyle(color: Colors.white))), // Reemplaza con tu SettingsScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo general oscuro
      body: _screens[_selectedIndex], // Muestra la pantalla seleccionada
      
      // TU BARRA DE NAVEGACIÓN INFERIOR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white12, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0x99000000), // Negro semitransparente
          unselectedItemColor: Colors.white54,
          selectedItemColor: const Color(0xFFC41E3A), // Tu rojo característico
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_outlined),
              activeIcon: Icon(Icons.cloud),
              label: 'INICIO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              activeIcon: Icon(Icons.location_on),
              label: 'CIUDAD',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'AJUSTES',
            ),
          ],
        ),
      ),
    );
  }
}