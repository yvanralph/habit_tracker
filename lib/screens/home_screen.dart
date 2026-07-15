import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/streak_service.dart';
import '../utils/app_colors.dart';
import '../widgets/tab_app_bar.dart';

/// Home / tracker screen - screen 3 in the design.
/// Shows how long the user has gone without their habit, their
/// current vs. longest streak, and lets them log a relapse.
///
/// The streak start time is fetched from Firestore once, then all the
/// day/hour/minute math is calculated locally using the device's own
/// clock - the UI doesn't wait on Firestore to refresh the numbers.
class HomeScreen extends StatefulWidget {
  /// Called when the profile icon in the top bar is tapped, so the
  /// parent (MainNavigation) can switch to the Profile tab.
  final VoidCallback? onProfileTap;

  const HomeScreen({super.key, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _streakService = StreakService();
  Timer? _ticker;

  bool _isLoading = true;
  bool _hasError = false;
  DateTime _streakStart = DateTime.now();
  int _longestStreakDays = 0;

  @override
  void initState() {
    super.initState();
    _loadStreakData();

    // Everything is calculated locally using the device's clock, so we
    // just need to re-render every so often to keep it moving.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadStreakData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final snapshot = await _streakService.fetchUserDoc(uid);
      final data = snapshot.data();
      final streakStartTimestamp = data?['streakStartDate'] as Timestamp?;

      // If the document exists but has no streakStartDate for some
      // reason, that's unexpected - treat it as an error instead of
      // silently starting a fresh streak from "now".
      if (data != null && streakStartTimestamp == null) {
        throw Exception('No streakStartDate found on user document');
      }

      if (!mounted) return;
      setState(() {
        _streakStart = streakStartTimestamp?.toDate() ?? DateTime.now();
        _longestStreakDays = (data?['longestStreakDays'] as int?) ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      // Something went wrong reading Firestore (no internet, a
      // permissions rule blocking the read, etc). Show an error
      // instead of quietly resetting the tracker to zero.
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  int get _currentStreakDays =>
      DateTime.now().difference(_streakStart).inDays;

  Future<void> _confirmRelapse() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final currentDays = _currentStreakDays;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log a relapse?'),
        content: const Text(
          'This resets your current streak and starts counting again '
          'from now. Your longest streak record stays saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'I did it again',
              style: TextStyle(color: AppColors.warningRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final newStart = DateTime.now();
    final newLongest =
        currentDays > _longestStreakDays ? currentDays : _longestStreakDays;

    // Update the screen immediately using the local clock - no need to
    // wait on a round-trip to Firestore for the tracker to reset.
    setState(() {
      _streakStart = newStart;
      _longestStreakDays = newLongest;
    });

    await _streakService.updateStreak(
      uid: uid,
      streakStart: newStart,
      longestStreakDays: newLongest,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: TabAppBar(onProfileTap: widget.onProfileTap),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: TabAppBar(onProfileTap: widget.onProfileTap),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: AppColors.textGrey),
                const SizedBox(height: 12),
                const Text(
                  "Couldn't load your streak. Check your connection and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadStreakData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final elapsed = DateTime.now().difference(_streakStart);
    final days = elapsed.inDays;
    final hours = elapsed.inHours % 24;
    final minutes = elapsed.inMinutes % 60;
    final longestDays = days > _longestStreakDays ? days : _longestStreakDays;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TabAppBar(
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.eco, color: Colors.white, size: 24),
        ),
        onProfileTap: widget.onProfileTap,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStreakCard(days, hours, minutes),
              const SizedBox(height: 16),
              _buildStatsRow(days, longestDays),
              const SizedBox(height: 24),
              _buildRelapseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(int days, int hours, int minutes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "You've been",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            '$days',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Days Clean',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$hours Hours $minutes Minutes',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int currentDays, int longestDays) {
    return Row(
      children: [
        Expanded(
          child: _statCard(label: 'Current Streak', value: currentDays),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: 'Longest Streak',
            value: longestDays,
            icon: Icons.emoji_events,
            iconColor: Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required int value,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(icon, color: iconColor ?? AppColors.textGrey, size: 16),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text('Days', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRelapseButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _confirmRelapse,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warningRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'I did it again',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
