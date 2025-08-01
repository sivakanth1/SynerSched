import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:syner_sched/shared/custom_nav_bar.dart';

class NewCollabScreen extends StatelessWidget {
  final StreamChatClient streamClient;

  const NewCollabScreen({super.key, required this.streamClient});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/app_background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const CustomNavBar(currentIndex: 2),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D4F48)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Start New Collaboration",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D4F48),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Collaboration Title",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Project Description",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final desc = descriptionController.text.trim();

                      if (title.isEmpty || desc.isEmpty || currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter all fields.")),
                        );
                        return;
                      }

                      try {
                        // 1. Create Firestore entry
                        final docRef = await FirebaseFirestore.instance.collection('collaborations').add({
                          'title': title,
                          'description': desc,
                          'members': [currentUser.uid],
                          'createdBy': currentUser.uid,
                          'createdAt': FieldValue.serverTimestamp(),
                          'streamChannelId': '', // placeholder
                        });

                        // 2. Create Stream channel
                        final channel = streamClient.channel(
                          'messaging',
                          id: docRef.id, // using Firestore doc ID as channel ID
                          extraData: {
                            'name': title,
                            'members': [currentUser.uid],
                          },
                        );
                        await channel.create();

                        // 3. Update Firestore with Stream channel ID
                        await docRef.update({'streamChannelId': channel.id});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Collaboration Created!")),
                        );

                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      }
                    },
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text("Create"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D4F48),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}