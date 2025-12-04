import 'package:equatable/equatable.dart';

class AiMessage extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isUser;
  final MessageType type;

  const AiMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isUser,
    this.type = MessageType.text,
  });

  @override
  List<Object?> get props => [id, content, timestamp, isUser, type];

  AiMessage copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    bool? isUser,
    MessageType? type,
  }) {
    return AiMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isUser: isUser ?? this.isUser,
      type: type ?? this.type,
    );
  }
}

enum MessageType {
  text,
  image,
  code,
  suggestion,
}

