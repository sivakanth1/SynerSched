import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: "Siva Kondamadugula");
  final _interestController = TextEditingController(
    text: "Smart campus apps, automation",
  );

  String _selectedDepartment = 'Computer Science';
  String _selectedYear = '2nd Year';

  final List<String> departments = [
    'Computer Science',
    'Mechanical Engineering',
    'Business',
    'Mathematics',
    'Biology',
  ];

  final List<String> years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Graduate',
  ];

  final List<String> allSkills = [
    'Flutter',
    'Machine Learning',
    'Firebase',
    'Python',
    'UI/UX',
  ];

  final Set<String> selectedSkills = {'Flutter', 'Machine Learning'};

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizer.translate("edit_profile")),
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: localizer.translate("name"),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: _selectedDepartment,
            items: departments.map((dep) {
              return DropdownMenuItem(value: dep, child: Text(dep));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedDepartment = val);
            },
            decoration: InputDecoration(
              labelText: localizer.translate("department"),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: _selectedYear,
            items: years.map((year) {
              return DropdownMenuItem(value: year, child: Text(year));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedYear = val);
            },
            decoration: InputDecoration(
              labelText: localizer.translate("year"),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          Text(localizer.translate("skills")),
          Wrap(
            spacing: 8,
            children: allSkills.map((skill) {
              final isSelected = selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedSkills.add(skill);
                    } else {
                      selectedSkills.remove(skill);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          TextField(
            controller: _interestController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: localizer.translate("interests"),
              border: const OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Save logic
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
            label: Text(localizer.translate("save")),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
