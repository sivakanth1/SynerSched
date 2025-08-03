// This screen displays the chat interface for a specific collaboration channel using Stream Chat.
// Users can view and send messages, and choose to leave the collaboration.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:syner_sched/localization/app_localizations.dart';

// A stateful widget that sets up and renders a chat channel using the provided collaboration details.
class ChatDetailScreen extends StatefulWidget {
  final String collabId;
  final String collabName;
  final StreamChatClient streamClient;

  const ChatDetailScreen({
    super.key,
    required this.collabId,
    required this.collabName,
    required this.streamClient,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late Channel _channel;
  final messageInputController = StreamMessageInputController();

  // Initializes the chat channel using the StreamChatClient and starts listening to updates.
  @override
  void initState() {
    super.initState();
    _channel = widget.streamClient.channel(
      'messaging',
      id: widget.collabId,
      extraData: {
        'name': widget.collabName,
      },
    );
    _channel.watch();
  }

  // Disposes the message input controller to free resources when the widget is removed.
  @override
  void dispose() {
    messageInputController.dispose();
    super.dispose();
  }

  // Builds the chat UI wrapped in the StreamChannel widget, which provides context to Stream Chat widgets.
  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: _channel,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        // The app bar showing the channel name and options menu (e.g., to leave the channel).
        appBar: StreamChannelHeader(
          showTypingIndicator: true,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                // When 'leave' is selected, removes the current user from the Stream channel and updates Firestore.
                if (value == 'leave') {
                  final userId = StreamChat.of(context).currentUser!.id;
                  await _channel.removeMembers([userId]);
                  await FirebaseFirestore.instance
                      .collection('collaborations')
                      .doc(_channel.id)
                      .update({
                    'members': FieldValue.arrayRemove([userId]),
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.translate("left_collab_message"))),
                    );
                  }
                }
              },
              itemBuilder: (context) =>  [
                PopupMenuItem(
                  value: 'leave',
                  child: Text(AppLocalizations.of(context)!.translate("leave_collaboration")),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Displays the list of chat messages in the channel.
            const Expanded(child: StreamMessageListView()),
            // Allows the user to input and send messages, including voice recordings.
            StreamMessageInput(
              messageInputController: messageInputController,
              enableVoiceRecording: true,
              autofocus: true,
              showCommandsButton: false,
            ),
          ],
        ),
      ),
    );
  }
}