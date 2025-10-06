import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/slider_page.dart';
import 'pages/breathing_exercise_page.dart';
import 'pages/notes_page.dart'; // NotesPage is in this file
import 'pages/data_summary_page.dart';
import 'pages/settings_page.dart';
import 'services/session_data_provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SessionDataProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'Unpanic',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const PageViewDemo(),
      ),
    );
  }
}

class PageViewDemo extends StatefulWidget {
  const PageViewDemo({super.key});

  @override
  State<PageViewDemo> createState() => _PageViewDemoState();
}

class _PageViewDemoState extends State<PageViewDemo> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the provider when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SessionDataProvider>(context, listen: false);
      provider.initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _autoSaveSession() async {
    try {
      final provider = Provider.of<SessionDataProvider>(context, listen: false);
      await provider.autoSaveSession();
      print('Session auto-saved successfully'); // Debug output
    } catch (e) {
      print('Error auto-saving session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Unpanic', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
                _autoSaveSession();
              },
              children: [
                const SliderPage(),
                const BreathingExercisePage(),
                const NotesPage(),
                DataSummaryPage(
                  onRestart: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
          ),
          _buildPageIndicator(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index ? Colors.blue : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 0
                ? () {
                    _autoSaveSession();
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            child: const Text('Previous'),
          ),
          ElevatedButton(
            onPressed: _currentPage < 3
                ? () {
                    _autoSaveSession();
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : () async {
                    // Save current session before restart
                    final provider = Provider.of<SessionDataProvider>(
                      context,
                      listen: false,
                    );
                    await provider.saveCurrentSession();
                    // Reset for new session
                    await provider.resetCurrentSession();
                    // Restart - go back to first page
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
            child: Text(_currentPage < 3 ? 'Next' : 'Restart'),
          ),
        ],
      ),
    );
  }
}
