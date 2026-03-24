import 'dart:async';
import 'dart:math';

import 'package:bara_alsalfa/domain/models/multiplayer_room.dart';
import 'package:bara_alsalfa/domain/repositories/multiplayer_room_repository.dart';

class FakeMultiplayerRoomRepository implements MultiplayerRoomRepository {
  final Random _random = Random();
  final Map<String, MultiplayerRoomState> _rooms = {};
  final Map<String, StreamController<MultiplayerRoomState>> _controllers = {};
  final Map<String, List<String>> _roomTopicPools = {};

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
      hostPlayerId: host.id,
      currentPlayerId: host.id,
      players: [host],
      round: const MultiplayerRoundState.empty(),
      privateView: const MultiplayerPrivateView.empty(),
      systemMessage: 'تم إنشاء الغرفة. شارك الكود وابدأ التجهيز.',
    );

    _rooms[roomId] = room;
    _roomTopicPools[roomId] = topicPool;
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
    );
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

    final topicPool = _roomTopicPools[roomId] ?? const <String>[];
    final outsider = room.players[_random.nextInt(room.players.length)];
    final topic = _pickTopic(topicPool, room.packId);
    final guessOptions = _guessOptions(topicPool, topic);

    final updated = room.copyWith(
      status: MultiplayerRoomStatus.inProgress,
      round: MultiplayerRoundState(
        roundNumber: 1,
        phase: MultiplayerRoomPhase.privateReveal,
        activePlayerId: room.players.first.id,
        outsiderIds: [outsider.id],
        phaseEndsAt: DateTime.now().add(const Duration(seconds: 45)),
        requiredVotes: room.players.length,
        submittedVotes: 0,
        mostVotedPlayerId: null,
        outsiderSurvived: false,
        statusLine: 'تم توزيع الأدوار الخاصة. كل لاعب يرى هاتفه فقط.',
      ),
      privateView: MultiplayerPrivateView(
        role: outsider.id == playerId
            ? MultiplayerPlayerRole.outsider
            : MultiplayerPlayerRole.insider,
        topicLabel: outsider.id == playerId ? null : topic,
        guessOptions: outsider.id == playerId ? guessOptions : const [],
        voteSubmitted: false,
        guessedTopic: null,
      ),
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
    if (room.players.length >= 4) {
      return;
    }

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
      MultiplayerRoomPhase.voting => round.outsiderSurvived
          ? MultiplayerRoomPhase.outsiderGuess
          : MultiplayerRoomPhase.voteReveal,
      MultiplayerRoomPhase.voteReveal => round.outsiderSurvived
          ? MultiplayerRoomPhase.outsiderGuess
          : MultiplayerRoomPhase.results,
      MultiplayerRoomPhase.outsiderGuess => MultiplayerRoomPhase.results,
      MultiplayerRoomPhase.results => MultiplayerRoomPhase.results,
    };

    final updated = room.copyWith(
      round: round.copyWith(
        phase: nextPhase,
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
    required String suspectId,
  }) async {
    final room = _requireRoom(roomId);
    final outsiderCaught = room.round.outsiderIds.contains(suspectId);
    final updated = room.copyWith(
      privateView: room.privateView.copyWith(voteSubmitted: true),
      round: room.round.copyWith(
        submittedVotes: (room.round.submittedVotes + 1).clamp(0, room.round.requiredVotes),
        mostVotedPlayerId: suspectId,
        outsiderSurvived: !outsiderCaught,
        phase: room.round.submittedVotes + 1 >= room.round.requiredVotes
            ? (outsiderCaught
                ? MultiplayerRoomPhase.results
                : MultiplayerRoomPhase.outsiderGuess)
            : room.round.phase,
        statusLine: outsiderCaught
            ? 'تم كشف برا السالفة في التصويت التجريبي.'
            : 'نجا برا السالفة وانتقل إلى شاشة التخمين.',
      ),
      systemMessage: 'تم تسجيل صوت اللاعب الحالي من الهاتف الخاص به.',
    );
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
    final correctTopic = room.privateView.guessOptions.isEmpty
        ? null
        : room.privateView.guessOptions.first;
    final isCorrect = guessedTopic == correctTopic;

    final updatedPlayers = [
      for (final player in room.players)
        if (player.id == playerId)
          player.copyWith(score: player.score + (isCorrect ? 2 : -1))
        else
          player,
    ];

    final updated = room.copyWith(
      players: updatedPlayers,
      privateView: room.privateView.copyWith(guessedTopic: guessedTopic),
      round: room.round.copyWith(
        phase: MultiplayerRoomPhase.results,
        statusLine: isCorrect
            ? 'خمن برا السالفة السالفة الصحيحة.'
            : 'فشل برا السالفة في التخمين النهائي.',
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

  MultiplayerRoomState _viewForPlayer(MultiplayerRoomState room, String currentPlayerId) {
    if (room.round.phase == MultiplayerRoomPhase.lobby || room.round.outsiderIds.isEmpty) {
      return room.copyWith(currentPlayerId: currentPlayerId);
    }

    final topicPool = _roomTopicPools[room.roomId] ?? const <String>[];
    final topic = _pickTopic(topicPool, room.packId);
    final isOutsider = room.round.outsiderIds.contains(currentPlayerId);
    return room.copyWith(
      currentPlayerId: currentPlayerId,
      privateView: MultiplayerPrivateView(
        role: isOutsider ? MultiplayerPlayerRole.outsider : MultiplayerPlayerRole.insider,
        topicLabel: isOutsider ? null : topic,
        guessOptions: isOutsider ? _guessOptions(topicPool, topic) : const [],
        voteSubmitted: room.privateView.voteSubmitted,
        guessedTopic: room.privateView.guessedTopic,
      ),
    );
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
    final options = <String>[topic];
    for (final candidate in topicPool) {
      if (candidate == topic || options.length >= 12) {
        continue;
      }
      options.add(candidate);
    }
    return options.toSet().toList(growable: false);
  }

  String _statusLineForPhase(MultiplayerRoomPhase phase) {
    return switch (phase) {
      MultiplayerRoomPhase.lobby => 'بانتظار اللاعبين',
      MultiplayerRoomPhase.privateReveal => 'الخادم يرسل الدور الخاص لكل هاتف.',
      MultiplayerRoomPhase.clueTurns => 'كل لاعب يتكلم من مكانه مع ترتيب دور واضح.',
      MultiplayerRoomPhase.discussion => 'النقاش حي بين كل الأجهزة.',
      MultiplayerRoomPhase.voting => 'التصويت خاص على كل هاتف.',
      MultiplayerRoomPhase.voteReveal => 'يتم الآن كشف نتيجة التصويت للجميع.',
      MultiplayerRoomPhase.outsiderGuess => 'برا السالفة وحده يرى شاشة التخمين.',
      MultiplayerRoomPhase.results => 'النقاط تمت مزامنتها للجميع.',
    };
  }
}
