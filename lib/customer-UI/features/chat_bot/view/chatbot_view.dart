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
    //initial msg to appear once user open the view
    //_controller.sendMessage("Hi", isInitial: true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == 0) {
        _controller.loadMoreMessages();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
            actions: [
              IconButton(
                icon: Icon(Icons.delete_sweep_outlined, color: AppColor.primary),
                onPressed: () => _controller.clearConversation(),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColor.primary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
            title: Text(
              "Chat with our event guide...",
              style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _controller.messages.length,
                  itemBuilder: (context, index) {if (index == 0 && _controller.isLoadingMore) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ));
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
              MessageInput(onSend: (text) {
                _controller.sendMessage(text);
                _scrollToBottom();
              }),
            ],
          ),
        );
      },
    );
  }
}