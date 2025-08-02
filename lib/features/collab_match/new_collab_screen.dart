import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class NewCollabScreen extends StatefulWidget {
  final StreamChatClient streamClient;

  const NewCollabScreen({super.key, required this.streamClient});

  @override
  State<NewCollabScreen> createState() => _NewCollabScreenState();
}

class _NewCollabScreenState extends State<NewCollabScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser;

  String? _selectedDepartment = "Computer Science";
  final List<String> _tags = [];

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
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
        backgroundColor: Colors.transparent,
        // bottomNavigationBar: const CustomNavBar(currentIndex: 2),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Start New Collaboration",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D4F48)),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Collaboration Title",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Project Description",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Department Dropdown
                  _buildLabel("Department"),
                  const SizedBox(height: 4),
                  _buildDepartmentAutocomplete(),
                  const SizedBox(height: 16),

                  // Tags/Skills
                  _buildLabel("Tags or Skills (optional)"),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: _tags
                        .map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.white,
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () => _removeTag(tag),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  _buildTagAutocomplete(),
                  const SizedBox(height: 24),

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createCollab,
                      icon: const Icon(Icons.check),
                      label: const Text("Create"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D4F48),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagAutocomplete() {
    final allTags = [
      "AI", "Automation", "Augmented Reality", "Big Data", "Blockchain", "Business Intelligence",
      "Cloud", "Cybersecurity", "Data Analysis", "Data Engineering", "Data Mining", "Data Science",
      "Deep Learning", "DevOps", "Digital Marketing", "Edge Computing", "Ethical Hacking", "Flutter",
      "Game Development", "Graphic Design", "IoT", "Java", "JavaScript", "Kotlin", "Machine Learning",
      "Mobile App", "Natural Language Processing", "Networking", "Python", "React", "Robotics",
      "SQL", "Software Engineering", "Sustainability", "Teamwork", "UI/UX", "Virtual Reality",
      "Web Dev", "Web3"
    ]..sort();

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return allTags
            .where((tag) =>
        tag.toLowerCase().contains(textEditingValue.text.toLowerCase()) &&
            !_tags.contains(tag))
            .toList();
      },
      onSelected: (String selection) => _addTag(selection),
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        _tagController.text = controller.text; // Sync controller
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          decoration: InputDecoration(
            hintText: "Add a tag (e.g., Flutter)",
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addTag(controller.text.trim()),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDepartmentAutocomplete() {
    final allDepartments = [
      "Accounting", "Anthropology", "Architecture", "Biological Sciences", "Business",
      "Chemical Engineering", "Civil Engineering", "Computer Science", "Criminal Justice",
      "Data Science", "Design", "Economics", "Education", "Electrical Engineering", "Engineering",
      "English", "Environmental Science", "Finance", "History", "Information Systems", "Law",
      "Linguistics", "Management", "Marketing", "Mathematics", "Mechanical Engineering",
      "Media Studies", "Medicine", "Nursing", "Philosophy", "Physics", "Political Science",
      "Psychology", "Public Administration", "Public Health", "Social Work", "Sociology",
      "Software Engineering", "Statistics", "Theater", "Urban Planning", "Zoology"
    ]..sort();

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return allDepartments.where((dept) => dept
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase()));
      },
      initialValue: TextEditingValue(text: _selectedDepartment ?? ""),
      onSelected: (String selection) {
        setState(() {
          _selectedDepartment = selection;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          decoration: InputDecoration(
            hintText: "Select Department",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
      },
    );
  }

  Future<void> _createCollab() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    if (title.isEmpty || desc.isEmpty || _currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields.")));
      return;
    }

    try {
      // Step 1: Create Firestore doc
      final docRef = await FirebaseFirestore.instance.collection('collaborations').add({
        'title': title,
        'description': desc,
        'department': _selectedDepartment,
        'skills': _tags,
        'members': [_currentUser.uid],
        'createdBy': _currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'streamChannelId': '',
      });

      // Step 2: Create Stream channel
      final channel = widget.streamClient.channel(
        'messaging',
        id: docRef.id,
        extraData: {
          'name': title,
          'members': [_currentUser.uid],
        },
      );
      await channel.create();

      // Step 3: Update Firestore with Stream channel ID
      await docRef.update({'streamChannelId': channel.id});

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Collaboration Created!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}