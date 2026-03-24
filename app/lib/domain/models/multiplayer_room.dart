import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

enum MultiplayerRoomVisibility {
  privateRoom,
  publicRoom,
}

enum MultiplayerRoomStatus {
  lobby,
  inProgress,
  completed,
  closed,
}

enum MultiplayerRoomPhase {
  lobby,
  privateReveal,
  clueTurns,
  discussion,
  voting,
  voteReveal,
  outsiderGuess,
  results,
}

enum MultiplayerPlayerRole {
  insider,
  outsider,
}

enum MultiplayerConnectionState {
  connected,
  reconnecting,
  disconnected,
}

int multiplayerMinimumPlayersForMode(String modeSlug) {
  switch (modeSlug) {
    case 'quick':
      return 3;
    case 'family':
    case 'classic':
      return 4;
    case 'chaos':
      return 5;
    case 'teams':
      return 6;
    default:
      return 4;
  }
}

int multiplayerMaxOutsidersForPlayerCount(int playerCount) {
  if (playerCount >= 9) {
    return 3;
  }
  if (playerCount >= 6) {
    return 2;
  }
  return 1;
}

@immutable
class MultiplayerPlayer {
  const MultiplayerPlayer({
    required this.id,
    required this.name,
    required this.avatarIndex,
    required this.score,
    required this.isHost,
    required this.isReady,
    required this.connectionState,
  });

  final String id;
  final String name;
  final int avatarIndex;
  final int score;
  final bool isHost;
  final bool isReady;
  final MultiplayerConnectionState connectionState;

  MultiplayerPlayer copyWith({
    String? id,
    String? name,
    int? avatarIndex,
    int? score,
    bool? isHost,
    bool? isReady,
    MultiplayerConnectionState? connectionState,
  }) {
    return MultiplayerPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      score: score ?? this.score,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}

@immutable
class MultiplayerChatMessage {
  const MultiplayerChatMessage({
    required this.id,
    required this.senderPlayerId,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.isSystem,
  });

  final String id;
  final String senderPlayerId;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final bool isSystem;
}

@immutable
class MultiplayerPrivateView {
  const MultiplayerPrivateView({
    required this.role,
    required this.topicLabel,
    required this.guessOptions,
    required this.voteSubmitted,
    required this.guessedTopic,
    required this.submittedSuspectIds,
  });

  const MultiplayerPrivateView.empty()
      : role = null,
        topicLabel = null,
        guessOptions = const [],
        voteSubmitted = false,
        guessedTopic = null,
        submittedSuspectIds = const [];

  final MultiplayerPlayerRole? role;
  final String? topicLabel;
  final List<String> guessOptions;
  final bool voteSubmitted;
  final String? guessedTopic;
  final List<String> submittedSuspectIds;

  bool get isOutsider => role == MultiplayerPlayerRole.outsider;
  bool get isInsider => role == MultiplayerPlayerRole.insider;

  MultiplayerPrivateView copyWith({
    Object? role = _sentinel,
    Object? topicLabel = _sentinel,
    List<String>? guessOptions,
    bool? voteSubmitted,
    Object? guessedTopic = _sentinel,
    List<String>? submittedSuspectIds,
  }) {
    return MultiplayerPrivateView(
      role: identical(role, _sentinel) ? this.role : role as MultiplayerPlayerRole?,
      topicLabel: identical(topicLabel, _sentinel) ? this.topicLabel : topicLabel as String?,
      guessOptions: guessOptions ?? this.guessOptions,
      voteSubmitted: voteSubmitted ?? this.voteSubmitted,
      guessedTopic: identical(guessedTopic, _sentinel) ? this.guessedTopic : guessedTopic as String?,
      submittedSuspectIds: submittedSuspectIds ?? this.submittedSuspectIds,
    );
  }
}

@immutable
class MultiplayerRoundState {
  const MultiplayerRoundState({
    required this.roundNumber,
    required this.phase,
    required this.activePlayerId,
    required this.outsiderIds,
    required this.survivingOutsiderIds,
    required this.accusedPlayerIds,
    required this.phaseEndsAt,
    required this.requiredVotes,
    required this.submittedVotes,
    required this.voteSelectionLimit,
    required this.outsiderSurvived,
    required this.statusLine,
  });

  const MultiplayerRoundState.empty()
      : roundNumber = 0,
        phase = MultiplayerRoomPhase.lobby,
        activePlayerId = null,
        outsiderIds = const [],
        survivingOutsiderIds = const [],
        accusedPlayerIds = const [],
        phaseEndsAt = null,
        requiredVotes = 0,
        submittedVotes = 0,
        voteSelectionLimit = 1,
        outsiderSurvived = false,
        statusLine = 'بانتظار بدء الغرفة';

  final int roundNumber;
  final MultiplayerRoomPhase phase;
  final String? activePlayerId;
  final List<String> outsiderIds;
  final List<String> survivingOutsiderIds;
  final List<String> accusedPlayerIds;
  final DateTime? phaseEndsAt;
  final int requiredVotes;
  final int submittedVotes;
  final int voteSelectionLimit;
  final bool outsiderSurvived;
  final String statusLine;

  MultiplayerRoundState copyWith({
    int? roundNumber,
    MultiplayerRoomPhase? phase,
    Object? activePlayerId = _sentinel,
    List<String>? outsiderIds,
    List<String>? survivingOutsiderIds,
    List<String>? accusedPlayerIds,
    Object? phaseEndsAt = _sentinel,
    int? requiredVotes,
    int? submittedVotes,
    int? voteSelectionLimit,
    bool? outsiderSurvived,
    String? statusLine,
  }) {
    return MultiplayerRoundState(
      roundNumber: roundNumber ?? this.roundNumber,
      phase: phase ?? this.phase,
      activePlayerId:
          identical(activePlayerId, _sentinel) ? this.activePlayerId : activePlayerId as String?,
      outsiderIds: outsiderIds ?? this.outsiderIds,
      survivingOutsiderIds: survivingOutsiderIds ?? this.survivingOutsiderIds,
      accusedPlayerIds: accusedPlayerIds ?? this.accusedPlayerIds,
      phaseEndsAt:
          identical(phaseEndsAt, _sentinel) ? this.phaseEndsAt : phaseEndsAt as DateTime?,
      requiredVotes: requiredVotes ?? this.requiredVotes,
      submittedVotes: submittedVotes ?? this.submittedVotes,
      voteSelectionLimit: voteSelectionLimit ?? this.voteSelectionLimit,
      outsiderSurvived: outsiderSurvived ?? this.outsiderSurvived,
      statusLine: statusLine ?? this.statusLine,
    );
  }
}

@immutable
class MultiplayerRoomState {
  const MultiplayerRoomState({
    required this.roomId,
    required this.roomCode,
    required this.shareLink,
    required this.visibility,
    required this.status,
    required this.modeSlug,
    required this.packId,
    required this.maxPlayers,
    required this.outsiderCount,
    required this.hostPlayerId,
    required this.currentPlayerId,
    required this.players,
    required this.round,
    required this.privateView,
    required this.chatMessages,
    required this.systemMessage,
  });

  final String roomId;
  final String roomCode;
  final String shareLink;
  final MultiplayerRoomVisibility visibility;
  final MultiplayerRoomStatus status;
  final String modeSlug;
  final String packId;
  final int maxPlayers;
  final int outsiderCount;
  final String hostPlayerId;
  final String currentPlayerId;
  final List<MultiplayerPlayer> players;
  final MultiplayerRoundState round;
  final MultiplayerPrivateView privateView;
  final List<MultiplayerChatMessage> chatMessages;
  final String systemMessage;

  MultiplayerPlayer? get currentPlayer {
    return players.firstWhereOrNull((player) => player.id == currentPlayerId);
  }

  bool get isCurrentPlayerHost => currentPlayerId == hostPlayerId;

  bool get canStart {
    if (!isCurrentPlayerHost || players.length < multiplayerMinimumPlayersForMode(modeSlug)) {
      return false;
    }
    if (outsiderCount > multiplayerMaxOutsidersForPlayerCount(players.length)) {
      return false;
    }
    return players.every((player) => player.isReady || player.isHost);
  }

  MultiplayerRoomState copyWith({
    String? roomId,
    String? roomCode,
    String? shareLink,
    MultiplayerRoomVisibility? visibility,
    MultiplayerRoomStatus? status,
    String? modeSlug,
    String? packId,
    int? maxPlayers,
    int? outsiderCount,
    String? hostPlayerId,
    String? currentPlayerId,
    List<MultiplayerPlayer>? players,
    MultiplayerRoundState? round,
    MultiplayerPrivateView? privateView,
    List<MultiplayerChatMessage>? chatMessages,
    String? systemMessage,
  }) {
    return MultiplayerRoomState(
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      shareLink: shareLink ?? this.shareLink,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      modeSlug: modeSlug ?? this.modeSlug,
      packId: packId ?? this.packId,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      outsiderCount: outsiderCount ?? this.outsiderCount,
      hostPlayerId: hostPlayerId ?? this.hostPlayerId,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      players: players ?? this.players,
      round: round ?? this.round,
      privateView: privateView ?? this.privateView,
      chatMessages: chatMessages ?? this.chatMessages,
      systemMessage: systemMessage ?? this.systemMessage,
    );
  }
}

const _sentinel = Object();
