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
