import 'dart:async';
import 'dart:math';

import 'package:bara_alsalfa/domain/models/multiplayer_room.dart';
import 'package:bara_alsalfa/domain/repositories/multiplayer_room_repository.dart';

class FakeMultiplayerRoomRepository implements MultiplayerRoomRepository {
  FakeMultiplayerRoomRepository({required this.clientId});

  final String clientId;
  final Random _random = Random();
  final Map<String, MultiplayerRoomState> _rooms = {};
  final Map<String, StreamController<MultiplayerRoomState>> _controllers = {};
  final Map<String, List<String>> _roomTopicPools = {};
  final Map<String, String> _roomTopics = {};
  final Map<String, Map<String, List<String>>> _roomVotes = {};
  final Map<String, Map<String, String>> _roomGuesses = {};
  final Map<String, Map<String, String>> _roomPlayerClientIds = {};
  final Map<String, Set<String>> _roomBannedClientIds = {};

  @override
  Stream<MultiplayerRoomState> watchRoom({
    required String roomId,
    required String currentPlayerId,
  }) async* {
    final room = _rooms[roomId];
    if (room != null) {
      yield _viewForPlayer(room, currentPlayerId);
    }
    final controller = _controllers.putIfAbsent(
      roomId,
      () => StreamController<MultiplayerRoomState>.broadcast(),
    );
    yield* controller.stream.map((state) => _viewForPlayer(state, currentPlayerId));
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
    final roomId = 'room-${DateTime.now().microsecondsSinceEpoch}';
    final playerId = 'player-${DateTime.now().millisecondsSinceEpoch}';
    final roomCode = _generateRoomCode();
    final host = MultiplayerPlayer(
      id: playerId,
      name: displayName,
      avatarIndex: avatarIndex,
      score: 0,
      isHost: true,
      isReady: true,
      connectionState: MultiplayerConnectionState.connected,
    );

    final room = MultiplayerRoomState(
      roomId: roomId,
      roomCode: roomCode,
      shareLink: 'bara://room/$roomCode',
      visibility: visibility,
      status: MultiplayerRoomStatus.lobby,
      modeSlug: modeSlug,
      packId: packId,
      maxPlayers: maxPlayers,
      outsiderCount: outsiderCount,
      hostPlayerId: host.id,
      currentPlayerId: host.id,
      players: [host],
      round: const MultiplayerRoundState.empty(),
      privateView: const MultiplayerPrivateView.empty(),
      chatMessages: const [],
      systemMessage: 'تم إنشاء الغرفة. شارك الكود وابدأ التجهيز.',
    );

    _rooms[roomId] = room;
    _roomTopicPools[roomId] = topicPool;
    _roomPlayerClientIds[roomId] = {host.id: clientId};
    _roomBannedClientIds[roomId] = <String>{};
    _roomVotes[roomId] = {};
    _roomGuesses[roomId] = {};
    _controllers.putIfAbsent(roomId, () => StreamController<MultiplayerRoomState>.broadcast());
    _emit(room);
    return _viewForPlayer(room, playerId);
  }

  @override
  Future<MultiplayerRoomState> joinRoom({
    required String roomCode,
    required String displayName,
    required int avatarIndex,
  }) async {
    final room = _rooms.values.firstWhere(
      (item) => item.roomCode.toUpperCase() == roomCode.trim().toUpperCase(),
      orElse: () => throw StateError('Room not found.'),
    );
    if (_roomBannedClientIds[room.roomId]?.contains(clientId) == true) {
      throw StateError('You were banned from this room.');
    }

    final nextPlayer = MultiplayerPlayer(
      id: 'player-${DateTime.now().microsecondsSinceEpoch}',
      name: displayName,
      avatarIndex: avatarIndex,
      score: 0,
      isHost: false,
      isReady: false,
      connectionState: MultiplayerConnectionState.connected,
    );

    final updated = room.copyWith(
      currentPlayerId: nextPlayer.id,
      players: [...room.players, nextPlayer],
      systemMessage: '$displayName انضم إلى الغرفة.',
      chatMessages: [
        ...room.chatMessages,
        _systemChatMessage('$displayName انضم إلى الغرفة.'),
      ],
    );
    _roomPlayerClientIds[room.roomId]![nextPlayer.id] = clientId;
    _rooms[room.roomId] = updated;
    _emit(updated);
    return _viewForPlayer(updated, nextPlayer.id);
  }

  @override
  Future<void> toggleReady({
    required String roomId,
    required String playerId,
  }) async {
    final room = _requireRoom(roomId);
    final updated = room.copyWith(
      players: [
        for (final player in room.players)
          if (player.id == playerId)
            player.copyWith(isReady: !player.isReady)
          else
            player,
      ],
      systemMessage: 'تم تحديث حالة الجاهزية.',
    );
    _rooms[roomId] = updated;
    _emit(updated);
  }

  @override
  Future<void> startGame({
    required String roomId,
    required String playerId,
  }) async {
    final room = _requireRoom(roomId);
    if (room.hostPlayerId != playerId) {
      throw StateError('Only the host can start the game.');
    }
    final minPlayers = multiplayerMinimumPlayersForMode(room.modeSlug);
    if (room.players.length < minPlayers) {
      throw StateError('At least $minPlayers players are required.');
    }

    final outsiderCount = room.outsiderCount.clamp(
      1,
      multiplayerMaxOutsidersForPlayerCount(room.players.length),
    );
    final topicPool = _roomTopicPools[roomId] ?? const <String>[];
    final topic = _pickTopic(topicPool, room.packId);
    final outsiderIds = [...room.players]..shuffle(_random);
    final selectedOutsiderIds = outsiderIds
        .take(outsiderCount)
        .map((player) => player.id)
        .toList(growable: false);
    _roomTopics[roomId] = topic;
    _roomVotes[roomId] = {};
    _roomGuesses[roomId] = {};

    final updated = room.copyWith(
      status: MultiplayerRoomStatus.inProgress,
      outsiderCount: outsiderCount,
      round: MultiplayerRoundState(
        roundNumber: room.round.roundNumber + 1,
        phase: MultiplayerRoomPhase.privateReveal,
        activePlayerId: room.players.first.id,
        outsiderIds: selectedOutsiderIds,
        survivingOutsiderIds: selectedOutsiderIds,
        accusedPlayerIds: const [],
        phaseEndsAt: DateTime.now().add(const Duration(seconds: 45)),
        requiredVotes: room.players.length,
        submittedVotes: 0,
        voteSelectionLimit: outsiderCount,
        outsiderSurvived: false,
        statusLine: 'تم توزيع الأدوار الخاصة. كل لاعب يرى هاتفه فقط.',
      ),
      chatMessages: [
        ...room.chatMessages,
        _systemChatMessage('بدأت الجولة الحية.'),
      ],
      systemMessage: 'بدأت الجولة. التزموا بالمزامنة الحية من الخادم.',
    );

    _rooms[roomId] = updated;
    _emit(updated);
  }

  @override
  Future<void> seedDemoPlayers({
    required String roomId,
  }) async {
    final room = _requireRoom(roomId);
    final demoPlayers = <MultiplayerPlayer>[
      const MultiplayerPlayer(
        id: 'demo-sara',
        name: 'سارة',
        avatarIndex: 1,
        score: 3,
        isHost: false,
        isReady: true,
        connectionState: MultiplayerConnectionState.connected,
      ),
      const MultiplayerPlayer(
        id: 'demo-omar',
        name: 'عمر',
        avatarIndex: 2,
        score: 1,
        isHost: false,
        isReady: true,
        connectionState: MultiplayerConnectionState.connected,
      ),
      const MultiplayerPlayer(
        id: 'demo-lina',
        name: 'لينا',
        avatarIndex: 3,
        score: 2,
        isHost: false,
        isReady: true,
        connectionState: MultiplayerConnectionState.connected,
      ),
    ];

    final existingIds = room.players.map((player) => player.id).toSet();
    final merged = [
      ...room.players,
      ...demoPlayers.where((player) => !existingIds.contains(player.id)),
    ];

    final updated = room.copyWith(
      players: merged.take(room.maxPlayers).toList(growable: false),
      systemMessage: 'تمت إضافة لاعبين تجريبيين لعرض تدفق الغرفة.',
    );
    _rooms[roomId] = updated;
    _emit(updated);
  }

  @override
  Future<void> advancePrototypePhase({
    required String roomId,
  }) async {
    final room = _requireRoom(roomId);
    final round = room.round;
    final nextPhase = switch (round.phase) {
      MultiplayerRoomPhase.lobby => MultiplayerRoomPhase.privateReveal,
      MultiplayerRoomPhase.privateReveal => MultiplayerRoomPhase.clueTurns,
      MultiplayerRoomPhase.clueTurns => MultiplayerRoomPhase.discussion,
      MultiplayerRoomPhase.discussion => MultiplayerRoomPhase.voting,
      MultiplayerRoomPhase.voting => MultiplayerRoomPhase.voteReveal,
      MultiplayerRoomPhase.voteReveal =>
        round.outsiderIds.isNotEmpty ? MultiplayerRoomPhase.outsiderGuess : MultiplayerRoomPhase.results,
      MultiplayerRoomPhase.outsiderGuess => MultiplayerRoomPhase.results,
      MultiplayerRoomPhase.results => MultiplayerRoomPhase.results,
    };

    final updated = room.copyWith(
      round: round.copyWith(
        phase: nextPhase,
        activePlayerId: nextPhase == MultiplayerRoomPhase.outsiderGuess
            ? (round.outsiderIds.isEmpty ? null : round.outsiderIds.first)
            : round.activePlayerId,
        phaseEndsAt: DateTime.now().add(const Duration(seconds: 30)),
        statusLine: _statusLineForPhase(nextPhase),
      ),
      systemMessage: 'تحول النموذج إلى مرحلة ${nextPhase.name}.',
    );
    _rooms[roomId] = updated;
    _emit(updated);
  }

  @override
  Future<void> submitVote({
    required String roomId,
    required String playerId,
    required List<String> suspectIds,
  }) async {
    final room = _requireRoom(roomId);
    if (room.round.phase != MultiplayerRoomPhase.voting) {
      throw StateError('Voting is not open.');
    }
    if (suspectIds.length != room.round.voteSelectionLimit) {
      throw StateError('You must select ${room.round.voteSelectionLimit} suspects.');
    }
    if (suspectIds.toSet().length != suspectIds.length) {
      throw StateError('Duplicate suspects are not allowed.');
    }
    if (suspectIds.contains(playerId)) {
      throw StateError('Player cannot vote for themselves.');
    }

    final votes = Map<String, List<String>>.from(_roomVotes[roomId] ?? {});
    if (votes.containsKey(playerId)) {
      throw StateError('Vote already submitted.');
    }
    votes[playerId] = suspectIds;
    _roomVotes[roomId] = votes;

    final updatedRound = room.round.copyWith(
      submittedVotes: votes.length,
      statusLine: 'تم استلام تصويت جديد في الغرفة.',
    );
    var updated = room.copyWith(
      round: updatedRound,
      systemMessage: 'تم تسجيل تصويت اللاعب الحالي من الهاتف الخاص به.',
    );

    if (votes.length >= room.players.length) {
      updated = _resolveVotes(updated);
    }

    _rooms[roomId] = updated;
    _emit(updated);
  }

  @override
  Future<void> submitOutsiderGuess({
    required String roomId,
    required String playerId,
    required String guessedTopic,
  }) async {
    final room = _requireRoom(roomId);
    final currentTopic = _roomTopics[roomId];
    if (room.round.phase != MultiplayerRoomPhase.outsiderGuess ||
        room.round.activePlayerId != playerId ||
        currentTopic == null) {
      throw StateError('Outsider guess phase is not open.');
    }

    final guesses = Map<String, String>.from(_roomGuesses[roomId] ?? {});
    guesses[playerId] = guessedTopic;
    _roomGuesses[roomId] = guesses;
    final isCorrect = guessedTopic == currentTopic;

    final updatedPlayers = [
      for (final player in room.players)
        if (player.id == playerId)
          player.copyWith(score: player.score + (isCorrect ? 1 : -1))
        else
          player,
    ];
    final remainingGuessers = room.round.outsiderIds
        .where((outsiderId) => !guesses.containsKey(outsiderId))
        .toList(growable: false);

    final nextPhase = remainingGuessers.isEmpty
        ? MultiplayerRoomPhase.results
        : MultiplayerRoomPhase.outsiderGuess;
    final updated = room.copyWith(
      players: updatedPlayers,
      round: room.round.copyWith(
        phase: nextPhase,
        activePlayerId: remainingGuessers.isEmpty ? null : remainingGuessers.first,
        phaseEndsAt: remainingGuessers.isEmpty
            ? null
            : DateTime.now().add(const Duration(seconds: 20)),
        statusLine: remainingGuessers.isEmpty
            ? 'تم إنهاء الجولة وإرسال النقاط للجميع.'
            : 'انتقل التخمين الآن إلى برا السالفة التالي.',
      ),
      systemMessage: 'وصل تخمين برا السالفة من هاتفه وتمت مزامنة النتيجة.',
    );

    _rooms[roomId] = updated;
    _emit(updated);
  }

  @override
  Future<void> leaveRoom({
    required String roomId,
    required String playerId,
  }) async {
    final room = _requireRoom(roomId);
    final remaining =
        room.players.where((player) => player.id != playerId).toList(growable: false);
    if (remaining.isEmpty) {
      _rooms.remove(roomId);
      _roomTopicPools.remove(roomId);
      _roomTopics.remove(roomId);
      _roomVotes.remove(roomId);
      _roomGuesses.remove(roomId);
      _roomPlayerClientIds.remove(roomId);
      _roomBannedClientIds.remove(roomId);
      await _controllers.remove(roomId)?.close();
      return;
    }

    final nextHost = remaining.any((player) => player.id == room.hostPlayerId)
        ? room.hostPlayerId
        : remaining.first.id;

    final updated = room.copyWith(
      hostPlayerId: nextHost,
      players: [
        for (final player in remaining)
          if (player.id == nextHost)
            player.copyWith(isHost: true)
          else
            player.copyWith(isHost: false),
      ],
      currentPlayerId: remaining.first.id,
      systemMessage: 'غادر أحد اللاعبين وتم تحديث المضيف إذا لزم الأمر.',
    );
    _roomVotes[roomId]?.remove(playerId);
    _roomGuesses[roomId]?.remove(playerId);
    _roomPlayerClientIds[roomId]?.remove(playerId);
    _rooms[roomId] = updated;
    _emit(updated);
  }

  @override
  Future<void> banPlayer({
    required String roomId,
    required String hostPlayerId,
    required String targetPlayerId,
  }) async {
    final room = _requireRoom(roomId);
    if (room.hostPlayerId != hostPlayerId) {
      throw StateError('Only the host can ban players.');
    }
    if (hostPlayerId == targetPlayerId) {
      throw StateError('Host cannot ban themselves.');
    }
    final target = room.players.firstWhere(
      (player) => player.id == targetPlayerId,
      orElse: () => throw StateError('Player not found.'),
    );
    final targetClientId = _roomPlayerClientIds[roomId]?[target.id];
    if (targetClientId != null) {
      _roomBannedClientIds[roomId]?.add(targetClientId);
    }
    await leaveRoom(roomId: roomId, playerId: targetPlayerId);
    final updated = _requireRoom(roomId).copyWith(
      systemMessage: 'تم حظر ${target.name} من الغرفة.',
      chatMessages: [
        ..._requireRoom(roomId).chatMessages,
        _systemChatMessage('قام المضيف بحظر ${target.name}.'),
      ],
    );
    _rooms[roomId] = updated;
    _emit(updated);
  }

  @override
  Future<void> sendChatMessage({
    required String roomId,
    required String playerId,
    required String text,
  }) async {
    final room = _requireRoom(roomId);
    final player = room.players.firstWhere(
      (item) => item.id == playerId,
      orElse: () => throw StateError('Player not found.'),
    );
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final updated = room.copyWith(
      chatMessages: [
        ...room.chatMessages,
        MultiplayerChatMessage(
          id: 'chat-${DateTime.now().microsecondsSinceEpoch}',
          senderPlayerId: player.id,
          senderName: player.name,
          text: trimmed,
          sentAt: DateTime.now(),
          isSystem: false,
        ),
      ],
      systemMessage: 'وصلت رسالة جديدة إلى الغرفة.',
    );
    _rooms[roomId] = updated;
    _emit(updated);
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  void _emit(MultiplayerRoomState room) {
    final controller = _controllers.putIfAbsent(
      room.roomId,
      () => StreamController<MultiplayerRoomState>.broadcast(),
    );
    controller.add(room);
  }

  MultiplayerRoomState _requireRoom(String roomId) {
    final room = _rooms[roomId];
    if (room == null) {
      throw StateError('Room not found.');
    }
    return room;
  }

  MultiplayerRoomState _resolveVotes(MultiplayerRoomState room) {
    final votes = _roomVotes[room.roomId] ?? const <String, List<String>>{};
    final counts = <String, int>{};
    for (final suspectIds in votes.values) {
      for (final suspectId in suspectIds) {
        counts.update(suspectId, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    final accusedPlayerIds = counts.entries.toList()
      ..sort((left, right) {
        final byVotes = right.value.compareTo(left.value);
        if (byVotes != 0) {
          return byVotes;
        }
        return left.key.compareTo(right.key);
      });
    final revealedIds = accusedPlayerIds
        .take(room.round.voteSelectionLimit)
        .map((entry) => entry.key)
        .toList(growable: false);
    final outsiderSet = room.round.outsiderIds.toSet();
    final survivingOutsiderIds = room.round.outsiderIds
        .where((outsiderId) => !revealedIds.contains(outsiderId))
        .toList(growable: false);

    final updatedPlayers = [
      for (final player in room.players)
        if (outsiderSet.contains(player.id))
          player
        else
          player.copyWith(
            score: player.score + _voteDelta(votes[player.id] ?? const [], outsiderSet),
          ),
    ];

    return room.copyWith(
      players: updatedPlayers,
      round: room.round.copyWith(
        phase: MultiplayerRoomPhase.voteReveal,
        accusedPlayerIds: revealedIds,
        survivingOutsiderIds: survivingOutsiderIds,
        outsiderSurvived: survivingOutsiderIds.isNotEmpty,
        statusLine: survivingOutsiderIds.isEmpty
            ? 'تم كشف كل برا السالفة في التصويت.'
            : 'نجا بعض برا السالفة وانتقلوا إلى التخمين.',
      ),
      systemMessage: 'تم حسم التصويت الحي.',
    );
  }

  MultiplayerRoomState _viewForPlayer(MultiplayerRoomState room, String currentPlayerId) {
    if (room.round.phase == MultiplayerRoomPhase.lobby || room.round.outsiderIds.isEmpty) {
      return room.copyWith(
        currentPlayerId: currentPlayerId,
        privateView: const MultiplayerPrivateView.empty(),
      );
    }

    final topicPool = _roomTopicPools[room.roomId] ?? const <String>[];
    final topic = _roomTopics[room.roomId] ?? _pickTopic(topicPool, room.packId);
    final isOutsider = room.round.outsiderIds.contains(currentPlayerId);
    final guesses = _roomGuesses[room.roomId] ?? const <String, String>{};
    final votes = _roomVotes[room.roomId] ?? const <String, List<String>>{};
    final canGuessNow = room.round.phase == MultiplayerRoomPhase.outsiderGuess &&
        room.round.activePlayerId == currentPlayerId &&
        room.round.outsiderIds.contains(currentPlayerId);

    return room.copyWith(
      currentPlayerId: currentPlayerId,
      privateView: MultiplayerPrivateView(
        role: isOutsider ? MultiplayerPlayerRole.outsider : MultiplayerPlayerRole.insider,
        topicLabel: isOutsider ? null : topic,
        guessOptions: canGuessNow ? _guessOptions(topicPool, topic) : const [],
        voteSubmitted: votes.containsKey(currentPlayerId),
        guessedTopic: guesses[currentPlayerId],
        submittedSuspectIds: votes[currentPlayerId] ?? const [],
      ),
    );
  }

  MultiplayerChatMessage _systemChatMessage(String text) {
    return MultiplayerChatMessage(
      id: 'system-${DateTime.now().microsecondsSinceEpoch}',
      senderPlayerId: 'system',
      senderName: 'النظام',
      text: text,
      sentAt: DateTime.now(),
      isSystem: true,
    );
  }

  int _voteDelta(List<String> suspectIds, Set<String> outsiderSet) {
    var delta = 0;
    for (final suspectId in suspectIds) {
      delta += outsiderSet.contains(suspectId) ? 1 : -1;
    }
    return delta;
  }

  String _generateRoomCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      6,
      (_) => alphabet[_random.nextInt(alphabet.length)],
    ).join();
  }

  String _pickTopic(List<String> topicPool, String packId) {
    if (topicPool.isNotEmpty) {
      return topicPool[_random.nextInt(topicPool.length)];
    }
    return switch (packId) {
      'countries' => 'المغرب',
      'historical-people' => 'صلاح الدين الأيوبي',
      _ => 'السالفة السرية',
    };
  }

  List<String> _guessOptions(List<String> topicPool, String topic) {
    final shuffled = topicPool.where((item) => item != topic).toList(growable: true)
      ..shuffle(_random);
    return {topic, ...shuffled.take(14)}.toList(growable: false);
  }

  String _statusLineForPhase(MultiplayerRoomPhase phase) {
    return switch (phase) {
      MultiplayerRoomPhase.lobby => 'بانتظار اللاعبين',
      MultiplayerRoomPhase.privateReveal => 'الخادم يرسل الدور الخاص لكل هاتف.',
      MultiplayerRoomPhase.clueTurns => 'كل لاعب يتكلم من مكانه مع ترتيب دور واضح.',
      MultiplayerRoomPhase.discussion => 'النقاش حي بين كل الأجهزة.',
      MultiplayerRoomPhase.voting => 'التصويت خاص على كل هاتف.',
      MultiplayerRoomPhase.voteReveal => 'يتم الآن كشف نتيجة التصويت للجميع.',
      MultiplayerRoomPhase.outsiderGuess => 'برا السالفة الناجي وحده يرى شاشة التخمين.',
      MultiplayerRoomPhase.results => 'النقاط تمت مزامنتها للجميع.',
    };
  }
}
