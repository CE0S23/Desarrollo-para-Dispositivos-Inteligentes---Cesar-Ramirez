import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Importante para el escáner BLE
import '../providers/weather_provider.dart';
import '../widgets/weather_icon.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Aquí está la clase del estado de la que hablábamos
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carga los datos iniciales al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).loadWeather('Santiago de Querétaro');
    });
  }

  // MÉTODO PARA MOSTRAR LA VENTANA EMERGENTE DEL ESCÁNER BLE
  void _showBleScanner(BuildContext context, WeatherProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Dispositivos BLE Cercanos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: StreamBuilder<List<ScanResult>>(
                stream: provider.bleService.scanForDevices(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Buscando..."));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final result = snapshot.data![index];
                      // Filtrar dispositivos sin nombre
                      //if (result.device.platformName.isEmpty) return const SizedBox.shrink();
                      
                      return ListTile(
                        title: Text(result.device.platformName),
                        subtitle: Text(result.device.remoteId.toString()),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Cerrar el modal
                            provider.connectToWearable(result.device); // Conectar
                          },
                          child: const Text('Conectar'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape = width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Clima Actual'), centerTitle: true),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.errorMessage != "Sin conexión BLE") {
            return Center(child: Text(provider.errorMessage!));
          }
          if (provider.weather == null) {
            return const Center(child: Text('No hay datos'));
          }

          // Todo el contenido visual centralizado en una lista
          final weatherContent = [
            if (provider.isBleConnected)
              const Text('🟢 Conectado al Wearable', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            if (!provider.isBleConnected && provider.errorMessage == "Sin conexión BLE")
              const Text('🔴 Sin conexión BLE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              
            Text(
              '${provider.displayTemperature}${provider.temperatureUnit}',
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            Text(provider.weather!.city, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            WeatherIcon(condition: provider.weather!.condition),
            const SizedBox(height: 32),
            Text('Humedad: ${provider.weather!.humidity}% | Viento: 12 km/h'),
            const SizedBox(height: 40),
            
            // Botones de Conversión y Búsqueda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => provider.toggleTemperatureUnit(),
                  child: const Text('Cambiar °C / °F'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchScreen()),
                    );
                  },
                  child: const Text('Buscar Ciudades'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // BOTÓN BLE
            ElevatedButton.icon(
              icon: const Icon(Icons.bluetooth),
              label: Text(provider.isBleConnected ? 'Desconectar Wearable' : 'Buscar dispositivos BLE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isBleConnected ? Colors.red.shade100 : Colors.blue.shade100
              ),
              onPressed: () {
                if (provider.isBleConnected) {
                  provider.disconnectWearable();
                } else {
                  // Aquí se manda a llamar el método que abre el escáner
                  _showBleScanner(context, provider);
                }
              },
            ),
          ];

          // Diseño responsivo
          return Center(
            child: isLandscape
                ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: weatherContent)
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: weatherContent),
          );
        },
      ),
    );
  }
}