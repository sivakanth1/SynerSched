import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:syner_sched/localization/app_localizations.dart';

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

  @override
  void dispose() {
    messageInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: _channel,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: StreamChannelHeader(
          showTypingIndicator: true,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
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
            const Expanded(child: StreamMessageListView()),
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