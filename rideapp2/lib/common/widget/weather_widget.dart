import 'package:flutter/material.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/model/weather_model.dart';
import 'package:ridesharing/common/services/weatherr_service.dart';
import 'package:ridesharing/common/theme.dart';

class WeatherWidget extends StatefulWidget {
  final String defaultCity;
  
  const WeatherWidget({super.key, this.defaultCity = 'Tunisie'});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final weather = await _weatherService.getWeatherByCity(widget.defaultCity);
      setState(() {
        _weatherData = weather;
      });
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger la météo';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildWeatherContent() {
    if (_isLoading) {
      return _buildLoading();
    }
    
    if (_error.isNotEmpty) {
      return _buildError();
    }
    
    if (_weatherData == null) {
      return _buildEmpty();
    }
    
    return _buildWeatherCard();
  }

  Widget _buildLoading() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Chargement de la météo...'),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Météo indisponible',
                    style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _error,
                    style: PoppinsTextStyles.bodySmallRegular.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadWeather,
              icon: const Icon(Icons.refresh),
              color: CustomTheme.appColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Text(
              'Météo non disponible',
              style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    final weather = _weatherData!;
    final emoji = _weatherService.getWeatherEmoji(weather.condition);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec ville et actualisation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: CustomTheme.appColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${weather.city}, ${weather.country}',
                      style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _loadWeather,
                  child: Row(
                    children: [
                      Text(
                        weather.lastUpdatedFormatted,
                        style: PoppinsTextStyles.bodySmallRegular.copyWith(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.refresh,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Informations météo principales
            Row(
              children: [
                // Icône et température
                Column(
                  children: [
                    // Vous pouvez utiliser l'image de WeatherAPI ou l'emoji
                    // Image.network(
                    //   weather.iconUrl,
                    //   width: 60,
                    //   height: 60,
                    // ),
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.formattedTemperature,
                      style: PoppinsTextStyles.titleMediumRegular.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Détails
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.description.toUpperCase(),
                        style: PoppinsTextStyles.bodySmallRegular.copyWith(
                          fontWeight: FontWeight.w600,
                          color: CustomTheme.appColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildWeatherDetail('🌡️', weather.formattedFeelsLike),
                      _buildWeatherDetail('💧', 'Humidité ${weather.formattedHumidity}'),
                      _buildWeatherDetail('💨', 'Vent ${weather.formattedWindSpeed}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: PoppinsTextStyles.bodySmallRegular.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildWeatherContent();
  }
}