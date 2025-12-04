import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/config/app_config.dart';
import '../models/ai_message.dart';
import 'ai_agent_event.dart';
import 'ai_agent_state.dart';

class AiAgentBloc extends Bloc<AiAgentEvent, AiAgentState> {
  final List<AiMessage> _messages = [];

  AiAgentBloc() : super(const AiAgentInitial()) {
    on<AiAgentMessageSent>(_onMessageSent);
    on<AiAgentClearChat>(_onClearChat);
    on<AiAgentLoadHistory>(_onLoadHistory);
  }

  Future<void> _onMessageSent(
    AiAgentMessageSent event,
    Emitter<AiAgentState> emit,
  ) async {
    // Add user message
    final userMessage = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.message,
      timestamp: DateTime.now(),
      isUser: true,
    );
    _messages.add(userMessage);
    emit(AiAgentChatLoaded(messages: List.from(_messages), isTyping: true));

    // Simulate AI response delay
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay + 500));

    // Generate AI response
    final aiResponse = _generateAiResponse(event.message);
    final aiMessage = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: aiResponse,
      timestamp: DateTime.now(),
      isUser: false,
    );
    _messages.add(aiMessage);
    emit(AiAgentChatLoaded(messages: List.from(_messages), isTyping: false));
  }

  Future<void> _onClearChat(
    AiAgentClearChat event,
    Emitter<AiAgentState> emit,
  ) async {
    _messages.clear();
    emit(const AiAgentChatLoaded(messages: []));
  }

  Future<void> _onLoadHistory(
    AiAgentLoadHistory event,
    Emitter<AiAgentState> emit,
  ) async {
    emit(AiAgentChatLoaded(messages: List.from(_messages)));
  }

  String _generateAiResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    // Simple rule-based responses (in production, use actual AI API)
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! I\'m your AI learning assistant. How can I help you with your studies today?';
    } else if (lowerMessage.contains('study plan')) {
      return 'I can help you create a study plan! Here are some tips:\n\n1. Break down your goals into smaller tasks\n2. Set realistic deadlines\n3. Review regularly\n4. Take breaks\n\nWould you like me to help you create a specific study plan?';
    } else if (lowerMessage.contains('certificate')) {
      return 'Certificates are a great way to showcase your achievements! You can:\n\n1. View your certificates in the Profile section\n2. Download them as PDF files\n3. Share them on your professional profiles\n\nHave you completed a course recently?';
    } else if (lowerMessage.contains('video') || lowerMessage.contains('ai video')) {
      return 'AI Video generation is a powerful feature! You can:\n\n1. Upload text content\n2. Choose a video style (Educational, Presentation, Tutorial, Summary)\n3. Generate engaging educational videos\n\nWould you like to learn more about creating AI videos?';
    } else if (lowerMessage.contains('forum')) {
      return 'The forum is a great place to connect with other learners! You can:\n\n1. Ask questions\n2. Share knowledge\n3. Get help from the community\n4. Upvote helpful posts\n\nWhat topic would you like to discuss?';
    } else if (lowerMessage.contains('help')) {
      return 'I\'m here to help! I can assist you with:\n\n📚 Study Plans - Create and manage your learning schedule\n🎥 AI Videos - Generate educational content\n💬 Forum - Connect with other learners\n📜 Certificates - Track your achievements\n\nWhat would you like to know more about?';
    } else if (lowerMessage.contains('thank')) {
      return 'You\'re welcome! Feel free to ask me anything else about your learning journey.';
    } else {
      return 'That\'s an interesting question! Let me help you with that.\n\nBased on your message, I can provide guidance on:\n- Study strategies\n- Course recommendations\n- Learning techniques\n- Time management\n\nCould you provide more details about what you\'d like to know?';
    }
  }
}

