import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../routes/app_routes.dart';
import '../../shared/stream_helper.dart';

class CollabBoardScreen extends StatefulWidget {
  final StreamChatClient streamClient;
  const CollabBoardScreen({super.key, required this.streamClient});

  @override
  State<CollabBoardScreen> createState() => _CollabBoardScreenState();
}

class _CollabBoardScreenState extends State<CollabBoardScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = 'Recent';

  Stream<QuerySnapshot> getCollabStream() {
    return FirebaseFirestore.instance
        .collection('collaborations')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _joinCollab(String collabId, String collabName, List members) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final alreadyMember = members.contains(currentUserId);

    final shouldJoin = alreadyMember
        ? true
        : await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Join $collabName?"),
        content: const Text("Do you want to join this collaboration and enter the chat?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Join")),
        ],
      ),
    ) ??
        false;

    if (!shouldJoin) return;

    try {
      await StreamConnectionHelper.ensureConnected(widget.streamClient);

      if (!alreadyMember) {
        await FirebaseFirestore.instance.collection('collaborations').doc(collabId).update({
          'members': FieldValue.arrayUnion([currentUserId])
        });
      }

      final channel = widget.streamClient.channel('messaging', id: collabId);
      await channel.watch();

      final streamMembers = await channel.queryMembers();
      final streamMemberIds = streamMembers.members.map((m) => m.userId).toList();

      if (!streamMemberIds.contains(currentUserId)) {
        await channel.addMembers([currentUserId]);
      }

      Navigator.pushNamed(
        context,
        AppRoutes.chatScreen,
        arguments: {
          'collabId': collabId,
          'collabName': collabName,
          'streamClient': widget.streamClient,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining collaboration: $e')),
      );
    }
  }

  List<DocumentSnapshot> _applyFilters(List<DocumentSnapshot> docs) {
    String query = _searchController.text.toLowerCase();

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = data['title']?.toString().toLowerCase() ?? '';
      final description = data['description']?.toString().toLowerCase() ?? '';
      final tags = (data['tags'] ?? []) as List<dynamic>;

      final matchesQuery = query.isEmpty ||
          title.contains(query) ||
          description.contains(query) ||
          tags.any((tag) => tag.toString().toLowerCase().contains(query));

      if (!matchesQuery) return false;

      // Optional sort filter — you can expand this with your data model
      if (_sortOption == 'Computer Science') {
        return data['department'] == 'Computer Science';
      } else if (_sortOption == 'Machine Learning') {
        return (data['skills'] ?? []).contains('Machine Learning');
      }

      return true;
    }).toList();
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
        // bottomNavigationBar: const CustomNavBar(currentIndex: 2),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Collaboration Board",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D4F48)),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // 🔍 Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Search by title, description or tag",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // 📦 Sort dropdown
                Row(
                  children: [
                    const Text("Sort by: ", style: TextStyle(color: Colors.black87)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _sortOption,
                      items: [
                        'Recent',
                        'Computer Science',
                        'Machine Learning',
                      ].map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                      onChanged: (value) {
                        setState(() => _sortOption = value!);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getCollabStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                      final filtered = _applyFilters(snapshot.data!.docs);
                      if (filtered.isEmpty) return const Center(child: Text("No matching collaborations."));

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final doc = filtered[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'Untitled';
                          final description = data['description'] ?? '';
                          final members = List<String>.from(data['members'] ?? []);
                          final memberCount = members.length;
                          final isJoined = members.contains(currentUserId);

                          return _CollabCard(
                            title: title,
                            subtitle: "$description • $memberCount members",
                            isJoined: isJoined,
                            onTap: () => _joinCollab(doc.id, title, members),
                          );
                        },
                      );
                    },
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.newCollab),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("New Collab", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D4F48),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size.fromHeight(50),
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
  final bool isJoined;
  final VoidCallback onTap;

  const _CollabCard({
    required this.title,
    required this.subtitle,
    required this.isJoined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isJoined ? const Color(0xFFE5F7EA) : Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isJoined ? const Color(0xFFB2DFDB) : const Color(0xFFE0E0E0),
          child: const Icon(Icons.groups, color: Color(0xFF2D4F48)),
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
            color: isJoined ? const Color(0xFF2D4F48) : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isJoined ? "Joined" : "Join",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}