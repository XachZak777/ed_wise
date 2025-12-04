import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ed_wise/features/ai_agent/bloc/ai_agent_bloc.dart';
import 'package:ed_wise/features/ai_agent/bloc/ai_agent_event.dart';
import 'package:ed_wise/features/ai_agent/bloc/ai_agent_state.dart';

void main() {
  group('AiAgentBloc', () {
    test('initial state is AiAgentInitial', () {
      expect(
        AiAgentBloc().state,
        equals(const AiAgentInitial()),
      );
    });

    blocTest<AiAgentBloc, AiAgentState>(
      'emits states when message sent',
      build: () => AiAgentBloc(),
      act: (bloc) => bloc.add(const AiAgentMessageSent(message: 'Hello')),
      wait: const Duration(milliseconds: 1200),
      expect: () => [
        isA<AiAgentChatLoaded>().having((s) => s.messages.length, 'messages length', 1),
        isA<AiAgentChatLoaded>().having((s) => s.messages.length, 'messages length', 2),
      ],
    );

    blocTest<AiAgentBloc, AiAgentState>(
      'emits cleared state when chat cleared',
      build: () => AiAgentBloc(),
      act: (bloc) => bloc.add(const AiAgentClearChat()),
      expect: () => [
        const AiAgentChatLoaded(messages: []),
      ],
    );

    blocTest<AiAgentBloc, AiAgentState>(
      'emits loaded state when history loaded',
      build: () => AiAgentBloc(),
      act: (bloc) => bloc.add(const AiAgentLoadHistory()),
      expect: () => [
        const AiAgentChatLoaded(messages: []),
      ],
    );
  });
}

