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
class MultiplayerPrivateView {
  const MultiplayerPrivateView({
    required this.role,
    required this.topicLabel,
    required this.guessOptions,
    required this.voteSubmitted,
    required this.guessedTopic,
  });

  const MultiplayerPrivateView.empty()
      : role = null,
        topicLabel = null,
        guessOptions = const [],
        voteSubmitted = false,
        guessedTopic = null;

  final MultiplayerPlayerRole? role;
  final String? topicLabel;
  final List<String> guessOptions;
  final bool voteSubmitted;
  final String? guessedTopic;

  bool get isOutsider => role == MultiplayerPlayerRole.outsider;
  bool get isInsider => role == MultiplayerPlayerRole.insider;

  MultiplayerPrivateView copyWith({
    Object? role = _sentinel,
    Object? topicLabel = _sentinel,
    List<String>? guessOptions,
    bool? voteSubmitted,
    Object? guessedTopic = _sentinel,
  }) {
    return MultiplayerPrivateView(
      role: identical(role, _sentinel) ? this.role : role as MultiplayerPlayerRole?,
      topicLabel: identical(topicLabel, _sentinel) ? this.topicLabel : topicLabel as String?,
      guessOptions: guessOptions ?? this.guessOptions,
      voteSubmitted: voteSubmitted ?? this.voteSubmitted,
      guessedTopic: identical(guessedTopic, _sentinel) ? this.guessedTopic : guessedTopic as String?,
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
    required this.phaseEndsAt,
    required this.requiredVotes,
    required this.submittedVotes,
    required this.mostVotedPlayerId,
    required this.outsiderSurvived,
    required this.statusLine,
  });

  const MultiplayerRoundState.empty()
      : roundNumber = 0,
        phase = MultiplayerRoomPhase.lobby,
        activePlayerId = null,
        outsiderIds = const [],
        phaseEndsAt = null,
        requiredVotes = 0,
        submittedVotes = 0,
        mostVotedPlayerId = null,
        outsiderSurvived = false,
        statusLine = 'بانتظار بدء الغرفة';

  final int roundNumber;
  final MultiplayerRoomPhase phase;
  final String? activePlayerId;
  final List<String> outsiderIds;
  final DateTime? phaseEndsAt;
  final int requiredVotes;
  final int submittedVotes;
  final String? mostVotedPlayerId;
  final bool outsiderSurvived;
  final String statusLine;

  MultiplayerRoundState copyWith({
    int? roundNumber,
    MultiplayerRoomPhase? phase,
    Object? activePlayerId = _sentinel,
    List<String>? outsiderIds,
    Object? phaseEndsAt = _sentinel,
    int? requiredVotes,
    int? submittedVotes,
    Object? mostVotedPlayerId = _sentinel,
    bool? outsiderSurvived,
    String? statusLine,
  }) {
    return MultiplayerRoundState(
      roundNumber: roundNumber ?? this.roundNumber,
      phase: phase ?? this.phase,
      activePlayerId:
          identical(activePlayerId, _sentinel) ? this.activePlayerId : activePlayerId as String?,
      outsiderIds: outsiderIds ?? this.outsiderIds,
      phaseEndsAt:
          identical(phaseEndsAt, _sentinel) ? this.phaseEndsAt : phaseEndsAt as DateTime?,
      requiredVotes: requiredVotes ?? this.requiredVotes,
      submittedVotes: submittedVotes ?? this.submittedVotes,
      mostVotedPlayerId: identical(mostVotedPlayerId, _sentinel)
          ? this.mostVotedPlayerId
          : mostVotedPlayerId as String?,
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
    required this.hostPlayerId,
    required this.currentPlayerId,
    required this.players,
    required this.round,
    required this.privateView,
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
  final String hostPlayerId;
  final String currentPlayerId;
  final List<MultiplayerPlayer> players;
  final MultiplayerRoundState round;
  final MultiplayerPrivateView privateView;
  final String systemMessage;

  MultiplayerPlayer? get currentPlayer {
    return players.firstWhereOrNull((player) => player.id == currentPlayerId);
  }

  bool get isCurrentPlayerHost => currentPlayerId == hostPlayerId;

  bool get canStart {
    if (!isCurrentPlayerHost || players.length < 4) {
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
    String? hostPlayerId,
    String? currentPlayerId,
    List<MultiplayerPlayer>? players,
    MultiplayerRoundState? round,
    MultiplayerPrivateView? privateView,
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
      hostPlayerId: hostPlayerId ?? this.hostPlayerId,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      players: players ?? this.players,
      round: round ?? this.round,
      privateView: privateView ?? this.privateView,
      systemMessage: systemMessage ?? this.systemMessage,
    );
  }
}

const _sentinel = Object();
