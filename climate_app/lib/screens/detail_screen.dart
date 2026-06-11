import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String city;

  const DetailScreen({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$city 5 Días')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Text('Lun\n24°C\n☁️', textAlign: TextAlign.center),
                Text('Mar\n26°C\n☀️', textAlign: TextAlign.center),
                Text('Mié\n20°C\n🌧️', textAlign: TextAlign.center),
                Text('Jue\n25°C\n☁️', textAlign: TextAlign.center),
                Text('Vie\n28°C\n☀️', textAlign: TextAlign.center),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}