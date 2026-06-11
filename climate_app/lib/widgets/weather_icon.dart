import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;

  const WeatherIcon({Key? key, required this.condition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      condition == 'sunny' ? Icons.sunny : Icons.cloud,
      size: 120,
      color: Colors.blue,
    );
  }
}