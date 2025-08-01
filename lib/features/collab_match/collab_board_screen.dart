import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';
import '../../routes/app_routes.dart';

class CollabBoardScreen extends StatefulWidget {

  const CollabBoardScreen({super.key});
  @override
  State<CollabBoardScreen> createState() => _CollabBoardScreenState();
}

class _CollabBoardScreenState extends State<CollabBoardScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot> getCollabStream() {
    return FirebaseFirestore.instance
        .collection('collaborations')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _joinCollab(String collabId, String collabName, List members) async {
    if (currentUserId == null) return;

    if (!members.contains(currentUserId)) {
      await FirebaseFirestore.instance.collection('collaborations').doc(collabId).update({
        'members': FieldValue.arrayUnion([currentUserId])
      });
    }

    // Navigate to chat screen later
    Navigator.pushNamed(
      context,
      AppRoutes.chatScreen,
      arguments: {
        'collabId': collabId,
        'collabName': collabName, // pass from the caller or store locally
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/app_background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: const CustomNavBar(currentIndex: 2),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D4F48)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Collaboration Board",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D4F48),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getCollabStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final collabs = snapshot.data!.docs;

                      if (collabs.isEmpty) {
                        return const Center(child: Text("No collaborations yet."));
                      }

                      return ListView.builder(
                        itemCount: collabs.length,
                        itemBuilder: (context, index) {
                          final doc = collabs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'Untitled';
                          final description = data['description'] ?? '';
                          final members = List<String>.from(data['members'] ?? []);
                          final memberCount = members.length;

                          return _CollabCard(
                            title: title,
                            subtitle: "$description • $memberCount members",
                            onTap: () => _joinCollab(doc.id,title, members),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.group_add, color: Colors.white),
                    label: const Text(
                      "New Collab",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.newCollab);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D4F48),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollabCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CollabCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        leading: const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFE5F7EA),
          child: Icon(Icons.groups, color: Color(0xFF2D4F48)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF2D4F48),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2D4F48),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text("Open", style: TextStyle(color: Colors.white)),
        ),
        onTap: onTap,
      ),
    );
  }
}