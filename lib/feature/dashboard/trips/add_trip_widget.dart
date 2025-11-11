//lib/feature/dashboard/trips/add_trip_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/model/trip_model.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/common_dropdown_box.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/common/widget/custom_text_field.dart';
import 'package:ridesharing/feature/dashboard/trips/service/trip_service.dart';
import 'package:intl/intl.dart';
import 'package:ridesharing/feature/dashboard/trips/service/map_service.dart';



class AddTripWidget extends StatefulWidget {
  const AddTripWidget({super.key});

  @override
  State<AddTripWidget> createState() => _AddTripWidgetState();
}

class _AddTripWidgetState extends State<AddTripWidget> {
  final _formKey = GlobalKey<FormState>();
  final TripService _tripService = TripService();
  
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverPhoneController = TextEditingController();
  final TextEditingController _totalSeatsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  

  final MapService _mapService = MapService();
  bool _calculatingPrice = false;
  double? _suggestedPrice;
  String? _estimatedDistance;
  String? _estimatedDuration;


  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  final List<String> _vehicleTypes = ['Car', 'Bike', 'Taxi', 'Cycle'];

  @override
  void initState() {
    super.initState();
    _vehicleTypeController.text = _vehicleTypes.first;
  }


  Future<void> _calculateSuggestedPrice() async {
  final from = _fromController.text.trim();
  final to = _toController.text.trim();
  
  if (from.isEmpty || to.isEmpty) {
    return;
  }
  
  setState(() {
    _calculatingPrice = true;
    _suggestedPrice = null;
    _estimatedDistance = null;
    _estimatedDuration = null;
  });
  
  try {
    final routeData = await _mapService.calculateRoute(from, to);
    
    if (routeData != null) {
      final distanceKm = routeData['distance_km'] as double;
      final price = _mapService.calculateSuggestedPrice(distanceKm);
      
      setState(() {
        _suggestedPrice = price;
        _estimatedDistance = routeData['distance_text'];
        _estimatedDuration = routeData['duration_text'];
        _priceController.text = price.toStringAsFixed(2);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prix suggéré : ${price.toStringAsFixed(2)} TND'),
          backgroundColor: CustomTheme.appColor,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de calculer l\'itinéraire'),
          backgroundColor: CustomTheme.googleColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erreur calcul prix: $e');
    }
  } finally {
    setState(() => _calculatingPrice = false);
  }
}


  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _addTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner la date et l\'heure de départ'),
          backgroundColor: CustomTheme.googleColor,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Combiner date et heure
      final departureTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      
      final trip = TripModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        from: _fromController.text.trim(),
        to: _toController.text.trim(),
        driverName: _driverNameController.text.trim(),
        driverPhone: _driverPhoneController.text.trim(),
        departureTime: departureTime,
        totalSeats: int.parse(_totalSeatsController.text),
        availableSeats: int.parse(_totalSeatsController.text),
        pricePerSeat: double.parse(_priceController.text),
        vehicleType: _vehicleTypeController.text,
      );
      
      await _tripService.addTrip(trip);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trajet ajouté avec succès!'),
            backgroundColor: CustomTheme.appColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout: ${e.toString()}'),
            backgroundColor: CustomTheme.googleColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      appBarTitle: "Ajouter un trajet",
      showBackBotton: true,
      body: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              "Informations du trajet",
              style: PoppinsTextStyles.titleMediumRegular,
            ),
            SizedBox(height: 16.hp),
            
            ReusableTextField(
              controller: _fromController,
              hintText: "Ville de départ",
              suffixIcon: const Icon(Icons.location_on_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer la ville de départ';
                }
                return null;
              },
            ),
            
            ReusableTextField(
              controller: _toController,
              hintText: "Ville d'arrivée",
              suffixIcon: const Icon(Icons.location_on),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer la ville d\'arrivée';
                }
                return null;
              },
            ),
            




            // Bouton pour calculer l'itinéraire
            SizedBox(height: 8.hp),
            ElevatedButton.icon(
              onPressed: _calculatingPrice ? null : _calculateSuggestedPrice,
              icon: _calculatingPrice
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.calculate_outlined),
              label: Text(_calculatingPrice ? "Calcul en cours..." : "Calculer l'itinéraire et le prix"),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.appColor.withOpacity(0.2),
                foregroundColor: CustomTheme.appColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: CustomTheme.appColor),
                ),
              ),
            ),

            // Si l'itinéraire est calculé, afficher les infos
            if (_estimatedDistance != null && _estimatedDuration != null)
              Container(
                margin: EdgeInsets.only(top: 12.hp),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CustomTheme.appColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CustomTheme.appColor, width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: CustomTheme.appColor, size: 20),
                        SizedBox(width: 8.wp),
                        Text(
                          "Informations calculées",
                          style: PoppinsTextStyles.labelMediumRegular.copyWith(
                            fontWeight: FontWeight.w600,
                            color: CustomTheme.appColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.hp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.straighten, color: CustomTheme.appColor, size: 24),
                            SizedBox(height: 4.hp),
                            Text(
                              _estimatedDistance!,
                              style: PoppinsTextStyles.labelMediumRegular.copyWith(
                                fontWeight: FontWeight.w700,
                                color: CustomTheme.darkColor,
                              ),
                            ),
                            Text(
                              "Distance",
                              style: PoppinsTextStyles.bodySmallRegular.copyWith(
                                color: CustomTheme.darkColor.withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: CustomTheme.appColor.withOpacity(0.3),
                        ),
                        Column(
                          children: [
                            Icon(Icons.access_time, color: CustomTheme.appColor, size: 24),
                            SizedBox(height: 4.hp),
                            Text(
                              _estimatedDuration!,
                              style: PoppinsTextStyles.labelMediumRegular.copyWith(
                                fontWeight: FontWeight.w700,
                                color: CustomTheme.darkColor,
                              ),
                            ),
                            Text(
                              "Durée estimée",
                              style: PoppinsTextStyles.bodySmallRegular.copyWith(
                                color: CustomTheme.darkColor.withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            SizedBox(height: 16.hp),






            ReusableTextField(
              controller: _dateController,
              hintText: "Date de départ",
              readOnly: true,
              suffixIcon: const Icon(Icons.calendar_today),
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner la date';
                }
                return null;
              },
            ),
            
            ReusableTextField(
              controller: _timeController,
              hintText: "Heure de départ",
              readOnly: true,
              suffixIcon: const Icon(Icons.access_time),
              onTap: _selectTime,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner l\'heure';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16.hp),
            
            Text(
              "Informations du conducteur",
              style: PoppinsTextStyles.titleMediumRegular,
            ),
            SizedBox(height: 16.hp),
            
            ReusableTextField(
              controller: _driverNameController,
              hintText: "Nom du conducteur",
              suffixIcon: const Icon(Icons.person),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du conducteur';
                }
                return null;
              },
            ),
            
            ReusableTextField(
              controller: _driverPhoneController,
              hintText: "Téléphone du conducteur",
              textInputType: TextInputType.phone,
              suffixIcon: const Icon(Icons.phone),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le numéro de téléphone';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16.hp),
            
            Text(
              "Détails du véhicule",
              style: PoppinsTextStyles.titleMediumRegular,
            ),
            SizedBox(height: 16.hp),
            
            ReusableTextField(
              controller: _vehicleTypeController,
              hintText: "Type de véhicule",
              readOnly: true,
              suffixIcon: const Icon(Icons.keyboard_arrow_down),
              onTap: () {
                showPopUpMenuWithItems(
                  context: context,
                  title: "Sélectionner le type de véhicule",
                  dataItems: _vehicleTypes,
                  onItemPressed: (value) {
                    setState(() {
                      _vehicleTypeController.text = value;
                    });
                  },
                );
              },
            ),
            
            ReusableTextField(
              controller: _totalSeatsController,
              hintText: "Nombre total de places",
              textInputType: TextInputType.number,
              suffixIcon: const Icon(Icons.event_seat),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nombre de places';
                }
                final seats = int.tryParse(value);
                if (seats == null || seats < 1) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
            ),
            
            ReusableTextField(
              controller: _priceController,
              hintText: "Prix par place (TND)",
              textInputType: TextInputType.numberWithOptions(decimal: true),
              suffixIcon: const Icon(Icons.attach_money),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le prix';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'Veuillez entrer un prix valide';
                }
                return null;
              },
            ),
            
            SizedBox(height: 24.hp),
            
            CustomRoundedButtom(
              title: _isLoading ? "Ajout en cours..." : "Ajouter le trajet",
              isLoading: _isLoading,
              isDisabled: _isLoading,
              onPressed: _addTrip,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _totalSeatsController.dispose();
    _priceController.dispose();
    _vehicleTypeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}