import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const CustomAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;
    return AppBar(
      title: Text("SynerSched", style: TextStyle(color: Color(0xFF2D4F48))),
      actions: actions,
      //backgroundColor: Color(0xFF0277BD),
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF2D4F48),
      // flexibleSpace: Container(
      //   decoration: const BoxDecoration(
      //     image: DecorationImage(
      //       image: AssetImage("assets/images/app_background.jpg"),
      //       fit: BoxFit.cover,
      //     ),
      //   ),
      // ),
      elevation: 0,
      // bottom: PreferredSize(
      //   preferredSize: const Size.fromHeight(40.0), // Adjust height as needed
      //   child: Container(
      //     alignment: Alignment.centerLeft, // Align welcome text to the left
      //     padding: EdgeInsets.symmetric(horizontal: 75.0), // Add padding
      //     child: Text(
      //       '${localizer.translate("welcome")}, Siva 👋',
      //       style: TextStyle(color: Colors.white),
      //     ),
      //   ),
      // ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
