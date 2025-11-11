//lib/feature/dashboard/trips/trip_detail_widget.dart
import 'package:flutter/material.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/model/trip_model.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/common_popup_box.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/feature/dashboard/trips/service/trip_service.dart';
import 'package:intl/intl.dart';
import 'package:ridesharing/common/constant/assets.dart';

import 'package:ridesharing/feature/dashboard/trips/service/map_service.dart';
import 'package:ridesharing/feature/dashboard/trips/trip_map_widget.dart';

class TripDetailWidget extends StatefulWidget {
  final TripModel trip;
  
  const TripDetailWidget({super.key, required this.trip});

  

  @override
  State<TripDetailWidget> createState() => _TripDetailWidgetState();
}

class _TripDetailWidgetState extends State<TripDetailWidget> {
  final TripService _tripService = TripService();
  late TripModel _trip;
  int _seatsToBook = 1;
  bool _isLoading = false;


Map<String, dynamic>? _routeData;
  bool _loadingRoute = false;


  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _loadRouteData();
  }

Future<void> _loadRouteData() async {
  setState(() => _loadingRoute = true);
  
  final mapService = MapService();
  final routeData = await mapService.calculateRoute(_trip.from, _trip.to);
  
  setState(() {
    _routeData = routeData;
    _loadingRoute = false;
  });
}


  // Fonction pour obtenir le nom du jour en français
  String _getDayName(DateTime date) {
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[date.weekday - 1];
  }

  // Fonction pour obtenir le nom du mois en français
  String _getMonthName(DateTime date) {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[date.month - 1];
  }

  // Formater la date complète
  String _formatFullDate(DateTime date) {
    return '${_getDayName(date)} ${date.day} ${_getMonthName(date)} ${date.year}';
  }

  Future<void> _bookTrip() async {
    if (_trip.availableSeats < _seatsToBook) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pas assez de places disponibles'),
          backgroundColor: CustomTheme.googleColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _tripService.bookTrip(_trip.id, _seatsToBook);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        showCommonPopUpDialog(
          context: context,
          imageUrl: Assets.successAlertImage,
          title: "Réservation réussie!",
          message: "Vous avez réservé $_seatsToBook place(s) pour le trajet de ${_trip.from} à ${_trip.to}",
          enableButtonName: "OK",
          onEnablePressed: () {
            Navigator.pop(context);
            Navigator.pop(context, true);
          },
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la réservation'),
            backgroundColor: CustomTheme.googleColor,
          ),
        );
      }
    }
  }

  Future<void> _cancelBooking() async {
    setState(() => _isLoading = true);

    final success = await _tripService.cancelBooking(_trip.id, _seatsToBook);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        showCommonPopUpDialog(
          context: context,
          imageUrl: Assets.successAlertImage,
          title: "Annulation réussie",
          message: "Votre réservation a été annulée avec succès",
          enableButtonName: "OK",
          onEnablePressed: () {
            Navigator.pop(context);
            Navigator.pop(context, true);
          },
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'annulation'),
            backgroundColor: CustomTheme.googleColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format simple sans locale spécifique
    final timeFormat = DateFormat('HH:mm');

    return CommonContainer(
      appBarTitle: "Détails du trajet",
      showBackBotton: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carte d'en-tête avec l'itinéraire
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CustomTheme.appColor,
                    CustomTheme.appColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CustomTheme.appColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                              _trip.from,
                              style: PoppinsTextStyles.titleMediumRegular.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 4.hp),
                            Text(
                              "Départ",
                              style: PoppinsTextStyles.bodySmallRegular.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _trip.to,
                              style: PoppinsTextStyles.titleMediumRegular.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 4.hp),
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
                ],
              ),
            ),

            SizedBox(height: 20.hp),

            // Date et heure
            _buildInfoSection(
              icon: Icons.calendar_today,
              title: "Date et heure de départ",
              content: "${_formatFullDate(_trip.departureTime)}\n${timeFormat.format(_trip.departureTime)}",
            ),

            // Informations du conducteur
            _buildInfoSection(
              icon: Icons.person,
              title: "Conducteur",
              content: _trip.driverName,
            ),

            _buildInfoSection(
              icon: Icons.phone,
              title: "Téléphone",
              content: _trip.driverPhone,
            ),

            // Informations du véhicule
            _buildInfoSection(
              icon: Icons.directions_car,
              title: "Type de véhicule",
              content: _trip.vehicleType,
            ),

            

            // Section Carte et Itinéraire
            if (_loadingRoute)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16.hp),
                    Text(
                      "Calcul de l'itinéraire...",
                      style: PoppinsTextStyles.bodySmallRegular,
                    ),
                  ],
                ),
              )
            else if (_routeData != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16.hp),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomTheme.appColor.withOpacity(0.1),
                      CustomTheme.appColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CustomTheme.appColor, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.map, color: CustomTheme.appColor, size: 24),
                        SizedBox(width: 12.wp),
                        Text(
                          "Informations de l'itinéraire",
                          style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                            fontWeight: FontWeight.w700,
                            color: CustomTheme.appColor,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.hp),
                    
                    // Distance et durée
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.straighten, color: CustomTheme.appColor, size: 32),
                                SizedBox(height: 8.hp),
                                Text(
                                  _routeData!['distance_text'],
                                  style: PoppinsTextStyles.titleMediumRegular.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: CustomTheme.appColor,
                                  ),
                                ),
                                Text(
                                  "Distance",
                                  style: PoppinsTextStyles.bodySmallRegular.copyWith(
                                    color: CustomTheme.darkColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 12.wp),
                        
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.access_time, color: CustomTheme.appColor, size: 32),
                                SizedBox(height: 8.hp),
                                Text(
                                  _routeData!['duration_text'],
                                  style: PoppinsTextStyles.titleMediumRegular.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: CustomTheme.appColor,
                                  ),
                                ),
                                Text(
                                  "Durée",
                                  style: PoppinsTextStyles.bodySmallRegular.copyWith(
                                    color: CustomTheme.darkColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.hp),
                    
                    // Bouton pour voir la carte
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripMapWidget(
                              routeData: _routeData!,
                              fromCity: _trip.from,
                              toCity: _trip.to,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.map_outlined),
                      label: Text("Voir la carte interactive"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.appColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16.hp),
                decoration: BoxDecoration(
                  color: CustomTheme.gray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CustomTheme.gray),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: CustomTheme.gray),
                    SizedBox(width: 12.wp),
                    Expanded(
                      child: Text(
                        "Informations d'itinéraire non disponibles",
                        style: PoppinsTextStyles.bodySmallRegular.copyWith(
                          color: CustomTheme.gray,
                        ),
                      ),
                    ),
                  ],
                ),
              ),







            // Places disponibles
            Container(
              padding: const EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 16.hp),
              decoration: BoxDecoration(
                color: CustomTheme.secondaryColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CustomTheme.appColor, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CustomTheme.appColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.event_seat,
                          color: CustomTheme.appColor,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12.wp),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Places disponibles",
                            style: PoppinsTextStyles.labelMediumRegular.copyWith(
                              color: CustomTheme.darkColor.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            "${_trip.availableSeats}/${_trip.totalSeats}",
                            style: PoppinsTextStyles.titleMediumRegular.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _trip.availableSeats > 0
                                  ? CustomTheme.appColor
                                  : CustomTheme.googleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Sélecteur de places
                  if (_trip.availableSeats > 0)
                    Container(
                      decoration: BoxDecoration(
                        color: CustomTheme.appColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            color: CustomTheme.appColor,
                            onPressed: () {
                              if (_seatsToBook > 1) {
                                setState(() => _seatsToBook--);
                              }
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: CustomTheme.appColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _seatsToBook.toString(),
                              style: PoppinsTextStyles.titleMediumRegular.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            color: CustomTheme.appColor,
                            onPressed: () {
                              if (_seatsToBook < _trip.availableSeats) {
                                setState(() => _seatsToBook++);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Prix
            Container(
              padding: const EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 24.hp),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CustomTheme.appColor.withOpacity(0.1),
                    CustomTheme.appColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomTheme.appColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Prix total",
                        style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                          fontWeight: FontWeight.w600,
                          color: CustomTheme.darkColor.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        "$_seatsToBook place(s) × ${_trip.pricePerSeat.toStringAsFixed(2)} TND",
                        style: PoppinsTextStyles.bodySmallRegular.copyWith(
                          color: CustomTheme.darkColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${(_trip.pricePerSeat * _seatsToBook).toStringAsFixed(2)} TND",
                    style: PoppinsTextStyles.titleMediumRegular.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CustomTheme.appColor,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Boutons d'action
            if (_trip.availableSeats > 0)
              CustomRoundedButtom(
                title: _isLoading ? "Réservation..." : "Réserver maintenant",
                isLoading: _isLoading,
                isDisabled: _isLoading,
                icon: Icons.check_circle_outline,
                onPressed: _bookTrip,
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomTheme.googleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CustomTheme.googleColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, color: CustomTheme.googleColor),
                    SizedBox(width: 8.wp),
                    Text(
                      "Aucune place disponible",
                      style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                        color: CustomTheme.googleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 12.hp),

            // Bouton pour annuler (si déjà réservé)
            if (_trip.bookedBy.contains('current_user_id'))
              CustomRoundedButtom(
                title: "Annuler ma réservation",
                color: Colors.transparent,
                borderColor: CustomTheme.googleColor,
                textColor: CustomTheme.googleColor,
                icon: Icons.cancel_outlined,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: CustomTheme.googleColor),
                          SizedBox(width: 8.wp),
                          Text(
                            "Confirmer l'annulation",
                            style: PoppinsTextStyles.titleMediumRegular,
                          ),
                        ],
                      ),
                      content: Text(
                        "Voulez-vous vraiment annuler votre réservation ?",
                        style: PoppinsTextStyles.bodyMediumRegular,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Non"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomTheme.googleColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _cancelBooking();
                          },
                          child: Text(
                            "Oui, annuler",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            SizedBox(height: 20.hp),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16.hp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomTheme.gray.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.appColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomTheme.appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: CustomTheme.appColor, size: 24),
          ),
          SizedBox(width: 16.wp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PoppinsTextStyles.bodySmallRegular.copyWith(
                    color: CustomTheme.darkColor.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 4.hp),
                Text(
                  content,
                  style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CustomTheme.darkColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





/*
import 'package:flutter/material.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/model/trip_model.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/common_popup_box.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/feature/dashboard/trips/service/trip_service.dart';
import 'package:intl/intl.dart';
import 'package:ridesharing/common/constant/assets.dart';

class TripDetailWidget extends StatefulWidget {
  final TripModel trip;
  
  const TripDetailWidget({super.key, required this.trip});

  @override
  State<TripDetailWidget> createState() => _TripDetailWidgetState();
}

class _TripDetailWidgetState extends State<TripDetailWidget> {
  final TripService _tripService = TripService();
  late TripModel _trip;
  int _seatsToBook = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  Future<void> _bookTrip() async {
    if (_trip.availableSeats < _seatsToBook) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pas assez de places disponibles'),
          backgroundColor: CustomTheme.googleColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _tripService.bookTrip(_trip.id, _seatsToBook);

    setState(() => _isLoading = false);

    if (success) {
      showCommonPopUpDialog(
        context: context,
        imageUrl: Assets.successAlertImage,
        title: "Réservation réussie!",
        message: "Vous avez réservé $_seatsToBook place(s) pour le trajet de ${_trip.from} à ${_trip.to}",
        enableButtonName: "OK",
        onEnablePressed: () {
          Navigator.pop(context, true);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la réservation'),
          backgroundColor: CustomTheme.googleColor,
        ),
      );
    }
  }

  Future<void> _cancelBooking() async {
    setState(() => _isLoading = true);

    final success = await _tripService.cancelBooking(_trip.id, _seatsToBook);

    setState(() => _isLoading = false);

    if (success) {
      showCommonPopUpDialog(
        context: context,
        imageUrl: Assets.successAlertImage,
        title: "Annulation réussie",
        message: "Votre réservation a été annulée avec succès",
        enableButtonName: "OK",
        onEnablePressed: () {
          Navigator.pop(context, true);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'annulation'),
          backgroundColor: CustomTheme.googleColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE dd MMMM yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm');

    return CommonContainer(
      appBarTitle: "Détails du trajet",
      showBackBotton: true,
      body: ListView(
        shrinkWrap: true,
        children: [
          // Carte d'en-tête avec l'itinéraire
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomTheme.appColor,
                  CustomTheme.appColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                            _trip.from,
                            style: PoppinsTextStyles.titleMediumRegular.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 4.hp),
                          Text(
                            "Départ",
                            style: PoppinsTextStyles.bodySmallRegular.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 32,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _trip.to,
                            style: PoppinsTextStyles.titleMediumRegular.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 4.hp),
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
              ],
            ),
          ),

          SizedBox(height: 20.hp),

          // Date et heure
          _buildInfoSection(
            icon: Icons.calendar_today,
            title: "Date et heure de départ",
            content: "${dateFormat.format(_trip.departureTime)}\n${timeFormat.format(_trip.departureTime)}",
          ),

          // Informations du conducteur
          _buildInfoSection(
            icon: Icons.person,
            title: "Conducteur",
            content: _trip.driverName,
          ),

          _buildInfoSection(
            icon: Icons.phone,
            title: "Téléphone",
            content: _trip.driverPhone,
          ),

          // Informations du véhicule
          _buildInfoSection(
            icon: Icons.directions_car,
            title: "Type de véhicule",
            content: _trip.vehicleType,
          ),

          // Places disponibles
          Container(
            padding: const EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 16.hp),
            decoration: BoxDecoration(
              color: CustomTheme.secondaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CustomTheme.appColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_seat, color: CustomTheme.appColor, size: 24),
                    SizedBox(width: 12.wp),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Places disponibles",
                          style: PoppinsTextStyles.labelMediumRegular.copyWith(
                            color: CustomTheme.darkColor.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          "${_trip.availableSeats}/${_trip.totalSeats}",
                          style: PoppinsTextStyles.titleMediumRegular.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _trip.availableSeats > 0
                                ? CustomTheme.appColor
                                : CustomTheme.googleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Sélecteur de places
                if (_trip.availableSeats > 0)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        color: CustomTheme.appColor,
                        onPressed: () {
                          if (_seatsToBook > 1) {
                            setState(() => _seatsToBook--);
                          }
                        },
                      ),
                      Text(
                        _seatsToBook.toString(),
                        style: PoppinsTextStyles.titleMediumRegular.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        color: CustomTheme.appColor,
                        onPressed: () {
                          if (_seatsToBook < _trip.availableSeats) {
                            setState(() => _seatsToBook++);
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Prix
          Container(
            padding: const EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 24.hp),
            decoration: BoxDecoration(
              color: CustomTheme.appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Prix total",
                  style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${(_trip.pricePerSeat * _seatsToBook).toStringAsFixed(2)} TND",
                  style: PoppinsTextStyles.titleMediumRegular.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CustomTheme.appColor,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),

          // Boutons d'action
          if (_trip.availableSeats > 0)
            CustomRoundedButtom(
              title: _isLoading ? "Réservation..." : "Réserver maintenant",
              isLoading: _isLoading,
              isDisabled: _isLoading,
              onPressed: _bookTrip,
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomTheme.googleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "Aucune place disponible",
                  style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                    color: CustomTheme.googleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          SizedBox(height: 12.hp),

          // Bouton pour annuler (si déjà réservé)
          if (_trip.bookedBy.contains('current_user_id'))
            CustomRoundedButtom(
              title: "Annuler ma réservation",
              color: Colors.transparent,
              borderColor: CustomTheme.googleColor,
              textColor: CustomTheme.googleColor,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      "Confirmer l'annulation",
                      style: PoppinsTextStyles.titleMediumRegular,
                    ),
                    content: Text(
                      "Voulez-vous vraiment annuler votre réservation ?",
                      style: PoppinsTextStyles.bodyMediumRegular,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Non"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _cancelBooking();
                        },
                        child: Text(
                          "Oui, annuler",
                          style: TextStyle(color: CustomTheme.googleColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16.hp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomTheme.gray),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomTheme.appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: CustomTheme.appColor, size: 24),
          ),
          SizedBox(width: 16.wp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PoppinsTextStyles.bodySmallRegular.copyWith(
                    color: CustomTheme.darkColor.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 4.hp),
                Text(
                  content,
                  style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CustomTheme.darkColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/