// lib/feature/dashboard/trips/trip_map_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';

class TripMapWidget extends StatefulWidget {
  final Map<String, dynamic> routeData;
  final String fromCity;
  final String toCity;

  const TripMapWidget({
    super.key,
    required this.routeData,
    required this.fromCity,
    required this.toCity,
  });

  @override
  State<TripMapWidget> createState() => _TripMapWidgetState();
}

class _TripMapWidgetState extends State<TripMapWidget> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  List<LatLng> _getRoutePoints() {
    final geometry = widget.routeData['geometry'] as List;
    return geometry
        .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
        .toList();
  }

  LatLng _getFromCoords() {
    final coords = widget.routeData['from_coords'] as Map<String, double>;
    return LatLng(coords['latitude']!, coords['longitude']!);
  }

  LatLng _getToCoords() {
    final coords = widget.routeData['to_coords'] as Map<String, double>;
    return LatLng(coords['latitude']!, coords['longitude']!);
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _getRoutePoints();
    final fromCoords = _getFromCoords();
    final toCoords = _getToCoords();

    return CommonContainer(
      appBarTitle: "Carte du trajet",
      showBackBotton: true,
      body: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 16.hp),

          // ✅ Carte avec affichage correct
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  (fromCoords.latitude + toCoords.latitude) / 2,
                  (fromCoords.longitude + toCoords.longitude) / 2,
                ),
                initialZoom: 7.5,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.rideapp',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5.0,
                      color: CustomTheme.appColor,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: fromCoords,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.flag, color: Colors.green, size: 32),
                    ),
                    Marker(
                      point: toCoords,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on,
                          color: Colors.red, size: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.hp),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.appColor, CustomTheme.appColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.fromCity,
              style: PoppinsTextStyles.titleMediumRegular
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const Icon(Icons.arrow_forward, color: Colors.white),
          Text(widget.toCity,
              style: PoppinsTextStyles.titleMediumRegular
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}










/*
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';

class TripMapWidget extends StatefulWidget {
  final Map<String, dynamic> routeData;
  final String fromCity;
  final String toCity;

  const TripMapWidget({
    super.key,
    required this.routeData,
    required this.fromCity,
    required this.toCity,
  });

  @override
  State<TripMapWidget> createState() => _TripMapWidgetState();
}

class _TripMapWidgetState extends State<TripMapWidget> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  List<LatLng> _getRoutePoints() {
    final geometry = widget.routeData['geometry'] as List;
    return geometry.map((coord) {
      return LatLng(coord[1] as double, coord[0] as double);
    }).toList();
  }

  LatLng _getFromCoords() {
    final coords = widget.routeData['from_coords'] as Map<String, double>;
    return LatLng(coords['latitude']!, coords['longitude']!);
  }

  LatLng _getToCoords() {
    final coords = widget.routeData['to_coords'] as Map<String, double>;
    return LatLng(coords['latitude']!, coords['longitude']!);
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _getRoutePoints();
    final fromCoords = _getFromCoords();
    final toCoords = _getToCoords();

    return CommonContainer(
      appBarTitle: "Carte du trajet",
      showBackBotton: true,
      body: Column(
        children: [
          // Informations du trajet
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomTheme.appColor,
                  CustomTheme.appColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fromCity,
                            style: PoppinsTextStyles.titleMediumRegular.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Départ",
                            style: PoppinsTextStyles.bodySmallRegular.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.toCity,
                            style: PoppinsTextStyles.titleMediumRegular.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Arrivée",
                            style: PoppinsTextStyles.bodySmallRegular.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.hp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoChip(
                      Icons.straighten,
                      widget.routeData['distance_text'],
                      "Distance",
                    ),
                    _buildInfoChip(
                      Icons.access_time,
                      widget.routeData['duration_text'],
                      "Durée estimée",
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.hp),

          // Carte
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CustomTheme.appColor, width: 2),
              ),
              clipBehavior: Clip.hardEdge,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: fromCoords,
                  initialZoom: 8.0,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                ),
                children: [
                  // Tuiles OpenStreetMap
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.rideapp',
                    maxZoom: 19,
                  ),
                  
                  // Ligne de l'itinéraire
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4.0,
                        color: CustomTheme.appColor,
                        borderColor: Colors.white,
                        borderStrokeWidth: 2.0,
                      ),
                    ],
                  ),
                  
                  // Marqueurs de départ et d'arrivée
                  MarkerLayer(
                    markers: [
                      // Marqueur de départ
                      Marker(
                        point: fromCoords,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: CustomTheme.appColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                      // Marqueur d'arrivée
                      Marker(
                        point: toCoords,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: CustomTheme.googleColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.hp),

          // Boutons de contrôle
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  Icons.zoom_in,
                  "Zoomer",
                  () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      zoom + 1,
                    );
                  },
                ),
              ),
              SizedBox(width: 8.wp),
              Expanded(
                child: _buildControlButton(
                  Icons.zoom_out,
                  "Dézoomer",
                  () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      zoom - 1,
                    );
                  },
                ),
              ),
              SizedBox(width: 8.wp),
              Expanded(
                child: _buildControlButton(
                  Icons.my_location,
                  "Centrer",
                  () {
                    // Calculer le centre entre les deux points
                    final centerLat = (fromCoords.latitude + toCoords.latitude) / 2;
                    final centerLng = (fromCoords.longitude + toCoords.longitude) / 2;
                    
                    _mapController.move(
                      LatLng(centerLat, centerLng),
                      8.0,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(width: 8.wp),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: PoppinsTextStyles.labelMediumRegular.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: PoppinsTextStyles.bodySmallRegular.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomTheme.appColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          SizedBox(height: 4.hp),
          Text(
            label,
            style: PoppinsTextStyles.bodySmallRegular.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
*/