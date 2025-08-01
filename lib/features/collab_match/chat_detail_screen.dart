import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final channel = streamClient.channel(
      'messaging',
      id: collabId,
      extraData: {
        'name': collabName,
      },
    );

    return FutureBuilder(
      future: channel.watch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        return StreamChannel(
          channel: channel,
          child: Scaffold(
            appBar: StreamChannelHeader(showTypingIndicator: true),
            body: Column(
              children: [
                Expanded(child: StreamMessageListView()),
                StreamMessageInput(),
              ],
            ),
          ),
        );
      },
    );
  }
}