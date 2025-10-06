import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _loadSavedNotes();
    _notesController.addListener(() {
      setState(() {
        _hasText = _notesController.text.isNotEmpty;
      });
      _saveNotes();
    });
  }

  void _loadSavedNotes() async {
    final savedNotes = await _storage.getCurrentNotes();
    _notesController.text = savedNotes;
    setState(() {
      _hasText = savedNotes.isNotEmpty;
    });
  }

  void _saveNotes() async {
    await _storage.saveCurrentNotes(_notesController.text);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearNotes() {
    _notesController.clear();
    _focusNode.unfocus();
    _saveNotes(); // This will save the empty string
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside text field
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade300, Colors.amber.shade300],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).viewInsets.bottom -
                    MediaQuery.of(context).padding.top -
                    40,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Is there anything you want to remember?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _notesController,
                        focusNode: _focusNode,
                        minLines: 8,
                        maxLines: 8,
                        expands: false,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Write your thoughts, reminders, or anything you want to remember...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_hasText) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_notesController.text.length} characters',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _clearNotes,
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text('Clear'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Text(
                            'Tap above to start writing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
