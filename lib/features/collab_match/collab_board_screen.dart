import 'package:flutter/material.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import '../../routes/app_routes.dart';

class CollabBoardScreen extends StatelessWidget {
  const CollabBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;
    final List<Map<String, dynamic>> projects = [
      {
        "title": "Machine Learning Capstone",
        "description": "3 new messages • 5 members",
        "unread": true,
      },
      {
        "title": "UX Research Group",
        "description": "Next meeting on Friday • 3 members",
        "unread": false,
      },
      {
        "title": "Cybersecurity Audit Team",
        "description": "Proposal shared • 4 members",
        "unread": false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(localizer.translate("collab_board")),
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to NewCollabScreen
          Navigator.pushNamed(context, AppRoutes.newCollab);
        },
        icon: const Icon(Icons.group_add, color: Colors.green),
        label: Text(
          localizer.translate("new_collab"),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade800,
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 2, onTap: (index) {}),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0277BD), Color(0xFF03A9F4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = projects[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white.withOpacity(0.95),
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: item["unread"]
                      ? Colors.redAccent
                      : Colors.grey.shade300,
                  child: const Icon(Icons.group, color: Colors.white),
                ),
                title: Text(
                  item["title"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item["description"]),
                trailing: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to chat or detail screen
                    Navigator.pushNamed(context, AppRoutes.chatDetail);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(localizer.translate("open")),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
