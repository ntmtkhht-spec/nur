import 'package:flutter_riverpod/flutter_riverpod.dart';


class WeatherData {
  final double temperature;
  final String condition;
  final String icon;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.icon,
  });
}

final weatherProvider = FutureProvider<WeatherData>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));
  
  // Here you would normally call OpenWeatherMap API using location.
  // final location = await ref.watch(locationProvider.future);
  
  return const WeatherData(
    temperature: 22.5,
    condition: 'Klarer Himmel',
    icon: '☀️',
  );
});
