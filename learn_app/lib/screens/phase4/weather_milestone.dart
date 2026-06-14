/// Phase 4 Milestone: Live Weather App
///
/// Uses Open-Meteo API (free, no API key required).
/// Features: geolocation search, current weather, 7-day forecast,
///           offline caching, loading/error/empty states.
///
/// APIs used:
///   - Geocoding:  https://geocoding-api.open-meteo.com/v1/search
///   - Weather:    https://api.open-meteo.com/v1/forecast

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherMilestone extends StatelessWidget {
  const WeatherMilestone({super.key});

  @override
  Widget build(BuildContext context) {
    return const WeatherApp();
  }
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  // --- State ---
  final _searchCtrl = TextEditingController();
  List<_CityResult>? _searchResults;
  _WeatherData? _weather;
  bool _loadingWeather = false;
  bool _searching = false;
  String? _error;
  bool _isCached = false;
  bool _showSearch = false;

  // Default city
  String _selectedCity = 'London';
  double _selectedLat = 51.51;
  double _selectedLon = -0.13;

  @override
  void initState() {
    super.initState();
    _loadLastCity();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // --- Load last viewed city from cache ---
  Future<void> _loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('last_city');
    final lat = prefs.getDouble('last_lat');
    final lon = prefs.getDouble('last_lon');

    if (cached != null && lat != null && lon != null) {
      _selectedCity = cached;
      _selectedLat = lat;
      _selectedLon = lon;
    }

    // Load cached weather
    final weatherJson = prefs.getString('cached_weather');
    if (weatherJson != null) {
      try {
        _weather = _WeatherData.fromJson(jsonDecode(weatherJson));
        _isCached = true;
      } catch (_) {}
    }

    // Fetch fresh weather
    _fetchWeather();
  }

  // --- Search cities ---
  Future<void> _searchCities(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = null);
      return;
    }

    setState(() => _searching = true);

    try {
      final response = await http.get(
        Uri.parse(
            'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=en&format=json'),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>?;

      setState(() {
        _searchResults = results
                ?.map((j) => _CityResult.fromJson(j))
                .toList() ??
            [];
      });
    } catch (e) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _searching = false);
    }
  }

  // --- Fetch weather for a city ---
  Future<void> _fetchWeather() async {
    setState(() {
      _loadingWeather = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?'
          'latitude=${_selectedLat.toStringAsFixed(2)}'
          '&longitude=${_selectedLon.toStringAsFixed(2)}'
          '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
          'weather_code,wind_speed_10m'
          '&daily=temperature_2m_max,temperature_2m_min,weather_code'
          '&timezone=auto&forecast_days=7',
        ),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final weather = _WeatherData.fromJson(data);

      // Cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_weather', response.body);
      await prefs.setString('last_city', _selectedCity);
      await prefs.setDouble('last_lat', _selectedLat);
      await prefs.setDouble('last_lon', _selectedLon);

      setState(() {
        _weather = weather;
        _isCached = false;
        _loadingWeather = false;
        _showSearch = false;
      });
    } catch (e) {
      if (_weather == null) {
        setState(() {
          _error = e.toString();
          _loadingWeather = false;
        });
      } else {
        // Have cached data — silently show it
        setState(() {
          _isCached = true;
          _loadingWeather = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Showing cached data (offline)')),
          );
        }
      }
    }
  }

  void _selectCity(_CityResult city) {
    setState(() {
      _selectedCity = '${city.name}, ${city.country}';
      _selectedLat = city.lat;
      _selectedLon = city.lon;
      _searchResults = null;
      _searchCtrl.clear();
    });
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showSearch ? 'Search City' : _selectedCity),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () =>
                setState(() => _showSearch = !_showSearch),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeather,
          ),
        ],
      ),
      body: _showSearch ? _buildSearch() : _buildWeather(),
    );
  }

  // --- Search UI ---
  Widget _buildSearch() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search city...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
            onChanged: _searchCities,
          ),
        ),
        Expanded(
          child: _searchResults == null
              ? const Center(
                  child: Text('Type to search for a city',
                      style: TextStyle(color: Colors.grey)))
              : _searchResults!.isEmpty
                  ? const Center(child: Text('No cities found'))
                  : ListView.builder(
                      itemCount: _searchResults!.length,
                      itemBuilder: (context, index) {
                        final city = _searchResults![index];
                        return ListTile(
                          leading: const Icon(Icons.location_city),
                          title: Text('${city.name}'),
                          subtitle: Text(
                              '${city.admin1 ?? ""}, ${city.country}'),
                          trailing: Text(
                              '${city.lat.toStringAsFixed(1)}, ${city.lon.toStringAsFixed(1)}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          onTap: () => _selectCity(city),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // --- Weather Display ---
  Widget _buildWeather() {
    if (_loadingWeather && _weather == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching weather...'),
          ],
        ),
      );
    }

    if (_error != null && _weather == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Error: $_error',
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _fetchWeather,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_weather == null) {
      return const Center(child: Text('Search for a city to see weather'));
    }

    // --- Cache banner ---
    return RefreshIndicator(
      onRefresh: _fetchWeather,
      child: ListView(
        children: [
          if (_isCached)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.orange.withValues(alpha: 0.15),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storage, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Cached data — pull to refresh',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),

          // Current weather card
          _CurrentWeatherCard(weather: _weather!),

          // 7-day forecast
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('7-Day Forecast',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary)),
          ),
          ..._weather!.daily.asMap().entries.map(
                (entry) => _ForecastDay(
                  day: entry.value,
                  isToday: entry.key == 0,
                ),
              ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ============================================================
// CURRENT WEATHER CARD
// ============================================================

class _CurrentWeatherCard extends StatelessWidget {
  final _WeatherData weather;
  const _CurrentWeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final temp = current.temp.toStringAsFixed(0);
    final feelsLike = current.feelsLike.toStringAsFixed(0);
    final icon = _weatherIcon(current.weatherCode);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 72, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              '$temp°C',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Feels like $feelsLike°C',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _WeatherInfo(
                    Icons.water_drop, '${current.humidity}%', 'Humidity'),
                _WeatherInfo(Icons.air, '${current.windSpeed} km/h', 'Wind'),
                _WeatherInfo(
                    Icons.thermostat,
                    '${weather.daily[0].max.toStringAsFixed(0)}°',
                    'High'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code <= 48) return Icons.foggy;
    if (code <= 57) return Icons.grain;
    if (code <= 67) return Icons.water;
    if (code <= 77) return Icons.ac_unit;
    if (code <= 82) return Icons.umbrella;
    return Icons.thunderstorm;
  }
}

class _WeatherInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherInfo(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }
}

// ============================================================
// FORECAST DAY
// ============================================================

class _ForecastDay extends StatelessWidget {
  final _DailyForecast day;
  final bool isToday;

  const _ForecastDay({required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final dateStr = isToday
        ? 'Today'
        : '${day.date.month}/${day.date.day}';
    final icon = _iconForCode(day.weatherCode);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      color: isToday
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.teal),
        title: Text(dateStr,
            style: TextStyle(fontWeight: isToday ? FontWeight.bold : null)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${day.min.toStringAsFixed(0)}°',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 8),
            Container(
              width: 80,
              height: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.3,
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  color: Colors.teal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${day.max.toStringAsFixed(0)}°',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  IconData _iconForCode(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code <= 48) return Icons.foggy;
    if (code <= 67) return Icons.water;
    if (code <= 82) return Icons.umbrella;
    return Icons.thunderstorm;
  }
}

// ============================================================
// DATA MODELS
// ============================================================

class _CityResult {
  final String name;
  final String? admin1;
  final String country;
  final double lat;
  final double lon;

  _CityResult({
    required this.name,
    this.admin1,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory _CityResult.fromJson(Map<String, dynamic> j) {
    return _CityResult(
      name: j['name'] ?? '',
      admin1: j['admin1']?.toString(),
      country: j['country'] ?? '',
      lat: (j['latitude'] as num?)?.toDouble() ?? 0.0,
      lon: (j['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class _WeatherData {
  final _CurrentWeather current;
  final List<_DailyForecast> daily;

  _WeatherData({required this.current, required this.daily});

  factory _WeatherData.fromJson(Map<String, dynamic> j) {
    final current = j['current'] as Map<String, dynamic>? ?? {};
    final daily = j['daily'] as Map<String, dynamic>? ?? {};

    final timeStrs = (daily['time'] as List<dynamic>? ?? []).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List<dynamic>? ?? [])
        .map((e) => (e as num).toDouble())
        .toList();
    final minTemps = (daily['temperature_2m_min'] as List<dynamic>? ?? [])
        .map((e) => (e as num).toDouble())
        .toList();
    final codes = (daily['weather_code'] as List<dynamic>? ?? [])
        .map((e) => e as int)
        .toList();

    return _WeatherData(
      current: _CurrentWeather(
        temp: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
        feelsLike:
            (current['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
        humidity:
            (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
        windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
        weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      ),
      daily: List.generate(
        timeStrs.length,
        (i) => _DailyForecast(
          date: DateTime.tryParse(timeStrs[i]) ?? DateTime.now(),
          max: i < maxTemps.length ? maxTemps[i] : 0.0,
          min: i < minTemps.length ? minTemps[i] : 0.0,
          weatherCode: i < codes.length ? codes[i] : 0,
        ),
      ),
    );
  }
}

class _CurrentWeather {
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;

  _CurrentWeather({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
  });
}

class _DailyForecast {
  final DateTime date;
  final double max;
  final double min;
  final int weatherCode;

  _DailyForecast({
    required this.date,
    required this.max,
    required this.min,
    required this.weatherCode,
  });
}
