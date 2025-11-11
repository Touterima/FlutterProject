import 'package:flutter/material.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/model/reservation_model.dart';
import 'package:ridesharing/common/model/trajet_model.dart';
import 'package:ridesharing/common/database/database_helper.dart';

class MyReservationsScreen extends StatefulWidget {
  final int currentUserId = 1;

  const MyReservationsScreen({Key? key}) : super(key: key);

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      final resList =
          await _dbHelper.getReservationsByUserId(widget.currentUserId);
      final List<Map<String, dynamic>> joined = [];

      for (var res in resList) {
        final trajet = await _dbHelper.getTrajetById(res.trajetId);
        if (trajet != null) {
          joined.add({"reservation": res, "trajet": trajet});
        }
      }

      setState(() {
        reservations = joined;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading reservations: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _cancelReservation(Reservation res) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Reservation"),
        content:
            const Text("Are you sure you want to cancel this reservation?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.cancelReservation(res.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reservation cancelled successfully"),
            backgroundColor: Colors.orange,
          ),
        );
        _loadReservations();
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
        title: Text(
          "My Reservations",
          style: PoppinsTextStyles.subheadLargeRegular.copyWith(
            color: CustomTheme.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : reservations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation =
                        reservations[index]["reservation"] as Reservation;
                    final trajet = reservations[index]["trajet"] as Trajet;

                    return _buildReservationCard(reservation, trajet);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 100, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'No reservations yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Book rides to see them here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation, Trajet trajet) {
    // ✅ handle null safety
    final String status = reservation.statut?.toLowerCase() ?? "inconnu";

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'confirmee':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'en attente':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'annulee':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: CustomTheme.appColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 5),
              Text(
                (reservation.statut ?? "INCONNU").toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Icon(Icons.directions_car, color: CustomTheme.appColor, size: 26),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${trajet.pointDepart} → ${trajet.pointArrivee}',
            style: PoppinsTextStyles.subheadLargeRegular.copyWith(
              color: CustomTheme.darkColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.person, "Driver", trajet.conducteur),
          _buildInfoRow(Icons.calendar_today, "Date",
              "${trajet.date} at ${trajet.heure}"),
          _buildInfoRow(
              Icons.event_seat, "Seats", "${reservation.nbPlacesReservees}"),
          _buildInfoRow(
              Icons.attach_money, "Total", "${reservation.prixTotal} TND"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text("Details"),
                  onPressed: () => _showDetailsDialog(reservation, trajet),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomTheme.appColor,
                    side: BorderSide(color: CustomTheme.appColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (status == 'confirmee')
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text("Cancel"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _cancelReservation(reservation),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 16),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(Reservation res, Trajet trajet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reservation Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem(
                "Route", "${trajet.pointDepart} → ${trajet.pointArrivee}"),
            _buildDetailItem("Driver", trajet.conducteur),
            _buildDetailItem("Date & Time", "${trajet.date} at ${trajet.heure}"),
            _buildDetailItem("Seats Reserved", "${res.nbPlacesReservees}"),
            _buildDetailItem("Total Amount", "${res.prixTotal} TND"),
            _buildDetailItem("Status", res.statut ?? "Unknown"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              )),
          Text(value,
              style:
                  const TextStyle(color: Colors.black87, fontSize: 14)),
        ],
      ),
    );
  }
}
