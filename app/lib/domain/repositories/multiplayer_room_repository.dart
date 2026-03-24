import 'package:bara_alsalfa/domain/models/multiplayer_room.dart';

abstract class MultiplayerRoomRepository {
  Stream<MultiplayerRoomState> watchRoom({
    required String roomId,
    required String currentPlayerId,
  });

  Future<MultiplayerRoomState> createRoom({
    required String displayName,
    required int avatarIndex,
    required String modeSlug,
    required String packId,
    required List<String> topicPool,
    required MultiplayerRoomVisibility visibility,
    required int maxPlayers,
    required int outsiderCount,
  });

  Future<MultiplayerRoomState> joinRoom({
    required String roomCode,
    required String displayName,
    required int avatarIndex,
  });

  Future<void> toggleReady({
    required String roomId,
    required String playerId,
  });

  Future<void> startGame({
    required String roomId,
    required String playerId,
  });

  Future<void> seedDemoPlayers({
    required String roomId,
  });

  Future<void> advancePrototypePhase({
    required String roomId,
  });

  Future<void> submitVote({
    required String roomId,
    required String playerId,
    required List<String> suspectIds,
  });

  Future<void> submitOutsiderGuess({
    required String roomId,
    required String playerId,
    required String guessedTopic,
  });

  Future<void> leaveRoom({
    required String roomId,
    required String playerId,
  });

  Future<void> banPlayer({
    required String roomId,
    required String hostPlayerId,
    required String targetPlayerId,
  });

  Future<void> sendChatMessage({
    required String roomId,
    required String playerId,
    required String text,
  });
}
