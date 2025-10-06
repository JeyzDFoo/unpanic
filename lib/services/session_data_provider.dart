import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import '../models/panic_entry.dart';

class SessionDataProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  // Current session data
  String? _currentSessionId;
  double _triggerLevel = 1.0;
  int _breathingCycles = 0;
  String _notes = '';
  List<PanicEntry> _savedEntries = [];

  // Getters
  String? get currentSessionId => _currentSessionId;
  double get triggerLevel => _triggerLevel;
  int get breathingCycles => _breathingCycles;
  String get notes => _notes;

  // Only return completed sessions (exclude current session)
  List<PanicEntry> get savedEntries => _savedEntries
      .where((entry) => entry.sessionId != _currentSessionId)
      .toList();

  // Get all entries including current session (for internal use)
  List<PanicEntry> get allEntries => _savedEntries;

  // Initialize provider with saved data
  Future<void> initialize() async {
    try {
      _triggerLevel = await _storage.getCurrentTrigger();
      _breathingCycles = await _storage.getCurrentBreathing();
      _notes = await _storage.getCurrentNotes();
      await loadSavedEntries();
      notifyListeners();
      print(
        'SessionDataProvider initialized - Trigger: $_triggerLevel, Breathing: $_breathingCycles, Notes: ${_notes.isNotEmpty ? "Yes" : "None"}',
      );
    } catch (e) {
      print('Error initializing SessionDataProvider: $e');
    }
  }

  // Update trigger level
  Future<void> updateTriggerLevel(double value) async {
    try {
      _triggerLevel = value;
      await _storage.saveCurrentTrigger(value);
      notifyListeners();
      print('Trigger updated to: $value');
    } catch (e) {
      print('Error updating trigger level: $e');
    }
  }

  // Update breathing cycles
  Future<void> updateBreathingCycles(int cycles) async {
    try {
      _breathingCycles = cycles;
      await _storage.saveCurrentBreathing(cycles);
      notifyListeners();
      print('Breathing cycles updated to: $cycles');
    } catch (e) {
      print('Error updating breathing cycles: $e');
    }
  }

  // Update notes
  Future<void> updateNotes(String notes) async {
    try {
      _notes = notes;
      await _storage.saveCurrentNotes(notes);
      notifyListeners();
      print('Notes updated');
    } catch (e) {
      print('Error updating notes: $e');
    }
  }

  // Save current session as permanent entry
  Future<void> saveCurrentSession() async {
    try {
      // Use existing session ID or create new one
      _currentSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();

      final entry = PanicEntry(
        sessionId: _currentSessionId!,
        timestamp: DateTime.now(),
        triggerLevel: _triggerLevel,
        breathingCycles: _breathingCycles,
        notes: _notes,
      );

      await _storage.saveOrUpdatePanicEntry(entry);
      await loadSavedEntries();
      notifyListeners();
      print('Session saved successfully with ID: $_currentSessionId');
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  // Reset current session data
  Future<void> resetCurrentSession() async {
    try {
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _triggerLevel = 1.0;
      _breathingCycles = 0;
      _notes = '';

      await _storage.resetCurrentData();
      notifyListeners();
      print('Session reset with new ID: $_currentSessionId');
    } catch (e) {
      print('Error resetting session: $e');
    }
  } // Load saved entries

  Future<void> loadSavedEntries() async {
    try {
      _savedEntries = await _storage.getAllEntries();
      notifyListeners();
    } catch (e) {
      print('Error loading saved entries: $e');
    }
  }

  // Auto-save current session (called when navigating between pages)
  // This saves/updates the permanent entry with current session ID
  Future<void> autoSaveSession() async {
    try {
      // Create session ID if this is a new session
      _currentSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();

      // Create or update entry with current session ID
      final entry = PanicEntry(
        sessionId: _currentSessionId!,
        timestamp: DateTime.now(),
        triggerLevel: _triggerLevel,
        breathingCycles: _breathingCycles,
        notes: _notes,
      );

      await _storage.saveOrUpdatePanicEntry(entry);
      await loadSavedEntries();
      notifyListeners();
      print('Session auto-saved/updated with ID: $_currentSessionId');
    } catch (e) {
      print('Error auto-saving session: $e');
    }
  }

  // Clear all data (for settings)
  Future<void> clearAllData() async {
    try {
      await _storage.clearAllData();
      await resetCurrentSession();
      _savedEntries.clear();
      // Reload entries from storage to ensure consistency
      await loadSavedEntries();
      notifyListeners();
      print('All data cleared');
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }
}
