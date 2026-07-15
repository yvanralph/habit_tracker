import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// A simple app bar shared by the main tab screens (Home, Achievements,
/// Craving, Profile), so they all use the same background color as the
/// bottom nav bar. Pass either [title] for plain text, or [titleWidget]
/// for something more custom (like an icon next to the text).
///
/// Only pass [onProfileTap] on screens that should show the profile
/// shortcut - leave it null (as Profile itself does) to hide it.
class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String? title;
  final Widget? titleWidget;
  final VoidCallback? onProfileTap;

  const TabAppBar({
    super.key,
    this.leading,
    this.title,
    this.titleWidget,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.barBackground,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: leading == null ? null : Center(child: leading),
      title: titleWidget ??
          (title == null
              ? null
              : Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
      actions: [
        if (onProfileTap != null)
          IconButton(
            onPressed: onProfileTap,
            icon: const Icon(Icons.account_circle_outlined),
          ),
      ],
    );
  }
}
