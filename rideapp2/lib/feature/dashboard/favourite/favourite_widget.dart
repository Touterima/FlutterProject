// widgets/events_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/constant/assets.dart';
import 'package:ridesharing/common/constant/sdg_constants.dart';
import 'package:ridesharing/common/database/database_helper.dart';
import 'package:ridesharing/common/model/event_model.dart';
import 'package:ridesharing/common/model/weather_model.dart';
import 'package:ridesharing/common/services/auth_service.dart';
import 'package:ridesharing/common/services/weatherr_service.dart'; // Correction du nom
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/validation/event_validator.dart'; // Nouveau fichier
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/feature/dashboard/favourite/event_form_bottom_sheet.dart';

class EventsWidget extends StatefulWidget {
  const EventsWidget({super.key});

  @override
  State<EventsWidget> createState() => _EventsWidgetState();
}

class _EventsWidgetState extends State<EventsWidget> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  final WeatherService _weatherService = WeatherService();
  List<Event> _events = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _currentUserId = AuthService.currentUserId;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    final events = await _databaseHelper.getAllEventsWithLikes(_currentUserId);
    setState(() {
      _events = events;
      _isLoading = false;
    });
    
    // Charger la météo pour tous les événements
    _loadWeatherForEvents();
  }

  Future<void> _loadWeatherForEvents() async {
    for (var i = 0; i < _events.length; i++) {
      // Attendre un peu entre chaque appel pour éviter de surcharger l'API
      if (i > 0) await Future.delayed(const Duration(milliseconds: 200));
      _loadWeatherForEvent(_events[i]);
    }
  }

  Future<void> _loadWeatherForEvent(Event event) async {
    final eventIndex = _events.indexWhere((e) => e.id == event.id);
    if (eventIndex == -1) return;

    // Mettre à jour l'état pour indiquer le chargement
    setState(() {
      _events[eventIndex] = event.copyWith(
        isWeatherLoading: true,
        weatherError: null,
      );
    });

    try {
      final weather = await _weatherService.getWeatherByCity(event.location);
      
      setState(() {
        _events[eventIndex] = event.copyWith(
          weather: weather,
          isWeatherLoading: false,
          weatherError: null,
        );
      });
    } catch (e) {
      setState(() {
        _events[eventIndex] = event.copyWith(
          isWeatherLoading: false,
          weatherError: 'Weather unavailable',
        );
      });
    }
  }

  // Méthode pour recharger la météo d'un événement spécifique
  Future<void> _refreshWeatherForEvent(int eventId) async {
    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      await _loadWeatherForEvent(_events[eventIndex]);
    }
  }

  void _showEventForm({Event? event}) {
    if (_currentUserId == null) {
      _showLoginRequiredDialog();
      return;
    }

    if (event != null && !event.isOwner(_currentUserId!)) {
      _showUnauthorizedDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EventFormBottomSheet(
        event: event,
        currentUserId: _currentUserId!,
        onEventSaved: _loadEvents,
      ),
    );
  }

  void _toggleEventLike(Event event) async {
    if (_currentUserId == null) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      Event updatedEvent;
      
      if (event.isLiked) {
        await _databaseHelper.unlikeEvent(event.id!, _currentUserId!);
        updatedEvent = event.copyWith(
          likeCount: event.likeCount - 1,
          isLiked: false,
        );
      } else {
        await _databaseHelper.likeEvent(event.id!, _currentUserId!);
        updatedEvent = event.copyWith(
          likeCount: event.likeCount + 1,
          isLiked: true,
        );
      }

      // Mettre à jour la liste des événements
      setState(() {
        final index = _events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          _events[index] = updatedEvent;
        }
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _deleteEvent(int id, int eventUserId) async {
    if (_currentUserId == null || eventUserId != _currentUserId) {
      _showUnauthorizedDialog();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseHelper.deleteEvent(id, _currentUserId!);
        _loadEvents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting event')),
        );
      }
    }
  }

  void _showUnauthorizedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unauthorized'),
        content: const Text('You can only modify events that you created.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to be logged in to create events.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Méthode pour formater la date
  String _formatDate(String? dateString) {
    if (dateString == null) return "Unknown date";
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  // Méthode pour construire une ligne d'information
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isHighlighted ? CustomTheme.appColor : Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: PoppinsTextStyles.bodyMediumRegular.copyWith(
              fontSize: 13,
              color: isHighlighted ? CustomTheme.appColor : Colors.grey[700],
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Méthode pour construire les icônes SDG
  Widget _buildSdgIconsSection(List<String> oddObjectives) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SDG Objectives",
          style: PoppinsTextStyles.bodySmallRegular.copyWith(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: oddObjectives.take(6).map((sdg) {
            return Tooltip(
              message: sdg,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SdgConstants.getColorForSdg(sdg).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SdgConstants.getColorForSdg(sdg).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  SdgConstants.getIconForSdg(sdg),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            );
          }).toList(),
        ),
        if (oddObjectives.length > 6) ...[
          const SizedBox(height: 4),
          Text(
            "+${oddObjectives.length - 6} more SDGs",
            style: PoppinsTextStyles.bodySmallRegular.copyWith(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  // Widget pour construire la météo de l'événement
  Widget _buildEventWeather(Event event, StateSetter setState) {
    if (event.isWeatherLoading) {
      return _buildWeatherLoading();
    }
    
    if (event.weatherError != null) {
      return _buildWeatherError(event, setState);
    }
    
    if (event.weather != null) {
      return _buildWeatherMiniCard(event.weather!, event, setState);
    }
    
    return _buildWeatherEmpty();
  }

  Widget _buildWeatherLoading() {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text(
          'Loading weather...',
          style: PoppinsTextStyles.bodySmallRegular.copyWith(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherError(Event event, StateSetter setState) {
    return Row(
      children: [
        Icon(Icons.cloud_off, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Weather unavailable',
            style: PoppinsTextStyles.bodySmallRegular.copyWith(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _refreshWeatherForEvent(event.id!),
          child: Icon(Icons.refresh, size: 14, color: CustomTheme.appColor),
        ),
      ],
    );
  }

  Widget _buildWeatherEmpty() {
    return Row(
      children: [
        Icon(Icons.cloud_off, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Text(
          'Weather not available',
          style: PoppinsTextStyles.bodySmallRegular.copyWith(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherMiniCard(WeatherData weather, Event event, StateSetter setState) {
    final emoji = _weatherService.getWeatherEmoji(weather.condition);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji météo
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          
          // Température
          Text(
            weather.formattedTemperature,
            style: PoppinsTextStyles.bodySmallRegular.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          
          const SizedBox(width: 4),
          
          // Description
          Expanded(
            child: Text(
              weather.description,
              style: PoppinsTextStyles.bodySmallRegular.copyWith(
                color: Colors.grey[700],
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(width: 4),
          
          // Bouton rafraîchir
          GestureDetector(
            onTap: () => _refreshWeatherForEvent(event.id!),
            child: Icon(
              Icons.refresh,
              size: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour construire la section météo étendue
  Widget _buildExpandedWeatherSection(WeatherData weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current Weather",
          style: PoppinsTextStyles.bodyMediumRegular.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomTheme.darkColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Icône et température principale
              Column(
                children: [
                  Text(
                    _weatherService.getWeatherEmoji(weather.condition),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.formattedTemperature,
                    style: PoppinsTextStyles.titleMediumRegular.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Détails météo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.description,
                      style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildWeatherDetailRow('🌡️', 'Feels like ${weather.feelsLike.round()}°C'),
                    _buildWeatherDetailRow('💧', 'Humidity ${weather.humidity}%'),
                    _buildWeatherDetailRow('💨', 'Wind ${weather.windSpeed.round()} km/h'),
                    _buildWeatherDetailRow('📍', '${weather.city}, ${weather.country}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetailRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
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

  // Widget pour construire une carte d'événement individuelle
  Widget _buildEventCard(Event event) {
    final isOwner = _currentUserId != null && event.isOwner(_currentUserId!);
    bool isExpanded = false;
    bool showActions = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec fond coloré
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CustomTheme.appColor.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre avec actions
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: PoppinsTextStyles.titleMediumRegular.copyWith(
                                fontWeight: FontWeight.w700,
                                color: CustomTheme.darkColor,
                                fontSize: 18,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Bouton like
                          IconButton(
                            onPressed: () => _toggleEventLike(event),
                            icon: Icon(
                              event.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: event.isLiked ? Colors.red : Colors.grey,
                            ),
                          ),
                          // Actions du propriétaire
                          if (isOwner) ...[
                            if (!showActions && !isExpanded)
                              IconButton(
                                onPressed: () => setState(() => showActions = true),
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                tooltip: "Actions",
                              ),
                            if (showActions || isExpanded) ...[
                              IconButton(
                                onPressed: () {
                                  setState(() => showActions = false);
                                  _showEventForm(event: event);
                                },
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: CustomTheme.appColor,
                                  size: 20,
                                ),
                                tooltip: "Edit",
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() => showActions = false);
                                  _deleteEvent(event.id!, event.userId);
                                },
                                icon: Icon(
                                  Icons.delete_outlined,
                                  color: CustomTheme.googleColor,
                                  size: 20,
                                ),
                                tooltip: "Delete",
                              ),
                              if (!isExpanded)
                                IconButton(
                                  onPressed: () => setState(() => showActions = false),
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey[600],
                                    size: 18,
                                  ),
                                  tooltip: "Close",
                                ),
                            ],
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                "Your Event",
                                style: PoppinsTextStyles.bodySmallRegular.copyWith(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Informations de base
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        text: event.location,
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: event.date,
                        isHighlighted: true,
                      ),

                      // Widget météo
                      const SizedBox(height: 8),
                      _buildEventWeather(event, setState),

                      // Compteur de likes
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${event.likeCount} likes",
                            style: PoppinsTextStyles.bodySmallRegular.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      // Icônes SDG
                      if (event.oddObjectives.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildSdgIconsSection(event.oddObjectives),
                      ],
                    ],
                  ),
                ),

                // Contenu principal
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        event.description,
                        style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: isExpanded ? 10 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Métadonnées et bouton expand
                      Row(
                        children: [
                          // Métadonnées
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Created on ${_formatDate(event.creationAt)}",
                                  style: PoppinsTextStyles.bodySmallRegular.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "ID: #${event.id}",
                                  style: PoppinsTextStyles.bodySmallRegular.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bouton expand
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                                if (isExpanded) {
                                  showActions = false;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isExpanded ? "Less" : "More",
                                    style: PoppinsTextStyles.bodySmallRegular.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    isExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Contenu étendu
                      if (isExpanded) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Section météo détaillée
                        if (event.weather != null) ...[
                          _buildExpandedWeatherSection(event.weather!),
                          const SizedBox(height: 16),
                        ],

                        // Section SDG détaillée
                        if (event.oddObjectives.isNotEmpty) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sustainable Development Goals",
                                style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: CustomTheme.darkColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: event.oddObjectives.map((sdg) {
                                  return Container(
                                    width: (MediaQuery.of(context).size.width - 100) / 2,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: SdgConstants.getColorForSdg(sdg).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: SdgConstants.getColorForSdg(sdg).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: SdgConstants.getColorForSdg(sdg),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            SdgConstants.getIconForSdg(sdg),
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            sdg,
                                            style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                                              fontSize: 13,
                                              color: SdgConstants.getColorForSdg(sdg),
                                              fontWeight: FontWeight.w600,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Description complète
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Full Description",
                              style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                                fontWeight: FontWeight.w600,
                                color: CustomTheme.darkColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.description,
                              style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),

                        // Actions étendues pour le propriétaire
                        if (isOwner) ...[
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Event Actions",
                                style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: CustomTheme.darkColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () => _showEventForm(event: event),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text("Edit Event"),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: CustomTheme.appColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton.icon(
                                    onPressed: () => _deleteEvent(event.id!, event.userId),
                                    icon: const Icon(Icons.delete, size: 16),
                                    label: const Text("Delete Event"),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: CustomTheme.googleColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      appBarTitle: "Events",
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildEventContent(),
    );
  }

  Widget _buildEventContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton Add Event - Seulement si l'utilisateur est connecté
          if (_currentUserId != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Events",
                    style: PoppinsTextStyles.titleMediumRegular.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showEventForm(),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Event'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.appColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Login to create your own events",
                      style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Liste des événements
          _events.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: _events.map((event) => _buildEventCard(event)).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 80,
            color: CustomTheme.appColor.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            "No Events Yet",
            style: PoppinsTextStyles.titleMediumRegular.copyWith(
              color: CustomTheme.darkColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Start by creating your first event! Tap the 'Add Event' button above to get started.",
            style: PoppinsTextStyles.bodyMediumRegular.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _currentUserId != null ? () => _showEventForm() : null,
            icon: const Icon(Icons.add),
            label: const Text('Create Your First Event'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.appColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}