import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isBreathing = false;
  String _breathingPhase = 'Tap to start';
  int _currentCycle = 0;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _loadSavedCycles();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8), // 4 seconds in, 4 seconds out
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.addListener(() {
      if (_isBreathing) {
        setState(() {
          if (_animationController.value < 0.5) {
            _breathingPhase = 'Breathe in...';
          } else {
            _breathingPhase = 'Breathe out...';
          }
        });
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentCycle++;
        });
        _saveCycles();
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed && _isBreathing) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadSavedCycles() async {
    final savedCycles = await _storage.getCurrentBreathing();
    setState(() {
      _currentCycle = savedCycles;
    });
  }

  void _saveCycles() async {
    await _storage.saveCurrentBreathing(_currentCycle);
  }

  void _toggleBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
      if (_isBreathing) {
        _currentCycle = 0;
        _breathingPhase = 'Breathe in...';
        _animationController.forward();
      } else {
        _breathingPhase = 'Tap to start';
        _animationController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade300, Colors.purple.shade300],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Breathing Exercise',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _breathingPhase,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            // Animated breathing circle
            GestureDetector(
              onTap: _toggleBreathing,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Container(
                    width: 150 * _scaleAnimation.value,
                    height: 150 * _scaleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        child: Icon(
                          _isBreathing ? Icons.pause : Icons.play_arrow,
                          size: 40,
                          color: Colors.blue.shade400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            if (_isBreathing) ...[
              Text(
                'Cycle: $_currentCycle',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                _isBreathing ? 'Tap circle to stop' : 'Tap circle to begin',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
