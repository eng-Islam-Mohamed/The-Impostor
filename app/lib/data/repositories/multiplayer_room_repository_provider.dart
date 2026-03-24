import 'package:bara_alsalfa/data/repositories/fake_multiplayer_room_repository.dart';
import 'package:bara_alsalfa/data/repositories/socket_multiplayer_room_repository.dart';
import 'package:bara_alsalfa/domain/repositories/multiplayer_room_repository.dart';
import 'package:bara_alsalfa/features/multiplayer/application/multiplayer_config_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final multiplayerRoomRepositoryProvider = Provider<MultiplayerRoomRepository>((ref) {
  final config = ref.watch(multiplayerClientConfigProvider);
  final repository = config.useLiveServer
      ? SocketMultiplayerRoomRepository(
          serverUrl: config.serverUrl,
          clientId: config.clientId,
        )
      : FakeMultiplayerRoomRepository(clientId: config.clientId);

  ref.onDispose(() {
    if (repository is SocketMultiplayerRoomRepository) {
      repository.dispose();
    }
    if (repository is FakeMultiplayerRoomRepository) {
      repository.dispose();
    }
  });
  return repository;
});
