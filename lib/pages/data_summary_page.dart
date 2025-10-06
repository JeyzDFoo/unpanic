import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/session_data_provider.dart';
import '../models/panic_entry.dart';

class DataSummaryPage extends StatefulWidget {
  final VoidCallback? onRestart;

  const DataSummaryPage({super.key, this.onRestart});

  @override
  State<DataSummaryPage> createState() => _DataSummaryPageState();
}

class _DataSummaryPageState extends State<DataSummaryPage> {
  double _currentTrigger = 1.0;
  int _currentBreathing = 0;
  String _currentNotes = '';
  List<PanicEntry> _savedEntries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentData();
      _loadSavedEntries();
    });
  }

  void _loadCurrentData() async {
    try {
      final provider = Provider.of<SessionDataProvider>(context, listen: false);

      print(
        'Loading current data - Trigger: ${provider.triggerLevel}, Breathing: ${provider.breathingCycles}, Notes: ${provider.notes.isNotEmpty ? "Yes" : "None"}',
      ); // Debug

      setState(() {
        _currentTrigger = provider.triggerLevel;
        _currentBreathing = provider.breathingCycles;
        _currentNotes = provider.notes;
      });
    } catch (e) {
      print('Error loading current data: $e');
    }
  }

  void _loadSavedEntries() async {
    final provider = Provider.of<SessionDataProvider>(context, listen: false);
    await provider.loadSavedEntries();
    setState(() {
      _savedEntries = provider.savedEntries;
    });
  }

  void _restartSession() async {
    final provider = Provider.of<SessionDataProvider>(context, listen: false);
    // Save current session first
    await provider.saveCurrentSession();
    // Reset for new session
    await provider.resetCurrentSession();
    _loadSavedEntries();
    _loadCurrentData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session saved and restarted!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to first page
      widget.onRestart?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Refresh data each time the widget is built (when user navigates to this page)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentData();
    });

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
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Data Summary',
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

              // Restart Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _restartSession,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
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
