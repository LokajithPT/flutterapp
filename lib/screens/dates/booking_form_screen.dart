import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/booking_model.dart';
import '../../providers/eden_data_provider.dart';

class BookingFormScreen extends StatefulWidget {
  final DateTime date;
  final Booking? booking;

  const BookingFormScreen({super.key, required this.date, this.booking});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  DateTime? _checkinDate;
  DateTime? _checkoutDate;

  bool get _isViewing => widget.booking != null;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _checkinDate = widget.date;
    _loadFormData();

    if (_isViewing) {
      _nameController.text = widget.booking!.name;
      _contactController.text = widget.booking!.contact;
      _checkinDate = DateTime.parse(widget.booking!.checkin);
      _checkoutDate = DateTime.parse(widget.booking!.checkout);
    }
  }

  Future<void> _loadFormData() async {
    if (!_isViewing) {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('booking_form_name');
      final savedContact = prefs.getString('booking_form_contact');
      
      if (savedName != null) _nameController.text = savedName;
      if (savedContact != null) _contactController.text = savedContact;
    }
  }

  Future<void> _saveFormData() async {
    if (!_isViewing) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('booking_form_name', _nameController.text);
      await prefs.setString('booking_form_contact', _contactController.text);
    }
  }

  @override
  void dispose() {
    _saveFormData();
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Booking' : (_isViewing ? 'View Booking' : 'New Booking')),
        actions: [
          if (_isViewing && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset values to original booking
                  _nameController.text = widget.booking!.name;
                  _contactController.text = widget.booking!.contact;
                  _checkinDate = DateTime.parse(widget.booking!.checkin);
                  _checkoutDate = DateTime.parse(widget.booking!.checkout);
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                readOnly: _isViewing && !_isEditing,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactController,
                readOnly: _isViewing && !_isEditing,
                decoration: const InputDecoration(labelText: 'Contact'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Check-in: ${DateFormat('yyyy-MM-dd').format(_checkinDate!)}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: (_isViewing && !_isEditing)
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _checkinDate!,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() {
                                _checkinDate = picked;
                              });
                            }
                          },
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Check-out: ${_checkoutDate != null ? DateFormat('yyyy-MM-dd').format(_checkoutDate!) : 'Select Date'}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: (_isViewing && !_isEditing)
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _checkoutDate ?? _checkinDate!,
                              firstDate: _checkinDate!,
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() {
                                _checkoutDate = picked;
                              });
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_isViewing && !_isEditing) {
                    Navigator.pop(context);
                    return;
                  }

                  if (_formKey.currentState!.validate() && _checkoutDate != null) {
                    final booking = Booking(
                      name: _nameController.text,
                      contact: _contactController.text,
                      checkin: DateFormat('yyyy-MM-dd').format(_checkinDate!),
                      checkout: DateFormat('yyyy-MM-dd').format(_checkoutDate!),
                    );

                    if (_isEditing) {
                      // Update existing booking - remove old dates first
                      final oldBooking = widget.booking!;
                      for (var d = DateTime.parse(oldBooking.checkin);
                          d.isBefore(DateTime.parse(oldBooking.checkout));
                          d = d.add(const Duration(days: 1))) {
                        final dateKey = DateFormat('yyyy-MM-dd').format(d);
                        Provider.of<EdenDataProvider>(context, listen: false)
                            .removeBooking(dateKey);
                      }
                    }

                    // Add booking for all dates in the range
                    for (var d = _checkinDate!;
                        d.isBefore(_checkoutDate!);
                        d = d.add(const Duration(days: 1))) {
                      final dateKey = DateFormat('yyyy-MM-dd').format(d);
                      Provider.of<EdenDataProvider>(context, listen: false)
                          .addBooking(dateKey, booking);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(_isEditing ? 'Update' : (_isViewing ? 'Close' : 'Done')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}