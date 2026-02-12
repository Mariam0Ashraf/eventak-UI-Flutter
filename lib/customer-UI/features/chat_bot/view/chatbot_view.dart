import 'package:eventak/customer-UI/features/chat_bot/data/chatbot_controller.dart';
import 'package:eventak/customer-UI/features/chat_bot/widgets/msg_input.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final ChatbotController _controller = ChatbotController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.fetchSessions();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == 0) {
        _controller.loadMoreMessages();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColor.primary),
            title: Text(
              "Chat with our event guide...",
              style: TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add_comment_outlined, color: AppColor.primary),
                tooltip: 'New Chat',
                onPressed: () => _controller.resetChat(),
              ),
              IconButton(
                icon: Icon(Icons.delete_sweep_outlined, color: AppColor.primary),
                onPressed: () async {
                  await _controller.clearConversation();

                },
              ),
            ],
          ),
          
          drawer: Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: AppColor.primary),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                        SizedBox(height: 10),
                        Text(
                          "Your Conversations",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _controller.sessions.isEmpty
                      ? const Center(child: Text("No history found"))
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _controller.sessions.length,
                          itemBuilder: (context, index) {
                            final session = _controller.sessions[index];
                            final String sessionId = session['id'].toString();
                            final bool isSelected = _controller.currentSessionId == sessionId;

                            return ListTile(
                              leading: Icon(
                                Icons.chat_bubble_outline,
                                color: isSelected ? AppColor.primary : Colors.grey,
                              ),
                              title: Text(
                                session['title'] ?? "New Conversation",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => _controller.deleteSpecificSession(sessionId),
                              ),
                              selected: isSelected,
                              selectedTileColor: AppColor.primary.withOpacity(0.1),
                              onTap: () {
                                _controller.switchSession(sessionId);
                                Navigator.pop(context); 
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          body: Column(
            children: [
              Expanded(
                child: _controller.messages.isEmpty && !_controller.isBotTyping
                    ? _buildWelcomeState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _controller.messages.length,
                        itemBuilder: (context, index) {
                          if (index == 0 && _controller.isLoadingMore) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }
                          return ChatBubble(message: _controller.messages[index]);
                        },
                      ),
              ),
              
              if (_controller.isBotTyping)
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Align(alignment: Alignment.centerLeft, child: TypingIndicator()),
                ),
              
              MessageInput(onSend: (text) async {
                await _controller.sendMessage(text);
                _scrollToBottom();
                _controller.fetchSessions();
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_outlined, size: 64, color: AppColor.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "How can I help you plan\nyour next event?",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}