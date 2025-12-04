import 'package:equatable/equatable.dart';

abstract class AiAgentEvent extends Equatable {
  const AiAgentEvent();

  @override
  List<Object?> get props => [];
}

class AiAgentMessageSent extends AiAgentEvent {
  final String message;

  const AiAgentMessageSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class AiAgentClearChat extends AiAgentEvent {
  const AiAgentClearChat();
}

class AiAgentLoadHistory extends AiAgentEvent {
  const AiAgentLoadHistory();
}

