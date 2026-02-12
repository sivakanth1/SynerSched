import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../localization/app_localizations.dart';
import 'collab_validator.dart';

/// Screen that allows users to start a new collaboration by entering details
/// such as title, description, department, and required skills.
/// It handles creation of the collaboration in Firestore and sets up
/// a corresponding Stream chat channel.
class NewCollabScreen extends StatefulWidget {
  final StreamChatClient streamClient;

  const NewCollabScreen({super.key, required this.streamClient});

  @override
  State<NewCollabScreen> createState() => _NewCollabScreenState();
}

class _NewCollabScreenState extends State<NewCollabScreen> {
  // Controller for the collaboration title input field
  final _titleController = TextEditingController();
  // Controller for the collaboration description input field
  final _descController = TextEditingController();
  // Controller for the tag input field used to add skills/tags
  final _tagController = TextEditingController();
  // Currently authenticated Firebase user
  final _currentUser = FirebaseAuth.instance.currentUser;

  // Currently selected department for the collaboration; default is "Computer Science"
  String? _selectedDepartment = "Computer Science";
  // List of tags/skills added by the user for this collaboration
  final List<String> _tags = [];

  /// Adds a new tag to the list if it's not empty and not already added.
  void _addTag(String tag) {
    final tagError = CollabValidator.validateTag(tag);
    if (tagError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate(tagError))));
      return;
    }

    final countError = CollabValidator.validateTagsCount(_tags);
    if (countError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate(countError))));
      return;
    }

    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  /// Removes a tag from the list.
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
          title: Text(
            AppLocalizations.of(context)!.translate("start_new_collab"),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D4F48)),
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
                      hintText: AppLocalizations.of(context)!.translate("title"),
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
                      hintText: AppLocalizations.of(context)!.translate("description"),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Department Dropdown
                  _buildLabel(AppLocalizations.of(context)!.translate("department")),
                  const SizedBox(height: 4),
                  _buildDepartmentAutocomplete(),
                  const SizedBox(height: 16),

                  // Tags/Skills
                  _buildLabel(AppLocalizations.of(context)!.translate("skills")),
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
                      label: Text(AppLocalizations.of(context)!.translate("create")),
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

  /// Builds an autocomplete text field for tags/skills input, allowing users
  /// to search and add predefined tags easily.
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
            hintText: AppLocalizations.of(context)!.translate("search_placeholder"),
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

  /// Builds a label widget with styled text, used to label sections like
  /// department and skills input areas.
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  /// Builds an autocomplete text field for selecting the department associated
  /// with the collaboration, with a predefined list of departments.
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
            hintText: AppLocalizations.of(context)!.translate("department"),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
      },
    );
  }

  /// Handles the creation of a new collaboration.
  ///
  /// Steps:
  /// 1. Validate input fields and current user presence.
  /// 2. Create a new document in Firestore 'collaborations' collection with
  ///    collaboration details including title, description, department, skills,
  ///    members, creator info, and timestamp.
  /// 3. Create a new Stream chat channel with the Firestore document ID as channel ID.
  /// 4. Update the Firestore document with the Stream channel ID.
  /// 5. Show success message and navigate back on success.
  /// 6. Show error message on failure.
  Future<void> _createCollab() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    final titleError = CollabValidator.validateTitle(title);
    if (titleError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate(titleError))));
      return;
    }

    final descError = CollabValidator.validateDescription(desc);
    if (descError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate(descError))));
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate("join_collaboration_prompt"))));
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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate("collab_created"))));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate("error_joining_collab"))));
    }
  }
}