class WeatherUtils {
  // Convierte Celsius a Fahrenheit
  static double celsiusToFahrenheit(int celsius) {
    return (celsius * 9 / 5) + 32;
  }

  // Convierte Fahrenheit a Celsius
  static int fahrenheitToCelsius(double fahrenheit) {
    return ((fahrenheit - 32) * 5 / 9).toInt();
  }
}