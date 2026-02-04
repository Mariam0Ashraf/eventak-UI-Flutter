import 'package:eventak/customer-UI/features/chat_bot/data/chat_msg_model.dart';
import 'package:eventak/customer-UI/features/chat_bot/data/chatbot_service.dart';
import 'package:flutter/material.dart';

class ChatbotController extends ChangeNotifier {
  final ChatbotApiService _apiService = ChatbotApiService();
  
  List<ChatMessage> _messages = [];
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  bool _isBotTyping = false;
  
  int _currentPage = 1;
  int _lastPage = 1;
  String? _currentSessionId;

  // --- Getters ---
  List<ChatMessage> get messages => _messages;
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  bool get isBotTyping => _isBotTyping;
  String? get currentSessionId => _currentSessionId;

  Future<void> sendMessage(String text, {bool isInitial = false}) async {
    if (text.trim().isEmpty) return;

    if (!isInitial) {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    }
    
    _isBotTyping = true;
    notifyListeners();

    try {
      final responseData = await _apiService.sendMessage(text, _currentSessionId);
      _currentSessionId = responseData['session_id']?.toString();
      final botMsgMap = responseData['message'] as Map<String, dynamic>;
      // Pass the internal map to the model
      final botMsg = ChatMessage.fromJson(botMsgMap);
      
      _messages.add(botMsg);
    } catch (e) {
      debugPrint("Chatbot Send Error: $e");
      _messages.add(ChatMessage(
        text: "Sorry, I'm having trouble connecting to the model.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isBotTyping = false;
      notifyListeners();
    }
  }

  // Handles pagination by loading older messages when user scrolls to top
  Future<void> loadMoreMessages() async {
    if (_isLoadingMore || _currentSessionId == null || _currentPage >= _lastPage) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final responseData = await _apiService.getMessages(_currentSessionId!, page: nextPage);
      
      final List<dynamic> messageList = responseData['data'];
      final List<ChatMessage> fetchedMessages = messageList
          .map((m) => ChatMessage.fromJson(m))
          .toList();

      _messages.insertAll(0, fetchedMessages);
      
      _currentPage = responseData['current_page'];
      _lastPage = responseData['last_page'];
    } catch (e) {
      debugPrint(" Pagination Error: $e");
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Loads the first page of messages for a specific session
  Future<void> loadInitialMessages(String sessionId) async {
    _isLoadingInitial = true;
    _currentSessionId = sessionId;
    _currentPage = 1;
    notifyListeners();

    try {
      final responseData = await _apiService.getMessages(sessionId, page: 1);
      final List<dynamic> messageList = responseData['data'];
      
      _messages = messageList.map((m) => ChatMessage.fromJson(m)).toList();
      _lastPage = responseData['last_page'];
    } catch (e) {
      debugPrint("Initial Load Error: $e");
    } finally {
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> clearConversation() async {
    if (_currentSessionId == null) {
      resetChat();
      return;
    }

    try {
      final success = await _apiService.deleteSession(_currentSessionId!);
      if (success) {
        resetChat();
      } else {
        debugPrint("Failed to delete session on server");
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  void resetChat() {
    _messages.clear();
    _currentSessionId = null;
    _currentPage = 1;
    _lastPage = 1;
    notifyListeners();
  }
}