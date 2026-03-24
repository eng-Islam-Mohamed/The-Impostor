import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/domain/models/multiplayer_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MultiplayerChatCard extends ConsumerWidget {
  const MultiplayerChatCard({
    required this.messages,
    required this.controller,
    required this.onSend,
    super.key,
  });

  final List<MultiplayerChatMessage> messages;
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    warmUiPhrases(
      ref,
      const [
        'دردشة الغرفة',
        'اكتب رسالة سريعة',
        'إرسال',
        'النظام',
      ],
    );

    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizeUiPhrase(ref, 'دردشة الغرفة'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          Container(
            height: 220,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ListView.separated(
              reverse: true,
              itemCount: messages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                final senderLabel = message.isSystem
                    ? localizeUiPhrase(ref, 'النظام')
                    : message.senderName;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isSystem
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                        : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(message.text),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: localizeUiPhrase(ref, 'اكتب رسالة سريعة'),
              suffixIcon: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded),
              ),
            ),
            onSubmitted: (_) => onSend(),
          ),
          const SizedBox(height: 12),
          BaraButton.secondary(
            label: localizeUiPhrase(ref, 'إرسال'),
            icon: Icons.send_rounded,
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
