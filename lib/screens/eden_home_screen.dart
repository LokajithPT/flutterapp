
import 'package:flutter/material.dart';
import 'dates/dates_screen.dart';
import 'rooms/rooms_screen.dart';

class EdenHomeScreen extends StatelessWidget {
  final int edenId;

  const EdenHomeScreen({super.key, required this.edenId});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getEdenTitle(edenId)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSexyButton(
                context,
                'Dates',
                Icons.calendar_today,
                Colors.blue[600]!,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DatesScreen(edenId: edenId)),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildSexyButton(
                context,
                'Rooms',
                Icons.bed,
                Colors.green[600]!,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RoomsScreen(edenId: edenId)),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSexyButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 200,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getEdenTitle(int edenId) {
    switch (edenId) {
      case 1:
        return 'EDEN 1';
      case 2:
        return 'EDEN 2';
      case 3:
        return 'EDEN 3';
      case 4:
        return 'EDEN 4';
      case 6:
        return 'EDEN 6';
      case 7:
        return 'EDEN 7';
      case 8:
        return 'Kunnur';
      case 9:
        return 'Kodanadu';
      case 10:
        return 'Others';
      default:
        return 'EDEN $edenId';
    }
  }
}
