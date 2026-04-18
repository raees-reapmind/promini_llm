import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pro_mini/providers/chat_provider.dart';
import 'package:pro_mini/providers/suggestion_notofier.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);
    final suggestions = ref.watch(suggestionProvider);
    final suggestionNotifier = ref.read(suggestionProvider.notifier);
    final isLoading = notifier.isLoading;

    log('[ChatScreen] isLoading: $isLoading, messages: ${messages.length}');

    return Scaffold(
      appBar: AppBar(title: const Text("Gemini Chat (Riverpod)")),
      body: Column(
        children: [
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                  controller: controller,
                  enabled: !isLoading,
                  onChanged: (text) {
                    suggestionNotifier.onTextChanged(text);
                  },
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ),
                const SizedBox(width: 8),
                if (isLoading)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[600]!,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = controller.text;
                      controller.clear();
                      log('[ChatScreen] Sending message: $text');
                      await notifier.sendMessage(text);
                    },
                  )
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: suggestions.isEmpty ? 0 : 150,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                )
              ],
            ),
            child: suggestions.isEmpty
                ? null
              : ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (_, i) {
                    final text = suggestions[i];
                    return ListTile(
                      dense: true,
                      title: Text(text),
                      onTap: () {
                        controller.text = text;
                        controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: text.length),
                        );
                        suggestionNotifier.clear();
                      },
                    );
                  },
                ),
        ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (isLoading && i == messages.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.smart_toy, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI is thinking...',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      minHeight: 4,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue[600]!,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final msg = messages[i];
                    return ListTile(
                      title: Text(msg.text),
                      trailing: msg.isUser ? const Icon(Icons.person) : null,
                      leading: !msg.isUser ? const Icon(Icons.smart_toy) : null,
                    );
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
