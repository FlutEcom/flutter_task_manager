import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String? _weatherInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        throw Exception('Brak uprawnień do lokalizacji.');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);

      // Klucz API z WeatherAPI.com (należy go podmienić)
      const apiKey = 'dc0456da006f4e1a80d141315251709'; 
      if (apiKey == 'YOUR_API_KEY' || apiKey.isEmpty) {
        throw Exception('Wpisz swój klucz API w kodzie');
      }

      final url = Uri.parse(
          'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=${position.latitude},${position.longitude}&aqi=no&lang=pl');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final temp = data['current']['temp_c'];
        final condition = data['current']['condition']['text'];
        final location = data['location']['name'];
        setState(() {
          _weatherInfo = '$location: $temp°C, $condition';
        });
      } else {
        throw Exception('Nie udało się pobrać danych pogodowych.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Usługi lokalizacji są wyłączone. Włącz je w ustawieniach.')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Brak uprawnień do lokalizacji.')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Uprawnienia do lokalizacji są zablokowane na stałe.')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: Center(child: LinearProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.amber[600], size: 16),
            const SizedBox(width: 8),
            Expanded(
                child: Text('Pogoda: $_errorMessage',
                    style: TextStyle(color: Colors.amber[600]))),
          ],
        ),
      );
    }

    if (_weatherInfo != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wb_sunny_outlined, color: Colors.grey[400], size: 16),
            const SizedBox(width: 8),
            Text(_weatherInfo!, style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
