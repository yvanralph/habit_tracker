import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/tab_app_bar.dart';
import 'craving_flow_screen.dart';

/// Craving support intro - screen 5 in the design. This is what the
/// Craving tab shows by default. Tapping "Let's Begin" starts the
/// breathing + reflection exercise (screens 6-9).
class CravingScreen extends StatelessWidget {
  /// Called when the profile icon in the top bar is tapped, so the
  /// parent (MainNavigation) can switch to the Profile tab.
  final VoidCallback? onProfileTap;

  /// Called once the whole craving exercise is finished, so the
  /// parent can switch back to the Home tab.
  final VoidCallback? onGoHome;

  const CravingScreen({super.key, this.onProfileTap, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TabAppBar(title: 'Craving Support', onProfileTap: onProfileTap),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.primaryGreen,
                  size: 72,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Feeling the urge?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "You're not alone. Take a moment for yourself. "
                "You can get through this.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 15),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CravingFlowScreen(onGoHome: onGoHome),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Let's Begin",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
