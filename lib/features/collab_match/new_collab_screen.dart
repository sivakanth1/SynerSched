import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import '../../shared/custom_nav_bar.dart';

class NewCollabScreen extends StatelessWidget {
  const NewCollabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Start New Collaboration"),
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 2, onTap: (index) {}),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: localizer.translate("collab_title"),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: localizer.translate("collab_description"),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Save project
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: Text(localizer.translate("create")),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
