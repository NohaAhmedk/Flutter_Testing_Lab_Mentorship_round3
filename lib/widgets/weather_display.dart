import 'dart:async';
import 'package:flutter/material.dart';

class WeatherDisplay extends StatefulWidget {
  const WeatherDisplay({super.key});

  @override
  State<WeatherDisplay> createState() => WeatherDisplayState();
}

class WeatherDisplayState extends State<WeatherDisplay> {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  bool _useFahrenheit = false;
  String _selectedCity = 'New York';

  final List<String> _cities = ['New York', 'London', 'Tokyo', 'Invalid City'];

  bool _disposed = false;

  double celsiusToFahrenheit(double celsius) => (celsius * 9 / 5) + 32;
  double fahrenheitToCelsius(double fahrenheit) => (fahrenheit - 32) * 5 / 9;

  Future<Map<String, dynamic>?> _fetchWeatherData(String city) async {
    await Future.delayed(const Duration(seconds: 2));

    if (_disposed) return null;

    if (city == 'Invalid City') {
      return null;
    }

    if (DateTime.now().millisecond % 4 == 0) {
      return {'city': city, 'temperature': 22.5};
    }

    return {
      'city': city,
      'temperature': city == 'London' ? 15.0 : (city == 'Tokyo' ? 25.0 : 22.5),
      'description': city == 'London'
          ? 'Rainy'
          : (city == 'Tokyo' ? 'Cloudy' : 'Sunny'),
      'humidity': city == 'London' ? 85 : (city == 'Tokyo' ? 70 : 65),
      'windSpeed': city == 'London' ? 8.5 : (city == 'Tokyo' ? 5.2 : 12.3),
      'icon': city == 'London' ? '🌧️' : (city == 'Tokyo' ? '☁️' : '☀️'),
    };
  }

  Future<void> _loadWeather() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
        _weatherData = null;
      });
    }

    try {
      final data = await _fetchWeatherData(_selectedCity);
      if (_disposed) return;

      if (data == null || !data.containsKey('temperature')) {
        throw Exception('Invalid or incomplete data');
      }

      final weather = WeatherData.fromJson(data);

      if (mounted) {
        setState(() {
          _weatherData = weather;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load weather data. Please try again.';
          _isLoading = false;
          _weatherData = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('City: '),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCity,
                  isExpanded: true,
                  items: _cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCity = value;
                      });
                      _loadWeather();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loadWeather,
                child: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Temperature Unit:'),
              const SizedBox(width: 10),
              Switch(
                value: _useFahrenheit,
                onChanged: (value) {
                  setState(() {
                    _useFahrenheit = value;
                  });
                },
              ),
              Text(_useFahrenheit ? 'Fahrenheit' : 'Celsius'),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          else if (_weatherData != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_weatherData!.icon, style: const TextStyle(fontSize: 48)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _weatherData!.city,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _weatherData!.description,
                                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _useFahrenheit
                              ? '${celsiusToFahrenheit(_weatherData!.temperatureCelsius).toStringAsFixed(1)}°F'
                              : '${_weatherData!.temperatureCelsius.toStringAsFixed(1)}°C',
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildWeatherDetail('Humidity', '${_weatherData!.humidity}%', Icons.water_drop),
                          _buildWeatherDetail('Wind Speed', '${_weatherData!.windSpeed} km/h', Icons.air),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              const Center(child: Text('No weather data available.')),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class WeatherData {
  final String city;
  final double temperatureCelsius;
  final String description;
  final int humidity;
  final double windSpeed;
  final String icon;

  WeatherData({
    required this.city,
    required this.temperatureCelsius,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw Exception('Weather data is null');
    return WeatherData(
      city: json['city'] ?? 'Unknown',
      temperatureCelsius: (json['temperature'] ?? 0).toDouble(),
      description: json['description'] ?? 'N/A',
      humidity: (json['humidity'] ?? 0).toInt(),
      windSpeed: (json['windSpeed'] ?? 0).toDouble(),
      icon: json['icon'] ?? '',
    );
  }
}
