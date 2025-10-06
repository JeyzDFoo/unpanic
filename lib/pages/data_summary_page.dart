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
  @override
  void initState() {
    super.initState();
    // No need to load data into local variables, we'll read from provider directly
  }

  void _restartSession() async {
    final provider = Provider.of<SessionDataProvider>(context, listen: false);
    // Save current session first
    await provider.saveCurrentSession();
    // Reset for new session
    await provider.resetCurrentSession();
    // No need to manually load data, Consumer will handle updates

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
    return Consumer<SessionDataProvider>(
      builder: (context, provider, child) {
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
                      'History',
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
                          'Trigger Level: ${provider.triggerLevel.round()}/10',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Breathing Cycles: ${provider.breathingCycles}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Notes: ${provider.notes.isNotEmpty ? provider.notes : "None"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
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
                    child: provider.savedEntries.isEmpty
                        ? const Center(
                            child: Text(
                              'No saved entries yet.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: provider.savedEntries.length,
                            itemBuilder: (context, index) {
                              final entry =
                                  provider.savedEntries[provider
                                          .savedEntries
                                          .length -
                                      1 -
                                      index];
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
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
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
      },
    );
  }
}
