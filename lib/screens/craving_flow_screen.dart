import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Walks the user through the full craving-support exercise: a
/// breathing exercise, two reflection questions, then a closing quote.
/// Screens 6-9 in the design.
class CravingFlowScreen extends StatefulWidget {
  /// Called once the user finishes (or dismisses) the exercise, so the
  /// parent can switch back to the Home tab.
  final VoidCallback? onGoHome;

  const CravingFlowScreen({super.key, this.onGoHome});

  @override
  State<CravingFlowScreen> createState() => _CravingFlowScreenState();
}

class _CravingFlowScreenState extends State<CravingFlowScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _titles = [
    'Take a Deep Breath',
    'Reflection',
    'Reflection',
    'Keep Going',
  ];

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleBack() {
    if (_currentPage == 0) {
      Navigator.of(context).pop();
    } else {
      _goToPage(_currentPage - 1);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.barBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        title: Text(
          _titles[_currentPage],
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          // Steps only move forward/back through the buttons below,
          // not by swiping, so the flow can't be skipped by accident.
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _BreathingStep(onContinue: () => _goToPage(1)),
            _ReflectionStep(
              stepIndex: 1,
              icon: Icons.psychology_outlined,
              question:
                  "You know this won't satisfy you, what should you be "
                  "doing to get there?",
              onNext: () => _goToPage(2),
            ),
            _ReflectionStep(
              stepIndex: 2,
              icon: Icons.favorite_outline,
              question:
                  'How will my future self feel if I stay strong right now?',
              onNext: () => _goToPage(3),
            ),
            _QuoteStep(onGoHome: widget.onGoHome),
          ],
        ),
      ),
    );
  }
}

/// Small row of dots showing progress through the 3-step exercise
/// (breathing, reflection 1, reflection 2). Not shown on the closing
/// quote step.
Widget _stepDots(int activeIndex) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(3, (index) {
      final isActive = index == activeIndex;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppColors.primaryGreen : AppColors.fieldFill,
        ),
      );
    }),
  );
}

/// One phase of the box-breathing pattern (4 seconds in, hold, out, hold).
class _BreathingPhase {
  final String label;
  final String caption;
  final int seconds;
  final double scale;

  const _BreathingPhase({
    required this.label,
    required this.caption,
    required this.seconds,
    required this.scale,
  });
}

const List<_BreathingPhase> _breathingPhases = [
  _BreathingPhase(label: 'Inhale', caption: 'Breathe in...', seconds: 4, scale: 1.3),
  _BreathingPhase(label: 'Hold', caption: 'Hold...', seconds: 4, scale: 1.3),
  _BreathingPhase(label: 'Exhale', caption: 'Breathe out...', seconds: 4, scale: 0.85),
  _BreathingPhase(label: 'Hold', caption: 'Hold...', seconds: 4, scale: 0.85),
];

/// Step 1 - a simple guided box-breathing exercise. The circle grows
/// while breathing in, holds, then shrinks while breathing out.
class _BreathingStep extends StatefulWidget {
  final VoidCallback onContinue;

  const _BreathingStep({required this.onContinue});

  @override
  State<_BreathingStep> createState() => _BreathingStepState();
}

class _BreathingStepState extends State<_BreathingStep> {
  Timer? _timer;
  int _phaseIndex = 0;
  int _secondsLeft = _breathingPhases[0].seconds;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_isPaused || !mounted) return;
    setState(() {
      if (_secondsLeft > 1) {
        _secondsLeft--;
      } else {
        _phaseIndex = (_phaseIndex + 1) % _breathingPhases.length;
        _secondsLeft = _breathingPhases[_phaseIndex].seconds;
      }
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = _breathingPhases[_phaseIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            width: 160 * phase.scale,
            height: 160 * phase.scale,
            decoration: const BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    phase.label,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$_secondsLeft',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Seconds',
                    style: TextStyle(color: AppColors.primaryGreen, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            phase.caption,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Follow the circle. You've got this.",
            style: TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),
          IconButton(
            onPressed: _togglePause,
            iconSize: 40,
            icon: Icon(
              _isPaused ? Icons.play_circle_fill : Icons.pause_circle_filled,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          _stepDots(0),
          const SizedBox(height: 24),
          TextButton(
            onPressed: widget.onContinue,
            child: const Text(
              "I'm ready, continue",
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Steps 2 and 3 - a reflection question to think through before
/// moving on. There's nothing to type - just a moment to consider it.
class _ReflectionStep extends StatelessWidget {
  /// 1 for the first reflection question, 2 for the second - used for
  /// the progress bar and dots.
  final int stepIndex;
  final IconData icon;
  final String question;
  final VoidCallback onNext;

  const _ReflectionStep({
    required this.stepIndex,
    required this.icon,
    required this.question,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (stepIndex + 1) / 3,
              minHeight: 6,
              backgroundColor: AppColors.fieldFill,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Step ${stepIndex + 1} of 3',
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 28),
          Icon(icon, size: 48, color: AppColors.primaryGreen),
          const SizedBox(height: 12),
          const Text(
            'Think About This',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            question,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _stepDots(stepIndex),
        ],
      ),
    );
  }
}

/// Step 4 - a closing quote to send the user off feeling encouraged.
class _QuoteStep extends StatelessWidget {
  final VoidCallback? onGoHome;

  const _QuoteStep({this.onGoHome});

  void _finish(BuildContext context) {
    // Pop the whole craving flow off the stack, then let the parent
    // (MainNavigation) switch back to the Home tab.
    Navigator.of(context).popUntil((route) => route.isFirst);
    onGoHome?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.format_quote, size: 48, color: AppColors.primaryGreen),
          const SizedBox(height: 16),
          const Text(
            'Everything you have and are is because you accepted.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.favorite, color: AppColors.primaryGreen, size: 28),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _finish(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "I'm Stronger Than This",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
