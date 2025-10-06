import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/panic_entry.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final StorageService _storage = StorageService();
  double _currentTrigger = 1.0;
  int _currentBreathing = 0;
  String _currentNotes = '';
  List<PanicEntry> _savedEntries = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
    _loadSavedEntries();
  }

  void _loadCurrentData() async {
    final trigger = await _storage.getCurrentTrigger();
    final breathing = await _storage.getCurrentBreathing();
    final notes = await _storage.getCurrentNotes();

    setState(() {
      _currentTrigger = trigger;
      _currentBreathing = breathing;
      _currentNotes = notes;
    });
  }

  void _loadSavedEntries() async {
    final entries = await _storage.getAllEntries();
    setState(() {
      _savedEntries = entries;
    });
  }

  void _saveCurrentEntry() async {
    await _storage.saveCurrentDataAsEntry();
    _loadSavedEntries();
    _loadCurrentData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade300, Colors.indigo.shade300],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(Icons.analytics, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Your Data',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Current Session Data
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Session',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Trigger Level: ${_currentTrigger.round()}/10',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Breathing Cycles: $_currentBreathing',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Notes: ${_currentNotes.isNotEmpty ? "Added" : "None"}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Save Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveCurrentEntry,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Current Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Saved Entries
              const Text(
                'Saved Entries',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: _savedEntries.isEmpty
                    ? const Center(
                        child: Text(
                          'No saved entries yet.\nSave your current session to get started!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _savedEntries.length,
                        itemBuilder: (context, index) {
                          final entry =
                              _savedEntries[_savedEntries.length - 1 - index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} at ${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Trigger: ${entry.triggerLevel.round()}/10 | Breathing: ${entry.breathingCycles} cycles',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                if (entry.notes.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    'Notes: ${entry.notes}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
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
