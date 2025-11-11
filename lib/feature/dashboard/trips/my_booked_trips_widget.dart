//lib/feature/dashboard/trips/my_booked_trips_widget.dart
import 'package:flutter/material.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/model/trip_model.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/feature/dashboard/trips/service/trip_service.dart';
import 'package:ridesharing/feature/dashboard/trips/trip_detail_widget.dart';
import 'package:intl/intl.dart';

class MyBookedTripsWidget extends StatefulWidget {
  const MyBookedTripsWidget({super.key});

  @override
  State<MyBookedTripsWidget> createState() => _MyBookedTripsWidgetState();
}

class _MyBookedTripsWidgetState extends State<MyBookedTripsWidget> {
  final TripService _tripService = TripService();
  List<TripModel> _bookedTrips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookedTrips();
  }

  Future<void> _loadBookedTrips() async {
    setState(() => _isLoading = true);
    
    final trips = await _tripService.getMyBookedTrips();
    
    setState(() {
      _bookedTrips = trips;
      _isLoading = false;
    });
  }

  Future<void> _cancelBooking(TripModel trip) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirmer l'annulation",
          style: PoppinsTextStyles.titleMediumRegular,
        ),
        content: Text(
          "Voulez-vous vraiment annuler votre réservation pour le trajet de ${trip.from} à ${trip.to} ?",
          style: PoppinsTextStyles.bodyMediumRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Non",
              style: TextStyle(color: CustomTheme.darkColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Oui, annuler",
              style: TextStyle(color: CustomTheme.googleColor),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      
      final success = await _tripService.cancelBooking(trip.id, 1);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation annulée avec succès'),
            backgroundColor: CustomTheme.appColor,
          ),
        );
        _loadBookedTrips();
      } else {
        setState(() => _isLoading = false);
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
    return CommonContainer(
      appBarTitle: "Mes Réservations",
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookedTrips.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _bookedTrips.length,
                  itemBuilder: (context, index) {
                    return _buildBookedTripCard(_bookedTrips[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.hp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80.hp,
              color: CustomTheme.gray,
            ),
            SizedBox(height: 24.hp),
            Text(
              "Aucune réservation",
              style: PoppinsTextStyles.titleMediumRegular.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.hp),
            Text(
              "Vous n'avez pas encore réservé de trajet",
              style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                color: CustomTheme.darkColor.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookedTripCard(TripModel trip) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    final isPast = trip.departureTime.isBefore(now);

    return Container(
      margin: EdgeInsets.only(bottom: 16.hp),
      decoration: BoxDecoration(
        border: Border.all(
          color: isPast ? CustomTheme.gray : CustomTheme.appColor,
        ),
        color: isPast 
            ? CustomTheme.gray.withOpacity(0.1)
            : CustomTheme.appColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // En-tête avec badge de statut
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPast 
                  ? CustomTheme.gray.withOpacity(0.3)
                  : CustomTheme.appColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isPast ? Icons.history : Icons.check_circle,
                      color: isPast ? CustomTheme.gray : CustomTheme.appColor,
                      size: 20,
                    ),
                    SizedBox(width: 8.wp),
                    Text(
                      isPast ? "Terminé" : "Confirmé",
                      style: PoppinsTextStyles.labelMediumRegular.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isPast ? CustomTheme.gray : CustomTheme.appColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trip.vehicleType,
                    style: PoppinsTextStyles.bodySmallRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CustomTheme.appColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Itinéraire
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 12,
                                color: CustomTheme.appColor,
                              ),
                              SizedBox(width: 8.wp),
                              Expanded(
                                child: Text(
                                  trip.from,
                                  style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: CustomTheme.darkColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Container(
                              width: 2,
                              height: 20,
                              color: CustomTheme.appColor.withOpacity(0.3),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: CustomTheme.googleColor,
                              ),
                              SizedBox(width: 8.wp),
                              Expanded(
                                child: Text(
                                  trip.to,
                                  style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: CustomTheme.darkColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.hp),

                // Informations du trajet
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.calendar_today,
                        "Date",
                        dateFormat.format(trip.departureTime),
                      ),
                      Divider(height: 16, color: CustomTheme.gray.withOpacity(0.3)),
                      _buildInfoRow(
                        Icons.access_time,
                        "Heure",
                        timeFormat.format(trip.departureTime),
                      ),
                      Divider(height: 16, color: CustomTheme.gray.withOpacity(0.3)),
                      _buildInfoRow(
                        Icons.person,
                        "Conducteur",
                        trip.driverName,
                      ),
                      Divider(height: 16, color: CustomTheme.gray.withOpacity(0.3)),
                      _buildInfoRow(
                        Icons.phone,
                        "Téléphone",
                        trip.driverPhone,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.hp),

                // Prix
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CustomTheme.appColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Prix payé",
                        style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${trip.pricePerSeat.toStringAsFixed(2)} TND",
                        style: PoppinsTextStyles.titleMediumRegular.copyWith(
                          fontWeight: FontWeight.w700,
                          color: CustomTheme.appColor,
                        ),
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
                        title: "Détails",
                        fontSize: 13,
                        verticalPadding: 10,
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
                            _loadBookedTrips();
                          }
                        },
                      ),
                    ),
                    if (!isPast) ...[
                      SizedBox(width: 12.wp),
                      Expanded(
                        child: CustomRoundedButtom(
                          title: "Annuler",
                          fontSize: 13,
                          verticalPadding: 10,
                          color: CustomTheme.googleColor,
                          onPressed: () => _cancelBooking(trip),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: CustomTheme.appColor),
        SizedBox(width: 12.wp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: PoppinsTextStyles.bodySmallRegular.copyWith(
                  color: CustomTheme.darkColor.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: PoppinsTextStyles.labelMediumRegular.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CustomTheme.darkColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}