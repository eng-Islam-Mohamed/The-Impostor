import 'dart:async';

import 'package:bara_alsalfa/data/repositories/multiplayer_room_repository_provider.dart';
import 'package:bara_alsalfa/domain/models/multiplayer_room.dart';
import 'package:bara_alsalfa/features/multiplayer/application/multiplayer_config_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MultiplayerRoomController extends AsyncNotifier<MultiplayerRoomState?> {
  StreamSubscription<MultiplayerRoomState>? _subscription;

  @override
  FutureOr<MultiplayerRoomState?> build() {
    ref.onDispose(() => _subscription?.cancel());
    ref.listen(multiplayerClientConfigProvider, (previousConfig, nextConfig) {
      _subscription?.cancel();
      _subscription = null;
      state = const AsyncData(null);
    });
    return null;
  }

  Future<void> createRoom({
    required String displayName,
    required int avatarIndex,
    required String modeSlug,
    required String packId,
    required List<String> topicPool,
    required MultiplayerRoomVisibility visibility,
    required int maxPlayers,
    required int outsiderCount,
  }) async {
    state = const AsyncLoading();
    try {
      final room = await ref.read(multiplayerRoomRepositoryProvider).createRoom(
            displayName: displayName,
            avatarIndex: avatarIndex,
            modeSlug: modeSlug,
            packId: packId,
            topicPool: topicPool,
            visibility: visibility,
            maxPlayers: maxPlayers,
            outsiderCount: outsiderCount,
          );
      _bind(room);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> joinRoom({
    required String roomCode,
    required String displayName,
    required int avatarIndex,
  }) async {
    state = const AsyncLoading();
    try {
      final room = await ref.read(multiplayerRoomRepositoryProvider).joinRoom(
            roomCode: roomCode,
            displayName: displayName,
            avatarIndex: avatarIndex,
          );
      _bind(room);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> toggleReady() async {
    final room = state.asData?.value;
    final player = room?.currentPlayer;
    if (room == null || player == null) {
      return;
    }
    await ref.read(multiplayerRoomRepositoryProvider).toggleReady(
          roomId: room.roomId,
          playerId: player.id,
        );
  }

  Future<void> seedDemoPlayers() async {
    final room = state.asData?.value;
    if (room == null) {
      return;
    }
    await ref.read(multiplayerRoomRepositoryProvider).seedDemoPlayers(roomId: room.roomId);
  }

  Future<void> startGame() async {
    final room = state.asData?.value;
    final player = room?.currentPlayer;
    if (room == null || player == null) {
      return;
    }
    await ref.read(multiplayerRoomRepositoryProvider).startGame(
          roomId: room.roomId,
          playerId: player.id,
        );
  }

  Future<void> advancePrototypePhase() async {
    final room = state.asData?.value;
    if (room == null) {
      return;
    }
    await ref
        .read(multiplayerRoomRepositoryProvider)
        .advancePrototypePhase(roomId: room.roomId);
  }

  Future<void> submitVote(List<String> suspectIds) async {
    final room = state.asData?.value;
    final player = room?.currentPlayer;
    if (room == null || player == null || suspectIds.isEmpty) {
      return;
    }
    await ref.read(multiplayerRoomRepositoryProvider).submitVote(
          roomId: room.roomId,
          playerId: player.id,
          suspectIds: suspectIds,
        );
  }

  Future<void> submitOutsiderGuess(String guessedTopic) async {
    final room = state.asData?.value;
    final player = room?.currentPlayer;
    if (room == null || player == null) {
      return;
    }
    await ref.read(multiplayerRoomRepositoryProvider).submitOutsiderGuess(
          roomId: room.roomId,
          playerId: player.id,
          guessedTopic: guessedTopic,
        );
  }

  Future<void> leaveRoom() async {
    final room = state.asData?.value;
    final player = room?.currentPlayer;
    if (room == null || player == null) {
      state = const AsyncData(null);
      return;
    }
    await ref.read(multiplayerRoomRepositoryProvider).leaveRoom(
          roomId: room.roomId,
          playerId: player.id,
        );
    await _subscription?.cancel();
    _subscription = null;
    state = const AsyncData(null);
  }

  Future<void> banPlayer(String targetPlayerId) async {
    final room = state.asData?.value;
    final player = room?.currentPlayer;
    if (room == null || player == null) {
      return;
    }
    await ref.read(multiplayerRoomRepositoryProvider).banPlayer(
          roomId: room.roomId,
          hostPlayerId: player.id,
          targetPlayerId: targetPlayerId,
        );
  }

  Future<void> sendChatMessage(String text) async {
    final room = state.asData?.value;
    final player = room?.currentPlayer;
    final trimmed = text.trim();
    if (room == null || player == null || trimmed.isEmpty) {
      return;
    }
    await ref.read(multiplayerRoomRepositoryProvider).sendChatMessage(
          roomId: room.roomId,
          playerId: player.id,
          text: trimmed,
        );
  }

  void clearError() {
    if (state.hasError) {
      state = const AsyncData(null);
    }
  }

  void _bind(MultiplayerRoomState room) {
    _subscription?.cancel();
    state = AsyncData(room);
    _subscription = ref
        .read(multiplayerRoomRepositoryProvider)
        .watchRoom(roomId: room.roomId, currentPlayerId: room.currentPlayerId)
        .listen(
      (nextRoom) {
        state = AsyncData(nextRoom);
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );
  }
}

final multiplayerRoomProvider =
    AsyncNotifierProvider<MultiplayerRoomController, MultiplayerRoomState?>(
  MultiplayerRoomController.new,
);
