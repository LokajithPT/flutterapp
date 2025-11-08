import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/eden_data_provider.dart';
import '../simple_images_screen.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  DateTime? selectedDate;
  final Map<String, TextEditingController> _controllers = {
    'Breakfast': TextEditingController(),
    'Lunch': TextEditingController(),
    'Dinner': TextEditingController(),
    'Snacks': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadSelectedDate();
  }

  Future<void> _loadSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('kitchen_selected_date');
    if (savedDate != null) {
      setState(() {
        selectedDate = DateTime.parse(savedDate);
      });
      _loadNotesForDate();
    }
  }

  Future<void> _saveSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedDate != null) {
      await prefs.setString('kitchen_selected_date', DateFormat('yyyy-MM-dd').format(selectedDate!));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _saveSelectedDate();
      _loadNotesForDate();
    }
  }

  void _loadNotesForDate() {
    if (selectedDate == null) return;
    
    final edenProvider = Provider.of<EdenDataProvider>(context, listen: false);
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate!);
    
    // Load existing notes for each meal type
    final breakfastNotes = edenProvider.getDailyKitchenOrders(dateKey, 'Breakfast');
    final lunchNotes = edenProvider.getDailyKitchenOrders(dateKey, 'Lunch');
    final dinnerNotes = edenProvider.getDailyKitchenOrders(dateKey, 'Dinner');
    final snacksNotes = edenProvider.getDailyKitchenOrders(dateKey, 'Snacks');
    
    setState(() {
      _controllers['Breakfast']!.text = breakfastNotes.isNotEmpty ? breakfastNotes.first : '';
      _controllers['Lunch']!.text = lunchNotes.isNotEmpty ? lunchNotes.first : '';
      _controllers['Dinner']!.text = dinnerNotes.isNotEmpty ? dinnerNotes.first : '';
      _controllers['Snacks']!.text = snacksNotes.isNotEmpty ? snacksNotes.first : '';
    });
  }

  void _saveNotes() async {
    if (selectedDate == null) return;
    
    final edenProvider = Provider.of<EdenDataProvider>(context, listen: false);
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate!);
    
    // Save notes for each meal type
    for (final mealType in _controllers.keys) {
      final text = _controllers[mealType]!.text.trim();
      final notes = text.isNotEmpty ? [text] : <String>[];
      await edenProvider.addKitchenItems(mealType, notes, dateKey);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notes saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _openNotepad(String mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotepadScreen(
          mealType: mealType,
          controller: _controllers[mealType]!,
          onSave: () {
            _saveNotes();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _openImages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleImagesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectedDate != null
            ? Text(
                'Kitchen - ${DateFormat('MMM dd, yyyy').format(selectedDate!)}',
                style: const TextStyle(fontSize: 16),
              )
            : const Text('Kitchen Orders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF1a1a1a),
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date selection
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                              : 'No date selected',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Choose Date'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Meal options
              Expanded(
                child: selectedDate == null
                    ? const Center(
                        child: Text(
                          'Please select a date first',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildMealCard('Breakfast', Icons.breakfast_dining),
                          _buildMealCard('Lunch', Icons.lunch_dining),
                          _buildMealCard('Dinner', Icons.dinner_dining),
                          _buildMealCard('Snacks', Icons.tapas),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedDate != null
          ? Stack(
              children: [
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton.extended(
                    onPressed: _saveNotes,
                    backgroundColor: Colors.green[600],
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Save All', style: TextStyle(color: Colors.white)),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () => _openImages(context),
                    backgroundColor: Colors.purple[600],
                    child: const Icon(Icons.photo_library, color: Colors.white, size: 20),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildMealCard(String mealType, IconData icon) {
    final controller = _controllers[mealType]!;
    final hasContent = controller.text.trim().isNotEmpty;
    
    return Card(
      color: Colors.grey[900],
      child: InkWell(
        onTap: () => _openNotepad(mealType),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.orange[600], size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mealType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (hasContent)
                    Icon(Icons.check_circle, color: Colors.green[400], size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hasContent 
                    ? controller.text.trim().length > 50 
                        ? '${controller.text.trim().substring(0, 50)}...'
                        : controller.text.trim()
                    : 'Tap to add notes',
                style: TextStyle(
                  fontSize: 14,
                  color: hasContent ? Colors.white70 : Colors.grey[400],
                  fontStyle: hasContent ? FontStyle.normal : FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotepadScreen extends StatefulWidget {
  final String mealType;
  final TextEditingController controller;
  final VoidCallback onSave;

  const NotepadScreen({
    super.key,
    required this.mealType,
    required this.controller,
    required this.onSave,
  });

  @override
  State<NotepadScreen> createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mealType} Notes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: widget.onSave,
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: 'Save',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF1a1a1a),
              Colors.black,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: widget.controller,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your notes here...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    autofocus: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onSave,
                icon: const Icon(Icons.save),
                label: const Text('Save Notes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}