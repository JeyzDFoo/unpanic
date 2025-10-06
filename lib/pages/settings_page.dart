import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/session_data_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade300, Colors.indigo.shade400],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Clear All Data Section
                Card(
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Export your data as CSV or clear all saved entries.',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _exportDataAsCSV(context),
                            icon: const Icon(Icons.file_download),
                            label: const Text('Export Data as CSV'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showClearDataDialog(context),
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Clear All Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // App Info Section
                Card(
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About Unpanic',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'A simple app to help manage panic attacks and anxiety.',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Version 1.0.0',
                          style: TextStyle(fontSize: 12, color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    // Get the provider reference before showing the dialog
    final provider = Provider.of<SessionDataProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'Are you sure you want to clear all saved data? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Use the provider reference we got before showing the dialog
                await provider.clearAllData();

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _exportDataAsCSV(BuildContext context) async {
    try {
      final provider = Provider.of<SessionDataProvider>(context, listen: false);

      // Load all entries including current session if needed
      await provider.loadSavedEntries();
      final entries = provider.allEntries; // Use allEntries to get everything

      if (entries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No data to export'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Generate CSV content
      String csvContent =
          'Session ID,Date,Time,Trigger Level,Breathing Cycles,Notes\n';

      for (final entry in entries) {
        final date = entry.timestamp.toLocal();
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final timeStr =
            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        final notes = entry.notes
            .replaceAll(',', ';')
            .replaceAll('\n', ' '); // Clean notes for CSV

        csvContent +=
            '${entry.sessionId},$dateStr,$timeStr,${entry.triggerLevel},${entry.breathingCycles},"$notes"\n';
      }

      // Get temporary directory to save the file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/unpanic_data.csv');
      await file.writeAsString(csvContent);

      // Share the CSV file
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Unpanic Data Export - ${entries.length} entries');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${entries.length} entries successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error exporting CSV: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
