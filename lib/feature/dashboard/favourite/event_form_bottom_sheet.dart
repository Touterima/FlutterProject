// widgets/event_form_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:ridesharing/common/constant/sdg_constants.dart';
import 'package:ridesharing/common/database/database_helper.dart';
import 'package:ridesharing/common/model/event_model.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/widget/custom_button.dart';

class EventFormBottomSheet extends StatefulWidget {
  final Event? event;
  final int currentUserId;
  final VoidCallback onEventSaved;

  const EventFormBottomSheet({
    super.key,
    this.event,
    required this.currentUserId,
    required this.onEventSaved,
  });

  @override
  State<EventFormBottomSheet> createState() => _EventFormBottomSheetState();
}

class _EventFormBottomSheetState extends State<EventFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _databaseHelper = DatabaseHelper();
  
  List<String> _selectedSdgs = [];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location;
      _dateController.text = widget.event!.date;
      _selectedSdgs = List.from(widget.event!.oddObjectives);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _toggleSdg(String sdg) {
    setState(() {
      if (_selectedSdgs.contains(sdg)) {
        _selectedSdgs.remove(sdg);
      } else {
        _selectedSdgs.add(sdg);
      }
    });
  }

  void _showSdgSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Select SDG Objectives',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SdgConstants.sdgObjectives.map((sdg) {
                      final isSelected = _selectedSdgs.contains(sdg);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(
                          sdg,
                          style: TextStyle(
                            color: isSelected 
                                ? Colors.white 
                                : SdgConstants.getColorForSdg(sdg),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: SdgConstants.getColorForSdg(sdg),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: SdgConstants.getColorForSdg(sdg),
                            width: 1,
                          ),
                        ),
                        onSelected: (bool selected) {
                          _toggleSdg(sdg);
                          Navigator.of(context).pop();
                          _showSdgSelectionDialog();
                        },
                        avatar: isSelected
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  SdgConstants.getIconForSdg(sdg),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: SdgConstants.getColorForSdg(sdg),
                                  ),
                                ),
                              )
                            : null,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomRoundedButtom(
                    title: 'Done',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final event = Event(
        id: widget.event?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        oddObjectives: _selectedSdgs,
        date: _dateController.text,
        creationAt: widget.event?.creationAt ?? DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
        userId: widget.event?.userId ?? widget.currentUserId,
      );

      try {
        if (widget.event == null) {
          await _databaseHelper.insertEvent(event);
        } else {
          await _databaseHelper.updateEvent(event, widget.currentUserId);
        }

        widget.onEventSaved();
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.event == null 
                ? 'Event created successfully' 
                : 'Event updated successfully'
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView( // ✅ Ajout du SingleChildScrollView principal
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event == null ? 'Create Event' : 'Edit Event',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // MULTI-SELECT SDG SECTION - AMÉLIORÉ
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SDG Objectives',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Selected SDGs Display avec hauteur limitée
                    if (_selectedSdgs.isNotEmpty) ...[
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 80, // ✅ Limite la hauteur
                        ),
                        child: SingleChildScrollView( // ✅ Scroll si trop d'éléments
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedSdgs.map((sdg) {
                              return Chip(
                                label: Text(
                                  _truncateSdgText(sdg), // ✅ Texte tronqué si trop long
                                  style: TextStyle(
                                    fontSize: 11, // ✅ Taille réduite
                                    color: SdgConstants.getColorForSdg(sdg),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: SdgConstants.getColorForSdg(sdg).withOpacity(0.1),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () => _toggleSdg(sdg),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: SdgConstants.getColorForSdg(sdg).withOpacity(0.3),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Select SDG Button
                    OutlinedButton(
                      onPressed: _showSdgSelectionDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CustomTheme.appColor,
                        side: BorderSide(color: CustomTheme.appColor),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _selectedSdgs.isEmpty 
                              ? 'Select SDG Objectives'
                              : 'Add More SDG Objectives',
                          ),
                        ],
                      ),
                    ),
                    
                    if (_selectedSdgs.isEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'No SDG objectives selected',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Event Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select event date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                CustomRoundedButtom(
                  title: widget.event == null ? 'Create Event' : 'Update Event',
                  onPressed: _saveEvent,
                ),
                const SizedBox(height: 10), // ✅ Espace supplémentaire en bas
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Méthode pour tronquer le texte des SDG si trop long
  String _truncateSdgText(String sdg) {
    const maxLength = 20;
    if (sdg.length > maxLength) {
      return '${sdg.substring(0, maxLength)}...';
    }
    return sdg;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}