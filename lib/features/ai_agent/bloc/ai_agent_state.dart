import 'package:equatable/equatable.dart';
import '../models/ai_message.dart';

abstract class AiAgentState extends Equatable {
  const AiAgentState();

  @override
  List<Object?> get props => [];
}

class AiAgentInitial extends AiAgentState {
  const AiAgentInitial();
}

class AiAgentLoading extends AiAgentState {
  const AiAgentLoading();
}

class AiAgentChatLoaded extends AiAgentState {
  final List<AiMessage> messages;
  final bool isTyping;

  const AiAgentChatLoaded({
    required this.messages,
    this.isTyping = false,
  });

  @override
  List<Object?> get props => [messages, isTyping];

  AiAgentChatLoaded copyWith({
    List<AiMessage>? messages,
    bool? isTyping,
  }) {
    return AiAgentChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class AiAgentError extends AiAgentState {
  final String message;

  const AiAgentError({required this.message});

  @override
  List<Object?> get props => [message];
}

