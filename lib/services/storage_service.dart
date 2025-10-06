import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/panic_entry.dart';

class StorageService {
  static const String _entriesKey = 'panic_entries';
  static const String _currentTriggerKey = 'current_trigger';
  static const String _currentBreathingKey = 'current_breathing';
  static const String _currentNotesKey = 'current_notes';

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Save a complete panic entry
  Future<void> savePanicEntry(PanicEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllEntries();
    entries.add(entry);

    final entriesJson = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_entriesKey, jsonEncode(entriesJson));
  }

  // Get all panic entries
  Future<List<PanicEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getString(_entriesKey);

    if (entriesString == null) return [];

    final entriesJson = jsonDecode(entriesString) as List<dynamic>;
    return entriesJson.map((json) => PanicEntry.fromJson(json)).toList();
  }

  // Save current trigger level
  Future<void> saveCurrentTrigger(double triggerLevel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_currentTriggerKey, triggerLevel);
  }

  // Get current trigger level
  Future<double> getCurrentTrigger() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_currentTriggerKey) ?? 1.0;
  }

  // Save current breathing cycles
  Future<void> saveCurrentBreathing(int cycles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentBreathingKey, cycles);
  }

  // Get current breathing cycles
  Future<int> getCurrentBreathing() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentBreathingKey) ?? 0;
  }

  // Save current notes
  Future<void> saveCurrentNotes(String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentNotesKey, notes);
  }

  // Get current notes
  Future<String> getCurrentNotes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentNotesKey) ?? '';
  }

  // Create and save a complete entry from current data
  Future<void> saveCurrentDataAsEntry() async {
    final triggerLevel = await getCurrentTrigger();
    final breathingCycles = await getCurrentBreathing();
    final notes = await getCurrentNotes();

    final entry = PanicEntry(
      timestamp: DateTime.now(),
      triggerLevel: triggerLevel,
      breathingCycles: breathingCycles,
      notes: notes,
    );

    await savePanicEntry(entry);

    // Reset current data after saving
    await resetCurrentData();
  }

  // Reset all current tracking data
  Future<void> resetCurrentData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_currentTriggerKey, 1.0);
    await prefs.setInt(_currentBreathingKey, 0);
    await prefs.setString(_currentNotesKey, '');
  }

  // Clear all data (for testing/reset purposes)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
    await resetCurrentData();
  }
}
