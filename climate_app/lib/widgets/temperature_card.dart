import 'package:flutter/material.dart';

class TemperatureCard extends StatelessWidget {
  final String day;
  final String temp;

  const TemperatureCard({Key? key, required this.day, required this.temp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(temp),
          ],
        ),
      ),
    );
  }
}