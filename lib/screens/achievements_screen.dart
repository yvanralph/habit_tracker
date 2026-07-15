import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/streak_service.dart';
import '../utils/app_colors.dart';
import '../widgets/tab_app_bar.dart';

/// One badge milestone shown in the grid.
class _Badge {
  final String label;
  final int thresholdDays;
  final int number;
  final Color color;

  const _Badge({
    required this.label,
    required this.thresholdDays,
    required this.number,
    required this.color,
  });
}

// Roughly 30 days per month, kept simple on purpose.
const List<_Badge> _badges = [
  _Badge(label: '1 Day', thresholdDays: 1, number: 1, color: Color(0xFF4CAF50)),
  _Badge(label: '1 Week', thresholdDays: 7, number: 1, color: Color(0xFF2196F3)),
  _Badge(label: '1 Month', thresholdDays: 30, number: 1, color: Color(0xFF8D6E63)),
  _Badge(label: '2 Months', thresholdDays: 60, number: 2, color: Color(0xFF009688)),
  _Badge(label: '3 Months', thresholdDays: 90, number: 3, color: Color(0xFF9C27B0)),
  _Badge(label: '4 Months', thresholdDays: 120, number: 4, color: Color(0xFFE91E63)),
  _Badge(label: '5 Months', thresholdDays: 150, number: 5, color: Color(0xFFF44336)),
  _Badge(label: '6 Months', thresholdDays: 180, number: 6, color: Color(0xFFFF9800)),
  _Badge(label: '7 Months', thresholdDays: 210, number: 7, color: Color(0xFF673AB7)),
  _Badge(label: '8 Months', thresholdDays: 240, number: 8, color: Color(0xFF3F51B5)),
];

/// Achievements tab - screen 4 in the design.
/// Shows a grid of badges that unlock as the user's streak grows.
/// Once a badge is unlocked it stays unlocked, even after a relapse -
/// that's why this is based on the longest streak ever recorded,
/// not the current one.
class AchievementsScreen extends StatefulWidget {
  /// Called when the profile icon in the top bar is tapped, so the
  /// parent (MainNavigation) can switch to the Profile tab.
  final VoidCallback? onProfileTap;

  const AchievementsScreen({super.key, this.onProfileTap});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _streakService = StreakService();

  bool _isLoading = true;
  int _bestStreakDays = 0;

  @override
  void initState() {
    super.initState();
    _loadAchievementData();
  }

  Future<void> _loadAchievementData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    final snapshot = await _streakService.fetchUserDoc(uid);
    final data = snapshot.data();

    final streakStartTimestamp = data?['streakStartDate'] as Timestamp?;
    final currentDays = streakStartTimestamp == null
        ? 0
        : DateTime.now().difference(streakStartTimestamp.toDate()).inDays;
    final storedLongestDays = (data?['longestStreakDays'] as int?) ?? 0;

    if (!mounted) return;
    setState(() {
      // The current streak might already be the longest one, even if
      // that hasn't been saved to Firestore yet.
      _bestStreakDays =
          currentDays > storedLongestDays ? currentDays : storedLongestDays;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TabAppBar(
        titleWidget: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 22),
            SizedBox(width: 8),
            Text(
              'Achievements',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        onProfileTap: widget.onProfileTap,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Your Badges',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _badges.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final badge = _badges[index];
                        final unlocked = _bestStreakDays >= badge.thresholdDays;
                        return _badgeTile(badge, unlocked);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Keep going! More badges unlocked as you grow.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _badgeTile(_Badge badge, bool unlocked) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: unlocked ? badge.color : AppColors.fieldFill,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${badge.number}',
                  style: TextStyle(
                    color: unlocked ? Colors.white : AppColors.textGrey,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!unlocked)
              const Positioned(
                bottom: 0,
                right: 0,
                child: Icon(Icons.lock, size: 18, color: AppColors.textGrey),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          badge.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: unlocked ? Colors.black87 : AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}
