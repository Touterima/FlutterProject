//lib/feature/dashboard/trips/trips_list_widget.dart
// lib/feature/dashboard/trips/trips_list_widget.dart
//lib/feature/dashboard/trips/trips_list_widget.dart
import 'package:flutter/material.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/constant/assets.dart';
import 'package:ridesharing/common/model/trip_model.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/common/widget/custom_text_field.dart';
import 'package:ridesharing/feature/dashboard/trips/service/trip_service.dart';
import 'package:ridesharing/feature/dashboard/trips/add_trip_widget.dart';
import 'package:ridesharing/feature/dashboard/trips/trip_detail_widget.dart';
import 'package:ridesharing/feature/dashboard/trips/my_booked_trips_widget.dart';

import 'package:intl/intl.dart';

class TripsListWidget extends StatefulWidget {
  const TripsListWidget({super.key});

  @override
  State<TripsListWidget> createState() => _TripsListWidgetState();
}

class _TripsListWidgetState extends State<TripsListWidget> {
  final TripService _tripService = TripService();
  List<TripModel> _allTrips = [];
  List<TripModel> _filteredTrips = [];
  bool _isLoading = true;
  
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    await _tripService.initializeSampleData();
    final trips = await _tripService.getAllTrips();
    setState(() {
      _allTrips = trips;
      _filteredTrips = trips;
      _isLoading = false;
    });
  }

  Future<void> _searchTrips() async {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    if (from.isEmpty && to.isEmpty) {
      setState(() { _filteredTrips = _allTrips; });
      return;
    }
    setState(() => _isLoading = true);
    final results = await _tripService.searchTrips(from, to);
    setState(() {
      _filteredTrips = results;
      _isLoading = false;
    });
  }

  Future<void> _deleteTrip(String tripId) async {
    await _tripService.deleteTrip(tripId);
    await _loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      appBarTitle: "Trajets Disponibles",
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomTheme.secondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ReusableTextField(
                  controller: _fromController,
                  hintText: "Départ (From)",
                  suffixIcon: const Icon(Icons.location_on_outlined),
                  onSubmited: (value) => _searchTrips(),
                ),
                ReusableTextField(
                  controller: _toController,
                  hintText: "Destination (To)",
                  suffixIcon: const Icon(Icons.location_on),
                  onSubmited: (value) => _searchTrips(),
                ),
                CustomRoundedButtom(
                  title: "Rechercher",
                  icon: Icons.search,
                  onPressed: _searchTrips,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.hp),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: CustomRoundedButtom(
                  title: "Ajouter un trajet",
                  icon: Icons.add,
                  color: CustomTheme.appColor,
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTripWidget(),
                      ),
                    );
                    if (result == true) {
                      _loadTrips();
                    }
                  },
                ),
              ),
              SizedBox(width: 12.wp),
              Expanded(
                child: CustomRoundedButtom(
                  title: "Mes réservations",
                  icon: Icons.bookmark,
                  color: Colors.transparent,
                  textColor: CustomTheme.appColor,
                  borderColor: CustomTheme.appColor,
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyBookedTripsWidget(),
                      ),
                    );
                    if (result == true) {
                      _loadTrips();
                    }
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 16.hp),

          // Contenu (loading / vide / liste)
          if (_isLoading)
            SizedBox(
              height: 200,
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_filteredTrips.isEmpty)
            Padding(
              padding: EdgeInsets.all(32.hp),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64.hp,
                    color: CustomTheme.gray,
                  ),
                  SizedBox(height: 16.hp),
                  Text(
                    "Aucun trajet disponible",
                    style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                      color: CustomTheme.darkColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _filteredTrips
                  .map((trip) => _buildTripCard(trip))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: EdgeInsets.only(bottom: 12.hp),
      decoration: BoxDecoration(
        border: Border.all(color: CustomTheme.appColor),
        color: CustomTheme.appColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CustomTheme.appColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getVehicleIcon(trip.vehicleType),
            color: CustomTheme.appColor,
            size: 32,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: CustomTheme.appColor),
                SizedBox(width: 8.wp),
                Expanded(
                  child: Text(
                    trip.from,
                    style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CustomTheme.darkColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.hp),
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: CustomTheme.googleColor),
                SizedBox(width: 8.wp),
                Expanded(
                  child: Text(
                    trip.to,
                    style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CustomTheme.darkColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.hp),
            Text(
              "Conducteur: ${trip.driverName}",
              style: PoppinsTextStyles.bodySmallRegular.copyWith(
                color: CustomTheme.darkColor.withOpacity(0.7),
              ),
            ),
            Text(
              "Départ: ${dateFormat.format(trip.departureTime)}",
              style: PoppinsTextStyles.bodySmallRegular.copyWith(
                color: CustomTheme.darkColor.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 4.hp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_seat, size: 16, color: CustomTheme.appColor),
                    SizedBox(width: 4.wp),
                    Text(
                      "${trip.availableSeats}/${trip.totalSeats} places",
                      style: PoppinsTextStyles.labelMediumRegular.copyWith(
                        fontWeight: FontWeight.w600,
                        color: trip.availableSeats > 0 
                            ? CustomTheme.appColor 
                            : CustomTheme.googleColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${trip.pricePerSeat.toStringAsFixed(2)} TND",
                  style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CustomTheme.appColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.hp),
            Row(
              children: [
                Expanded(
                  child: CustomRoundedButtom(
                    title: "Détails",
                    fontSize: 12,
                    verticalPadding: 8,
                    color: Colors.transparent,
                    borderColor: CustomTheme.appColor,
                    textColor: CustomTheme.appColor,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripDetailWidget(trip: trip),
                        ),
                      );
                      if (result == true) {
                        _loadTrips();
                      }
                    },
                  ),
                ),
                SizedBox(width: 8.wp),
                Expanded(
                  child: CustomRoundedButtom(
                    title: "Supprimer",
                    fontSize: 12,
                    verticalPadding: 8,
                    color: CustomTheme.googleColor,
                    onPressed: () {
                      _showDeleteConfirmation(trip);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'bike':
        return Icons.two_wheeler;
      case 'taxi':
        return Icons.local_taxi;
      case 'cycle':
        return Icons.pedal_bike;
      default:
        return Icons.directions_car;
    }
  }

  void _showDeleteConfirmation(TripModel trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirmer la suppression",
          style: PoppinsTextStyles.titleMediumRegular,
        ),
        content: Text(
          "Voulez-vous vraiment supprimer ce trajet de ${trip.from} à ${trip.to} ?",
          style: PoppinsTextStyles.bodyMediumRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Annuler",
              style: TextStyle(color: CustomTheme.darkColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTrip(trip.id);
            },
            child: Text(
              "Supprimer",
              style: TextStyle(color: CustomTheme.googleColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}





/*
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/constant/assets.dart';
import 'package:ridesharing/common/model/trip_model.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/common/widget/custom_text_field.dart';
import 'package:ridesharing/feature/dashboard/trips/service/trip_service.dart';
import 'package:ridesharing/feature/dashboard/trips/add_trip_widget.dart';
import 'package:ridesharing/feature/dashboard/trips/trip_detail_widget.dart';
import 'package:intl/intl.dart';

class TripsListWidget extends StatefulWidget {
  const TripsListWidget({super.key});

  @override
  State<TripsListWidget> createState() => _TripsListWidgetState();
}

class _TripsListWidgetState extends State<TripsListWidget> {
  final TripService _tripService = TripService();
  List<TripModel> _allTrips = [];
  List<TripModel> _filteredTrips = [];
  bool _isLoading = true;
  
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    await _tripService.initializeSampleData();
    final trips = await _tripService.getAllTrips();
    setState(() {
      _allTrips = trips;
      _filteredTrips = trips;
      _isLoading = false;
    });
  }

  Future<void> _searchTrips() async {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    if (from.isEmpty && to.isEmpty) {
      setState(() { _filteredTrips = _allTrips; });
      return;
    }
    setState(() => _isLoading = true);
    final results = await _tripService.searchTrips(from, to);
    setState(() {
      _filteredTrips = results;
      _isLoading = false;
    });
  }

  Future<void> _deleteTrip(String tripId) async {
    await _tripService.deleteTrip(tripId);
    await _loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      appBarTitle: "Trajets Disponibles",
      // IMPORTANT : on fournit une ListView en tant que body pour éviter
      // Expanded (qui casse le layout quand CommonContainer wrappe dans un Scroll)
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomTheme.secondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ReusableTextField(
                  controller: _fromController,
                  hintText: "Départ (From)",
                  suffixIcon: const Icon(Icons.location_on_outlined),
                  onSubmited: (value) => _searchTrips(),
                ),
                ReusableTextField(
                  controller: _toController,
                  hintText: "Destination (To)",
                  suffixIcon: const Icon(Icons.location_on),
                  onSubmited: (value) => _searchTrips(),
                ),
                CustomRoundedButtom(
                  title: "Rechercher",
                  icon: Icons.search,
                  onPressed: _searchTrips,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.hp),

          // Bouton pour ajouter un trajet
          CustomRoundedButtom(
            title: "Ajouter un trajet",
            icon: Icons.add,
            color: CustomTheme.appColor,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTripWidget(),
                ),
              );
              if (result == true) {
                _loadTrips();
              }
            },
          ),

          SizedBox(height: 16.hp),

          // Contenu (loading / vide / liste)
          if (_isLoading)
            SizedBox(
              height: 200, // espace pour le loader
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_filteredTrips.isEmpty)
            Padding(
              padding: EdgeInsets.all(32.hp),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64.hp,
                    color: CustomTheme.gray,
                  ),
                  SizedBox(height: 16.hp),
                  Text(
                    "Aucun trajet disponible",
                    style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                      color: CustomTheme.darkColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            // Afficher les cartes de trajets en tant que list de widgets
            Column(
              children: _filteredTrips
                  .map((trip) => _buildTripCard(trip))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: EdgeInsets.only(bottom: 12.hp),
      decoration: BoxDecoration(
        border: Border.all(color: CustomTheme.appColor),
        color: CustomTheme.appColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CustomTheme.appColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getVehicleIcon(trip.vehicleType),
            color: CustomTheme.appColor,
            size: 32,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: CustomTheme.appColor),
                SizedBox(width: 8.wp),
                Expanded(
                  child: Text(
                    trip.from,
                    style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CustomTheme.darkColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.hp),
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: CustomTheme.googleColor),
                SizedBox(width: 8.wp),
                Expanded(
                  child: Text(
                    trip.to,
                    style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CustomTheme.darkColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.hp),
            Text(
              "Conducteur: ${trip.driverName}",
              style: PoppinsTextStyles.bodySmallRegular.copyWith(
                color: CustomTheme.darkColor.withOpacity(0.7),
              ),
            ),
            Text(
              "Départ: ${dateFormat.format(trip.departureTime)}",
              style: PoppinsTextStyles.bodySmallRegular.copyWith(
                color: CustomTheme.darkColor.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 4.hp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_seat, size: 16, color: CustomTheme.appColor),
                    SizedBox(width: 4.wp),
                    Text(
                      "${trip.availableSeats}/${trip.totalSeats} places",
                      style: PoppinsTextStyles.labelMediumRegular.copyWith(
                        fontWeight: FontWeight.w600,
                        color: trip.availableSeats > 0 
                            ? CustomTheme.appColor 
                            : CustomTheme.googleColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${trip.pricePerSeat.toStringAsFixed(2)} TND",
                  style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CustomTheme.appColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.hp),
            Row(
              children: [
                Expanded(
                  child: CustomRoundedButtom(
                    title: "Détails",
                    fontSize: 12,
                    verticalPadding: 8,
                    color: Colors.transparent,
                    borderColor: CustomTheme.appColor,
                    textColor: CustomTheme.appColor,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripDetailWidget(trip: trip),
                        ),
                      );
                      if (result == true) {
                        _loadTrips();
                      }
                    },
                  ),
                ),
                SizedBox(width: 8.wp),
                Expanded(
                  child: CustomRoundedButtom(
                    title: "Supprimer",
                    fontSize: 12,
                    verticalPadding: 8,
                    color: CustomTheme.googleColor,
                    onPressed: () {
                      _showDeleteConfirmation(trip);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'bike':
        return Icons.two_wheeler;
      case 'taxi':
        return Icons.local_taxi;
      case 'cycle':
        return Icons.pedal_bike;
      default:
        return Icons.directions_car;
    }
  }

  void _showDeleteConfirmation(TripModel trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirmer la suppression",
          style: PoppinsTextStyles.titleMediumRegular,
        ),
        content: Text(
          "Voulez-vous vraiment supprimer ce trajet de ${trip.from} à ${trip.to} ?",
          style: PoppinsTextStyles.bodyMediumRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Annuler",
              style: TextStyle(color: CustomTheme.darkColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTrip(trip.id);
            },
            child: Text(
              "Supprimer",
              style: TextStyle(color: CustomTheme.googleColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}

*/





/*
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/constant/assets.dart';
import 'package:ridesharing/common/model/trip_model.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/common/widget/custom_text_field.dart';
import 'package:ridesharing/feature/dashboard/trips/service/trip_service.dart';
import 'package:ridesharing/feature/dashboard/trips/add_trip_widget.dart';
import 'package:ridesharing/feature/dashboard/trips/trip_detail_widget.dart';
import 'package:intl/intl.dart';

class TripsListWidget extends StatefulWidget {
  const TripsListWidget({super.key});

  @override
  State<TripsListWidget> createState() => _TripsListWidgetState();
}

class _TripsListWidgetState extends State<TripsListWidget> {
  final TripService _tripService = TripService();
  List<TripModel> _allTrips = [];
  List<TripModel> _filteredTrips = [];
  bool _isLoading = true;
  
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    
    // Initialiser les données de test si nécessaire
    await _tripService.initializeSampleData();
    
    final trips = await _tripService.getAllTrips();
    setState(() {
      _allTrips = trips;
      _filteredTrips = trips;
      _isLoading = false;
    });
  }

  Future<void> _searchTrips() async {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    
    if (from.isEmpty && to.isEmpty) {
      setState(() {
        _filteredTrips = _allTrips;
      });
      return;
    }
    
    setState(() => _isLoading = true);
    
    final results = await _tripService.searchTrips(from, to);
    setState(() {
      _filteredTrips = results;
      _isLoading = false;
    });
  }

  Future<void> _deleteTrip(String tripId) async {
    await _tripService.deleteTrip(tripId);
    _loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      appBarTitle: "Trajets Disponibles",
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomTheme.secondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ReusableTextField(
                  controller: _fromController,
                  hintText: "Départ (From)",
                  suffixIcon: const Icon(Icons.location_on_outlined),
                  onSubmited: (value) => _searchTrips(),
                ),
                ReusableTextField(
                  controller: _toController,
                  hintText: "Destination (To)",
                  suffixIcon: const Icon(Icons.location_on),
                  onSubmited: (value) => _searchTrips(),
                ),
                CustomRoundedButtom(
                  title: "Rechercher",
                  icon: Icons.search,
                  onPressed: _searchTrips,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.hp),
          
          // Bouton pour ajouter un trajet
          CustomRoundedButtom(
            title: "Ajouter un trajet",
            icon: Icons.add,
            color: CustomTheme.appColor,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTripWidget(),
                ),
              );
              
              if (result == true) {
                _loadTrips();
              }
            },
          ),
          
          SizedBox(height: 16.hp),
          
          // Liste des trajets
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_filteredTrips.isEmpty)
            Padding(
              padding: EdgeInsets.all(32.hp),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64.hp,
                    color: CustomTheme.gray,
                  ),
                  SizedBox(height: 16.hp),
                  Text(
                    "Aucun trajet disponible",
                    style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                      color: CustomTheme.darkColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredTrips.length,
                itemBuilder: (context, index) {
                  final trip = _filteredTrips[index];
                  return _buildTripCard(trip);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.hp),
      decoration: BoxDecoration(
        border: Border.all(color: CustomTheme.appColor),
        color: CustomTheme.appColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CustomTheme.appColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getVehicleIcon(trip.vehicleType),
            color: CustomTheme.appColor,
            size: 32,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: CustomTheme.appColor),
                SizedBox(width: 8.wp),
                Expanded(
                  child: Text(
                    trip.from,
                    style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CustomTheme.darkColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.hp),
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: CustomTheme.googleColor),
                SizedBox(width: 8.wp),
                Expanded(
                  child: Text(
                    trip.to,
                    style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CustomTheme.darkColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.hp),
            Text(
              "Conducteur: ${trip.driverName}",
              style: PoppinsTextStyles.bodySmallRegular.copyWith(
                color: CustomTheme.darkColor.withOpacity(0.7),
              ),
            ),
            Text(
              "Départ: ${dateFormat.format(trip.departureTime)}",
              style: PoppinsTextStyles.bodySmallRegular.copyWith(
                color: CustomTheme.darkColor.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 4.hp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_seat, size: 16, color: CustomTheme.appColor),
                    SizedBox(width: 4.wp),
                    Text(
                      "${trip.availableSeats}/${trip.totalSeats} places",
                      style: PoppinsTextStyles.labelMediumRegular.copyWith(
                        fontWeight: FontWeight.w600,
                        color: trip.availableSeats > 0 
                            ? CustomTheme.appColor 
                            : CustomTheme.googleColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${trip.pricePerSeat.toStringAsFixed(2)} TND",
                  style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CustomTheme.appColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.hp),
            Row(
              children: [
                Expanded(
                  child: CustomRoundedButtom(
                    title: "Détails",
                    fontSize: 12,
                    verticalPadding: 8,
                    color: Colors.transparent,
                    borderColor: CustomTheme.appColor,
                    textColor: CustomTheme.appColor,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripDetailWidget(trip: trip),
                        ),
                      );
                      
                      if (result == true) {
                        _loadTrips();
                      }
                    },
                  ),
                ),
                SizedBox(width: 8.wp),
                Expanded(
                  child: CustomRoundedButtom(
                    title: "Supprimer",
                    fontSize: 12,
                    verticalPadding: 8,
                    color: CustomTheme.googleColor,
                    onPressed: () {
                      _showDeleteConfirmation(trip);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'bike':
        return Icons.two_wheeler;
      case 'taxi':
        return Icons.local_taxi;
      case 'cycle':
        return Icons.pedal_bike;
      default:
        return Icons.directions_car;
    }
  }

  void _showDeleteConfirmation(TripModel trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirmer la suppression",
          style: PoppinsTextStyles.titleMediumRegular,
        ),
        content: Text(
          "Voulez-vous vraiment supprimer ce trajet de ${trip.from} à ${trip.to} ?",
          style: PoppinsTextStyles.bodyMediumRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Annuler",
              style: TextStyle(color: CustomTheme.darkColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTrip(trip.id);
            },
            child: Text(
              "Supprimer",
              style: TextStyle(color: CustomTheme.googleColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}
*/