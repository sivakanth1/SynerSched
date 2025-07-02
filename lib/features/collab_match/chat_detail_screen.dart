import 'package:flutter/material.dart';
import 'package:syner_sched/localization/app_localizations.dart';
import '../../shared/custom_nav_bar.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [
    "Hey team!",
    "Let's finalize the model today.",
  ];

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizer.translate("chat_room")),
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 2, onTap: (index) {}),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: index % 2 == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: index % 2 == 0
                          ? Colors.blue.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(messages[index]),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: localizer.translate("type_message"),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      setState(() {
                        messages.add(_controller.text.trim());
                        _controller.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
