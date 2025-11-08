
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/booking_model.dart';
import '../../providers/eden_data_provider.dart';
import 'booking_form_screen.dart';

class DatesScreen extends StatefulWidget {
  const DatesScreen({super.key});

  @override
  State<DatesScreen> createState() => _DatesScreenState();
}

class _DatesScreenState extends State<DatesScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Get all unique bookings from the dates
  Map<String, Booking> _getUniqueBookings(Map<String, Booking> dates) {
    Map<String, Booking> uniqueBookings = {};
    Set<String> processedBookings = {};
    
    dates.forEach((dateKey, booking) {
      String bookingKey = '${booking.name}_${booking.checkin}_${booking.checkout}';
      if (!processedBookings.contains(bookingKey)) {
        uniqueBookings[dateKey] = booking;
        processedBookings.add(bookingKey);
      }
    });
    
    return uniqueBookings;
  }

  // Check if a date is within a booking range
  bool _isDateInBookingRange(DateTime day, Booking booking) {
    final checkin = DateTime.parse(booking.checkin);
    final checkout = DateTime.parse(booking.checkout);
    return (day.isAfter(checkin.subtract(const Duration(days: 1))) && 
            day.isBefore(checkout.add(const Duration(days: 1))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dates'),
      ),
      body: Consumer<EdenDataProvider>(
        builder: (context, provider, child) {
          if (provider.edenData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              final dateKey = DateFormat('yyyy-MM-dd').format(selectedDay);
              final booking = provider.edenData!.dates[dateKey];

              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              if (booking != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingFormScreen(
                      date: selectedDay,
                      booking: booking,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingFormScreen(
                      date: selectedDay,
                    ),
                  ),
                );
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final dateKey = DateFormat('yyyy-MM-dd').format(day);
                final booking = provider.edenData!.dates[dateKey];
                
                if (booking != null) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
                return null;
              },
              selectedBuilder: (context, day, focusedDay) {
                final dateKey = DateFormat('yyyy-MM-dd').format(day);
                final booking = provider.edenData!.dates[dateKey];
                
                if (booking != null) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                return null;
              },
              todayBuilder: (context, day, focusedDay) {
                final dateKey = DateFormat('yyyy-MM-dd').format(day);
                final booking = provider.edenData!.dates[dateKey];
                
                if (booking != null) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBookingsList(context);
        },
        child: const Icon(Icons.list),
        tooltip: 'Show All Bookings',
      ),
    );
  }

  void _showBookingsList(BuildContext context) {
    final provider = Provider.of<EdenDataProvider>(context, listen: false);
    final uniqueBookings = _getUniqueBookings(provider.edenData!.dates);

    showModalBottomSheet(
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Bookings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: uniqueBookings.length,
                  itemBuilder: (context, index) {
                    final dateKey = uniqueBookings.keys.elementAt(index);
                    final booking = uniqueBookings[dateKey]!;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(booking.name),
                        subtitle: Text(
                          '${booking.checkin} to ${booking.checkout}\nContact: ${booking.contact}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingFormScreen(
                                date: DateTime.parse(booking.checkin),
                                booking: booking,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
