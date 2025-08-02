import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
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
  List<String> _departments = [
    "Computer Science",
    "Information Systems",
    "Engineering",
    "Data Science",
  ];

  List<String> _skills = ["Flutter", "Machine Learning"];

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
        title: const Text(
          "Edit Profile",
          style: TextStyle(
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
            _buildLabel("Name"),
            _buildTextField(_nameController, hint: "Enter your name"),
            const SizedBox(height: 16),

            _buildLabel("Department"),
            _buildDropdown(),
            const SizedBox(height: 16),

            _buildLabel("Year"),
            _buildTextField(_yearController, hint: "Enter year"),
            const SizedBox(height: 16),

            _buildLabel("Skills"),
            _buildSkillChips(),
            const SizedBox(height: 8),
            _buildTextField(
              _skillController,
              hint: "Add a skill",
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addSkill(_skillController.text),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel("Interests"),
            _buildTextField(_interestsController, hint: "Enter your Interests"),
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
                      const SnackBar(content: Text('Profile updated')),
                    );

                    if (widget.fromSignup) {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    } else {
                      Navigator.pop(context); // just go back to ProfileScreen
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving profile: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text("Save"),
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

  Widget _buildSkillChips() {
    return Wrap(
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
    );
  }
}
