import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
import '../../localization/app_localizations.dart';
import '../../routes/app_routes.dart';

class EditProfileScreen extends StatefulWidget {
  final bool fromSignup;
  const EditProfileScreen({super.key, this.fromSignup =false});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();
  final _skillController = TextEditingController();
  final _interestsController = TextEditingController();

  String? _selectedDepartment = "Computer Science";
  final List<String> _departments = [
    "Accounting", "Anthropology", "Architecture", "Biological Sciences", "Business",
    "Chemical Engineering", "Civil Engineering", "Computer Science", "Criminal Justice",
    "Data Science", "Design", "Economics", "Education", "Electrical Engineering", "Engineering",
    "English", "Environmental Science", "Finance", "History", "Information Systems", "Law",
    "Linguistics", "Management", "Marketing", "Mathematics", "Mechanical Engineering",
    "Media Studies", "Medicine", "Nursing", "Philosophy", "Physics", "Political Science",
    "Psychology", "Public Administration", "Public Health", "Social Work", "Sociology",
    "Software Engineering", "Statistics", "Theater", "Urban Planning", "Zoology",
  ];

  final List<String> _skills = [];

  final List<String> _allSkillOptions = [
    "AI", "Automation", "Augmented Reality", "Big Data", "Blockchain", "Business Intelligence",
    "Cloud", "Cybersecurity", "Data Analysis", "Data Engineering", "Data Mining", "Data Science",
    "Deep Learning", "DevOps", "Digital Marketing", "Edge Computing", "Ethical Hacking", "Flutter",
    "Game Development", "Graphic Design", "IoT", "Java", "JavaScript", "Kotlin", "Machine Learning",
    "Mobile App", "Natural Language Processing", "Networking", "Python", "React", "Robotics",
    "SQL", "Software Engineering", "Sustainability", "Teamwork", "UI/UX", "Virtual Reality",
    "Web Dev", "Web3"
  ];

  void _addSkill(String skill) {
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.translate("edit_profile"),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D4F48),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            _buildLabel(AppLocalizations.of(context)!.translate("name")),
            _buildTextField(_nameController, hint: AppLocalizations.of(context)!.translate("enter_name")),
            const SizedBox(height: 16),

            _buildLabel(AppLocalizations.of(context)!.translate("department")),
            _buildDropdown(),
            const SizedBox(height: 16),

            _buildLabel(AppLocalizations.of(context)!.translate("year")),
            _buildTextField(_yearController, hint: AppLocalizations.of(context)!.translate("enter_year")),
            const SizedBox(height: 16),

            _buildLabel(AppLocalizations.of(context)!.translate("skills")),
            _buildSkillAutocomplete(),
            const SizedBox(height: 16),

            _buildLabel(AppLocalizations.of(context)!.translate("interests")),
            _buildTextField(_interestsController, hint: AppLocalizations.of(context)!.translate("enter_interests")),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;

                  try {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('profile')
                        .doc('info') // <- you can name this anything; 'info' is a good default
                        .set({
                      'name': _nameController.text,
                      'department': _selectedDepartment,
                      'year': _yearController.text,
                      'skills': _skills,
                      'interests': _interestsController.text.split(','),
                    });

                    // Optional: update Stream Chat name
                    try {
                      final streamClient = stream.StreamChat.of(context).client;
                      await streamClient.updateUser(
                        stream.User(id: uid, name: _nameController.text.trim()),
                      );
                    } catch (e) {
                      debugPrint("⚠️ Failed to update Stream name: $e");
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.translate("profile_updated"))),
                    );

                    if (widget.fromSignup) {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    } else {
                      Navigator.pop(context); // just go back to ProfileScreen
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${AppLocalizations.of(context)!.translate("error_saving_profile")}: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.check),
                label: Text(AppLocalizations.of(context)!.translate("save_changes")),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF2D4F48),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    String? hint,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _selectedDepartment,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: _departments.map((dept) {
          return DropdownMenuItem<String>(value: dept, child: Text(dept));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDepartment = value;
          });
        },
      ),
    );
  }

  Widget _buildSkillAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: _skills
              .map(
                (skill) => Chip(
                  label: Text(skill),
                  backgroundColor: const Color(0xFFE3F2FD),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => _removeSkill(skill),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            final input = textEditingValue.text.toLowerCase();
            return _allSkillOptions
                .where((skill) => skill.toLowerCase().contains(input) && !_skills.contains(skill))
                .toList();
          },
          onSelected: (String selection) {
            _addSkill(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            controller.clear();
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.translate("add_skill"),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _addSkill(controller.text.trim());
                    _skillController.clear();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }
}
