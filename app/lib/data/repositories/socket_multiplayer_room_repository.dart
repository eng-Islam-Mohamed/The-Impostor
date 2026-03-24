import 'dart:async';

import 'package:bara_alsalfa/domain/models/multiplayer_room.dart';
import 'package:bara_alsalfa/domain/repositories/multiplayer_room_repository.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketMultiplayerRoomRepository implements MultiplayerRoomRepository {
  SocketMultiplayerRoomRepository({
    required this.serverUrl,
    required this.clientId,
  });

  final String serverUrl;
  final String clientId;

  io.Socket? _socket;
  StreamController<MultiplayerRoomState>? _roomController;
  MultiplayerRoomState? _latestRoom;

  @override
  Stream<MultiplayerRoomState> watchRoom({
    required String roomId,
    required String currentPlayerId,
  }) {
    final controller = _roomController ??= StreamController<MultiplayerRoomState>.broadcast();
    if (_latestRoom != null) {
      Future<void>.microtask(() => controller.add(_latestRoom!));
    }
    return controller.stream;
  }

  @override
  Future<MultiplayerRoomState> createRoom({
    required String displayName,
    required int avatarIndex,
    required String modeSlug,
    required String packId,
    required List<String> topicPool,
    required MultiplayerRoomVisibility visibility,
    required int maxPlayers,
    required int outsiderCount,
  }) async {
    await _ensureConnected();
    final response = await _emitWithAck(
      'room.create.requested',
      {
        'displayName': displayName,
        'avatarIndex': avatarIndex,
        'clientId': clientId,
        'modeSlug': modeSlug,
        'packId': packId,
        'topicPool': topicPool,
        'visibility': visibility.name,
        'maxPlayers': maxPlayers,
        'outsiderCount': outsiderCount,
      },
    );
    return _acceptRoomResponse(response);
  }

  @override
  Future<MultiplayerRoomState> joinRoom({
    required String roomCode,
    required String displayName,
    required int avatarIndex,
  }) async {
    await _ensureConnected();
    final response = await _emitWithAck(
      'room.join.requested',
      {
        'roomCode': roomCode,
        'displayName': displayName,
        'avatarIndex': avatarIndex,
        'clientId': clientId,
      },
    );
    return _acceptRoomResponse(response);
  }

  @override
  Future<void> toggleReady({
    required String roomId,
    required String playerId,
  }) async {
    await _emitAction(
      'room.ready.updated',
      {
        'roomId': roomId,
        'playerId': playerId,
      },
    );
  }

  @override
  Future<void> startGame({
    required String roomId,
    required String playerId,
  }) async {
    await _emitAction(
      'game.start.requested',
      {
        'roomId': roomId,
        'playerId': playerId,
      },
    );
  }

  @override
  Future<void> seedDemoPlayers({
    required String roomId,
  }) async {
    await _emitAction(
      'room.seed_demo.requested',
      {
        'roomId': roomId,
      },
    );
  }

  @override
  Future<void> advancePrototypePhase({
    required String roomId,
  }) async {
    await _emitAction(
      'game.phase.advance.requested',
      {
        'roomId': roomId,
      },
    );
  }

  @override
  Future<void> submitVote({
    required String roomId,
    required String playerId,
    required List<String> suspectIds,
  }) async {
    await _emitAction(
      'game.vote.submitted',
      {
        'roomId': roomId,
        'playerId': playerId,
        'suspectIds': suspectIds,
      },
    );
  }

  @override
  Future<void> submitOutsiderGuess({
    required String roomId,
    required String playerId,
    required String guessedTopic,
  }) async {
    await _emitAction(
      'game.outsider_guess.submitted',
      {
        'roomId': roomId,
        'playerId': playerId,
        'guessedTopic': guessedTopic,
      },
    );
  }

  @override
  Future<void> leaveRoom({
    required String roomId,
    required String playerId,
  }) async {
    if (_socket == null) {
      return;
    }
    await _emitAction(
      'room.leave.requested',
      {
        'roomId': roomId,
        'playerId': playerId,
      },
    );
    _latestRoom = null;
  }

  @override
  Future<void> banPlayer({
    required String roomId,
    required String hostPlayerId,
    required String targetPlayerId,
  }) async {
    await _emitAction(
      'room.player.ban.requested',
      {
        'roomId': roomId,
        'hostPlayerId': hostPlayerId,
        'targetPlayerId': targetPlayerId,
      },
    );
  }

  @override
  Future<void> sendChatMessage({
    required String roomId,
    required String playerId,
    required String text,
  }) async {
    await _emitAction(
      'room.chat.sent',
      {
        'roomId': roomId,
        'playerId': playerId,
        'text': text,
      },
    );
  }

  Future<void> dispose() async {
    await _roomController?.close();
    _roomController = null;
    _socket?.dispose();
    _socket = null;
  }

  Future<void> _ensureConnected() async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    final completer = Completer<void>();
    final socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1200)
          .build(),
    );

    socket.onConnect((_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    socket.onConnectError((error) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('Connection failed: $error'));
      }
    });
    socket.onError((error) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('Socket error: $error'));
      }
    });
    socket.on('room.snapshot', (payload) {
      final room = _roomFromJson(payload as Map<String, dynamic>);
      _latestRoom = room;
      _roomController?.add(room);
    });
    socket.on('room.error', (payload) {
      final message = payload is Map<String, dynamic>
          ? payload['message']?.toString() ?? 'Room error'
          : payload.toString();
      _roomController?.addError(StateError(message));
    });
    socket.on('room.access.revoked', (payload) {
      final message = payload is Map<String, dynamic>
          ? payload['message']?.toString() ?? 'Your access to this room was revoked.'
          : 'Your access to this room was revoked.';
      _latestRoom = null;
      _roomController?.addError(StateError(message));
    });
    socket.connect();
    _socket = socket;
    await completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => throw StateError('Connection timed out.'),
    );
  }

  Future<Map<String, dynamic>> _emitWithAck(
    String event,
    Map<String, dynamic> payload,
  ) async {
    final socket = _socket;
    if (socket == null) {
      throw StateError('Socket is not connected.');
    }

    final completer = Completer<Map<String, dynamic>>();
    socket.emitWithAck(
      event,
      payload,
      ack: (data) {
        if (data is Map<String, dynamic>) {
          if (data['ok'] == false) {
            completer.completeError(StateError(data['message']?.toString() ?? 'Request failed.'));
            return;
          }
          completer.complete(data);
          return;
        }
        completer.completeError(StateError('Unexpected server response.'));
      },
    );
    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => throw StateError('Server did not acknowledge in time.'),
    );
  }

  Future<void> _emitAction(String event, Map<String, dynamic> payload) async {
    await _ensureConnected();
    await _emitWithAck(event, payload);
  }

  MultiplayerRoomState _acceptRoomResponse(Map<String, dynamic> response) {
    final room = _roomFromJson(response['room'] as Map<String, dynamic>);
    _latestRoom = room;
    return room;
  }

  MultiplayerRoomState _roomFromJson(Map<String, dynamic> json) {
    final round = json['round'] as Map<String, dynamic>? ?? const {};
    final privateView = json['privateView'] as Map<String, dynamic>? ?? const {};

    return MultiplayerRoomState(
      roomId: json['roomId'] as String,
      roomCode: json['roomCode'] as String,
      shareLink: json['shareLink'] as String? ?? '',
      visibility: _visibilityFromString(json['visibility'] as String?),
      status: _statusFromString(json['status'] as String?),
      modeSlug: json['modeSlug'] as String? ?? 'classic',
      packId: json['packId'] as String? ?? 'countries',
      maxPlayers: json['maxPlayers'] as int? ?? 8,
      outsiderCount: json['outsiderCount'] as int? ?? 1,
      hostPlayerId: json['hostPlayerId'] as String,
      currentPlayerId: json['currentPlayerId'] as String,
      players: ((json['players'] as List<dynamic>?) ?? const [])
          .map((item) => _playerFromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      round: MultiplayerRoundState(
        roundNumber: round['roundNumber'] as int? ?? 0,
        phase: _phaseFromString(round['phase'] as String?),
        activePlayerId: round['activePlayerId'] as String?,
        outsiderIds: ((round['outsiderIds'] as List<dynamic>?) ?? const [])
            .map((item) => item.toString())
            .toList(growable: false),
        survivingOutsiderIds: ((round['survivingOutsiderIds'] as List<dynamic>?) ?? const [])
            .map((item) => item.toString())
            .toList(growable: false),
        accusedPlayerIds: ((round['accusedPlayerIds'] as List<dynamic>?) ?? const [])
            .map((item) => item.toString())
            .toList(growable: false),
        phaseEndsAt: round['phaseEndsAt'] == null
            ? null
            : DateTime.tryParse(round['phaseEndsAt'].toString()),
        requiredVotes: round['requiredVotes'] as int? ?? 0,
        submittedVotes: round['submittedVotes'] as int? ?? 0,
        voteSelectionLimit: round['voteSelectionLimit'] as int? ?? 1,
        outsiderSurvived: round['outsiderSurvived'] as bool? ?? false,
        statusLine: round['statusLine'] as String? ?? '',
      ),
      privateView: MultiplayerPrivateView(
        role: _roleFromString(privateView['role'] as String?),
        topicLabel: privateView['topicLabel'] as String?,
        guessOptions: ((privateView['guessOptions'] as List<dynamic>?) ?? const [])
            .map((item) => item.toString())
            .toList(growable: false),
        voteSubmitted: privateView['voteSubmitted'] as bool? ?? false,
        guessedTopic: privateView['guessedTopic'] as String?,
        submittedSuspectIds: ((privateView['submittedSuspectIds'] as List<dynamic>?) ?? const [])
            .map((item) => item.toString())
            .toList(growable: false),
      ),
      chatMessages: ((json['chatMessages'] as List<dynamic>?) ?? const [])
          .map((item) => _chatMessageFromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      systemMessage: json['systemMessage'] as String? ?? '',
    );
  }

  MultiplayerPlayer _playerFromJson(Map<String, dynamic> json) {
    return MultiplayerPlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarIndex: json['avatarIndex'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      isHost: json['isHost'] as bool? ?? false,
      isReady: json['isReady'] as bool? ?? false,
      connectionState: _connectionFromString(json['connectionState'] as String?),
    );
  }

  MultiplayerChatMessage _chatMessageFromJson(Map<String, dynamic> json) {
    return MultiplayerChatMessage(
      id: json['id'] as String,
      senderPlayerId: json['senderPlayerId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      sentAt: DateTime.tryParse(json['sentAt']?.toString() ?? '') ?? DateTime.now(),
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  MultiplayerRoomVisibility _visibilityFromString(String? value) {
    return value == MultiplayerRoomVisibility.publicRoom.name
        ? MultiplayerRoomVisibility.publicRoom
        : MultiplayerRoomVisibility.privateRoom;
  }

  MultiplayerRoomStatus _statusFromString(String? value) {
    return MultiplayerRoomStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => MultiplayerRoomStatus.lobby,
    );
  }

  MultiplayerRoomPhase _phaseFromString(String? value) {
    return MultiplayerRoomPhase.values.firstWhere(
      (item) => item.name == value,
      orElse: () => MultiplayerRoomPhase.lobby,
    );
  }

  MultiplayerPlayerRole? _roleFromString(String? value) {
    if (value == null) {
      return null;
    }
    return MultiplayerPlayerRole.values.firstWhere(
      (item) => item.name == value,
      orElse: () => MultiplayerPlayerRole.insider,
    );
  }

  MultiplayerConnectionState _connectionFromString(String? value) {
    return MultiplayerConnectionState.values.firstWhere(
      (item) => item.name == value,
      orElse: () => MultiplayerConnectionState.connected,
    );
  }
}
