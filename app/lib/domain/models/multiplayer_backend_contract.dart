enum MultiplayerSocketEvent {
  createRoomRequested('room.create.requested'),
  roomCreated('room.created'),
  joinRoomRequested('room.join.requested'),
  roomJoined('room.joined'),
  roomSnapshot('room.snapshot'),
  readyUpdated('room.ready.updated'),
  startGameRequested('game.start.requested'),
  privateRoleAssigned('game.private_role.assigned'),
  phaseAdvanced('game.phase.advanced'),
  voteSubmitted('game.vote.submitted'),
  voteReveal('game.vote.reveal'),
  outsiderGuessSubmitted('game.outsider_guess.submitted'),
  roundResolved('game.round.resolved'),
  scoreUpdated('game.score.updated'),
  playerDisconnected('room.player.disconnected'),
  playerReconnected('room.player.reconnected'),
  hostMigrated('room.host.migrated'),
  roomClosed('room.closed'),
  error('room.error');

  const MultiplayerSocketEvent(this.value);

  final String value;
}

class MultiplayerRestContract {
  static const createRoom = '/v1/multiplayer/rooms';
  static const joinRoom = '/v1/multiplayer/rooms/join';
  static const reconnectRoom = '/v1/multiplayer/rooms/reconnect';
  static const leaveRoom = '/v1/multiplayer/rooms/leave';

  const MultiplayerRestContract._();
}
