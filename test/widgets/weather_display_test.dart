import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/weather_display.dart';

void main() {
  group('Unit Tests - Weather Data Processing', () {
    test('Celsius to Fahrenheit conversion should be correct', () {
      final widgetState = WeatherDisplayState();
      expect(widgetState.celsiusToFahrenheit(0), 32);
      expect(widgetState.celsiusToFahrenheit(100), 212);
      expect(widgetState.celsiusToFahrenheit(-40), -40);
    });

    test('Fahrenheit to Celsius conversion should be correct', () {
      final widgetState = WeatherDisplayState();
      expect(widgetState.fahrenheitToCelsius(32).round(), 0);
      expect(widgetState.fahrenheitToCelsius(212).round(), 100);
      expect(widgetState.fahrenheitToCelsius(-40).round(), -40);
    });

    test('WeatherData.fromJson handles missing fields safely', () {
      final json = {'city': 'Test City', 'temperature': 20.0};
      final data = WeatherData.fromJson(json);

      expect(data.city, 'Test City');
      expect(data.temperatureCelsius, 20.0);
      expect(data.description, 'N/A'); // default
      expect(data.humidity, 0); // default
      expect(data.windSpeed, 0); // default
      expect(data.icon, ''); // default
    });

    test('WeatherData.fromJson throws exception on null', () {
      expect(() => WeatherData.fromJson(null), throwsException);
    });
  });

  group('Widget Tests - WeatherDisplay UI', () {
    testWidgets('Displays loading indicator initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

    });

    testWidgets('Switch toggles between Celsius and Fahrenheit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 3)); // simulate loading complete

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('°F'), findsOneWidget);
    });

    testWidgets('Shows error message when API fails', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invalid City').last);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final errorText = find.textContaining('Failed to load weather data');
      expect(errorText, findsOneWidget);
    });
  });
}
