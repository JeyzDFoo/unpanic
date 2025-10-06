import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _triggerValue = 1.0; // Default to baseline (calm)

  String _getTriggerText() {
    if (_triggerValue <= 2) return "Baseline";
    if (_triggerValue <= 4) return "Slightly Triggered";
    if (_triggerValue <= 6) return "Moderately Triggered";
    if (_triggerValue <= 8) return "Highly Triggered";
    return "Full Panic";
  }

  Color _getTriggerColor() {
    if (_triggerValue <= 2) return Colors.green;
    if (_triggerValue <= 4) return Colors.lightGreen;
    if (_triggerValue <= 6) return Colors.yellow;
    if (_triggerValue <= 8) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.shade300,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'How triggered are you?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              // Vertical Slider Container
              Container(
                height: 300,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: RotatedBox(
                  quarterTurns: 3, // Rotate to make it vertical
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _getTriggerColor(),
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: _getTriggerColor(),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 15,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 25,
                      ),
                      trackHeight: 8,
                    ),
                    child: Slider(
                      value: _triggerValue,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      onChanged: (value) {
                        setState(() {
                          _triggerValue = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Feeling indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _getTriggerColor().withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getTriggerText(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${_triggerValue.round()}/10',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
