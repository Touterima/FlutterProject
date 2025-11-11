import 'package:flutter/material.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/constant/assets.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/common_popup_box.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/feature/dashboard/dashboard_widget.dart';
import 'package:ridesharing/common/database/database_helper.dart';
import 'package:ridesharing/common/model/trajet_model.dart';
import 'package:ridesharing/common/model/reservation_model.dart';
import 'package:ridesharing/feature/rideFlow/my_reservations_screen.dart';



class AvailableRideScreen extends StatefulWidget {
  final int currentUserId; // Pass the logged-in user ID
  
  const AvailableRideScreen({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<AvailableRideScreen> createState() => _AvailableRideScreenState();
}

class _AvailableRideScreenState extends State<AvailableRideScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Trajet> trajets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrajets();
  }

  Future<void> _loadTrajets() async {
    try {
      final loadedTrajets = await _dbHelper.getAllTrajets();
      setState(() {
        trajets = loadedTrajets;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rides: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
       title: const Text(
          'Available cars for ride',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
            IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.teal),
            onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyReservationsScreen(),
                ),
                );
            },
            tooltip: 'My Reservations',
            ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: CustomTheme.appColor),
            )
          : trajets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16.hp),
                      Text(
                        'No rides available',
                        style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                          color: CustomTheme.darkColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        '${trajets.length} ride${trajets.length > 1 ? 's' : ''} found',
                        style: PoppinsTextStyles.bodySmallRegular.copyWith(
                          fontSize: 14,
                          color: CustomTheme.darkColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: trajets.length,
                        itemBuilder: (context, index) {
                          return AvailableRideBoxDesign(
                            trajet: trajets[index],
                            currentUserId: widget.currentUserId,
                            onReservationMade: _loadTrajets,
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class AvailableRideBoxDesign extends StatelessWidget {
  final Trajet trajet;
  final int currentUserId;
  final VoidCallback onReservationMade;

  const AvailableRideBoxDesign({
    super.key,
    required this.trajet,
    required this.currentUserId,
    required this.onReservationMade,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSeats = trajet.nbPlacesDispo > 0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: hasSeats ? CustomTheme.appColor : Colors.grey.shade300,
        ),
        color: hasSeats
            ? CustomTheme.appColor.withOpacity(0.08)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trajet.pointDepart} → ${trajet.pointArrivee}',
                      style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                        color: CustomTheme.darkColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.hp),
                    Text(
                      'Driver: ${trajet.conducteur}',
                      style: PoppinsTextStyles.bodySmallRegular.copyWith(
                        color: CustomTheme.darkColor.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: 2.hp),
                    Text(
                      '${trajet.nbPlacesDispo} seat${trajet.nbPlacesDispo > 1 ? 's' : ''} available',
                      style: PoppinsTextStyles.bodySmallRegular.copyWith(
                        color: hasSeats ? CustomTheme.appColor : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.hp),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: CustomTheme.darkColor.withOpacity(0.6),
                        ),
                        SizedBox(width: 4.wp),
                        Text(
                          '${trajet.date} at ${trajet.heure}',
                          style: PoppinsTextStyles.labelMediumRegular.copyWith(
                            color: CustomTheme.darkColor.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.hp),
                    Text(
                      '${trajet.prix.toStringAsFixed(2)} TND',
                      style: PoppinsTextStyles.labelMediumRegular.copyWith(
                        color: CustomTheme.darkColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                Assets.bmwCario,
                width: 100,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.directions_car,
                    size: 80,
                    color: CustomTheme.appColor.withOpacity(0.5),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10.hp),
          Row(
            children: [
              Expanded(
                child: CustomRoundedButtom(
                  color: Colors.transparent,
                  borderColor: hasSeats ? CustomTheme.appColor : Colors.grey,
                  title: hasSeats ? "Book Later" : "Full",
                  textColor: hasSeats ? CustomTheme.appColor : Colors.grey,
                  onPressed: hasSeats
                      ? () => _showReservationDialog(context)
                      : null,
                ),
              ),
              SizedBox(width: 10.wp),
              Expanded(
                child: CustomRoundedButtom(
                  color: hasSeats ? CustomTheme.appColor : Colors.grey.shade300,
                  borderColor: hasSeats ? CustomTheme.appColor : Colors.grey.shade300,
                  title: hasSeats ? "Book Now" : "Unavailable",
                  textColor: Colors.white,
                  onPressed: hasSeats
                      ? () => _makeReservation(context, 1)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReservationDialog(BuildContext context) {
    int selectedPlaces = 1;
    String comment = '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Book Reservation',
                style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                  color: CustomTheme.darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${trajet.pointDepart} → ${trajet.pointArrivee}',
                      style: PoppinsTextStyles.bodySmallRegular.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: CustomTheme.darkColor,
                      ),
                    ),
                    SizedBox(height: 15.hp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Number of seats:',
                          style: PoppinsTextStyles.bodySmallRegular.copyWith(
                            color: CustomTheme.darkColor,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: CustomTheme.appColor,
                              ),
                              onPressed: selectedPlaces > 1
                                  ? () {
                                      setDialogState(() {
                                        selectedPlaces--;
                                      });
                                    }
                                  : null,
                            ),
                            Text(
                              '$selectedPlaces',
                              style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CustomTheme.darkColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: CustomTheme.appColor,
                              ),
                              onPressed: selectedPlaces < trajet.nbPlacesDispo
                                  ? () {
                                      setDialogState(() {
                                        selectedPlaces++;
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.hp),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Comment (optional)',
                        labelStyle: PoppinsTextStyles.bodySmallRegular,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: CustomTheme.appColor),
                        ),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        comment = value;
                      },
                    ),
                    SizedBox(height: 15.hp),
                    Container(
                      padding: EdgeInsets.all(12.hp),
                      decoration: BoxDecoration(
                        color: CustomTheme.appColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: PoppinsTextStyles.bodySmallRegular.copyWith(
                              fontWeight: FontWeight.w600,
                              color: CustomTheme.darkColor,
                            ),
                          ),
                          Text(
                            '${(trajet.prix * selectedPlaces).toStringAsFixed(2)} TND',
                            style: PoppinsTextStyles.subheadLargeRegular.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CustomTheme.appColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: PoppinsTextStyles.bodySmallRegular.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _makeReservation(context, selectedPlaces, comment: comment);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.appColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: PoppinsTextStyles.bodySmallRegular.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _makeReservation(
    BuildContext context,
    int nbPlaces, {
    String comment = '',
  }) async {
    try {
      final dbHelper = DatabaseHelper();
      
      final reservation = Reservation(
        userId: currentUserId,
        trajetId: trajet.id!,
        nbPlacesReservees: nbPlaces,
        dateReservation: DateTime.now().toIso8601String(),
        statut: 'confirmee',
        prixTotal: trajet.prix * nbPlaces,
      );

      await dbHelper.insertReservation(reservation);

      if (context.mounted) {
        showCommonPopUpDialog(
          imageUrl: Assets.successAlertImage,
          title: "Booking Success",
          context: context,
          enableButtonName: "Done",
          onEnablePressed: () {
            Navigator.pop(context);
            onReservationMade();
          },
          message:
              "Your reservation for $nbPlaces seat${nbPlaces > 1 ? 's' : ''} has been confirmed. Total: ${(trajet.prix * nbPlaces).toStringAsFixed(2)} TND",
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making reservation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}