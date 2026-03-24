import cors from 'cors';
import express from 'express';
import http from 'http';
import { Server } from 'socket.io';

type RoomVisibility = 'privateRoom' | 'publicRoom';
type RoomStatus = 'lobby' | 'inProgress' | 'completed' | 'closed';
type RoomPhase =
  | 'lobby'
  | 'privateReveal'
  | 'clueTurns'
  | 'discussion'
  | 'voting'
  | 'voteReveal'
  | 'outsiderGuess'
  | 'results';
type PlayerRole = 'insider' | 'outsider';
type ConnectionState = 'connected' | 'reconnecting' | 'disconnected';

interface ServerPlayer {
  id: string;
  clientId: string;
  socketId?: string;
  name: string;
  avatarIndex: number;
  score: number;
  isHost: boolean;
  isReady: boolean;
  connectionState: ConnectionState;
}

interface ServerChatMessage {
  id: string;
  senderPlayerId: string;
  senderName: string;
  text: string;
  sentAt: string;
  isSystem: boolean;
}

interface ServerRound {
  roundNumber: number;
  phase: RoomPhase;
  activePlayerId: string | null;
  outsiderIds: string[];
  survivingOutsiderIds: string[];
  accusedPlayerIds: string[];
  phaseEndsAt: string | null;
  requiredVotes: number;
  submittedVotes: number;
  voteSelectionLimit: number;
  outsiderSurvived: boolean;
  statusLine: string;
  topic: string | null;
  topicPool: string[];
  guessOptions: string[];
  votes: Record<string, string[]>;
  guessedTopicByPlayer: Record<string, string>;
}

interface ServerRoom {
  roomId: string;
  roomCode: string;
  shareLink: string;
  visibility: RoomVisibility;
  status: RoomStatus;
  modeSlug: string;
  packId: string;
  maxPlayers: number;
  outsiderCount: number;
  hostPlayerId: string;
  players: ServerPlayer[];
  round: ServerRound;
  chatMessages: ServerChatMessage[];
  bannedClientIds: string[];
  systemMessage: string;
}

const port = Number(process.env.PORT ?? 8080);
const publicBaseUrl = (process.env.PUBLIC_BASE_URL ?? '').trim();
const corsOrigin = process.env.CORS_ORIGIN?.trim();

const app = express();
app.use(
  cors({
    origin: corsOrigin && corsOrigin.length > 0 ? corsOrigin : '*',
  }),
);
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    service: 'bara-alsalfa-multiplayer',
    timestamp: new Date().toISOString(),
  });
});

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: corsOrigin && corsOrigin.length > 0 ? corsOrigin : '*',
  },
});

const rooms = new Map<string, ServerRoom>();

io.on('connection', (socket) => {
  socket.on('room.create.requested', (payload, ack) => {
    try {
      const room = createRoom(payload, socket.id);
      emitRoom(room);
      ack?.({ ok: true, room: buildRoomView(room, room.hostPlayerId) });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('room.join.requested', (payload, ack) => {
    try {
      const room = joinRoom(payload, socket.id);
      emitRoom(room);
      const player = room.players.find((item) => item.socketId === socket.id);
      ack?.({
        ok: true,
        room: buildRoomView(room, player?.id ?? room.hostPlayerId),
      });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('room.ready.updated', (payload, ack) => {
    try {
      const room = requireRoom(payload.roomId);
      const player = requirePlayer(room, payload.playerId);
      player.isReady = !player.isReady;
      room.systemMessage = 'تم تحديث حالة الجاهزية.';
      pushSystemMessage(room, `${player.name} ${player.isReady ? 'أصبح جاهزًا' : 'ألغى الجاهزية'}.`);
      emitRoom(room);
      ack?.({ ok: true });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('room.seed_demo.requested', (payload, ack) => {
    try {
      const room = requireRoom(payload.roomId);
      const host = requirePlayer(room, room.hostPlayerId);
      if (host.socketId !== socket.id) {
        throw new Error('Only the host can seed demo players.');
      }
      seedDemoPlayers(room);
      emitRoom(room);
      ack?.({ ok: true });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('game.start.requested', (payload, ack) => {
    try {
      const room = requireRoom(payload.roomId);
      const host = requirePlayer(room, payload.playerId);
      if (!host.isHost || host.socketId !== socket.id) {
        throw new Error('Only the host can start the game.');
      }
      startGame(room);
      emitRoom(room);
      ack?.({ ok: true });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('game.phase.advance.requested', (payload, ack) => {
    try {
      const room = requireRoom(payload.roomId);
      const host = requirePlayer(room, room.hostPlayerId);
      if (host.socketId !== socket.id) {
        throw new Error('Only the host can advance the phase.');
      }
      advancePhase(room);
      emitRoom(room);
      ack?.({ ok: true });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('game.vote.submitted', (payload, ack) => {
    try {
      const room = requireRoom(payload.roomId);
      const player = requirePlayer(room, payload.playerId);
      if (player.socketId !== socket.id) {
        throw new Error('Vote must come from the owning device.');
      }
      submitVote(room, player.id, payload.suspectIds);
      emitRoom(room);
      ack?.({ ok: true });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('game.outsider_guess.submitted', (payload, ack) => {
    try {
      const room = requireRoom(payload.roomId);
      const player = requirePlayer(room, payload.playerId);
      if (player.socketId !== socket.id) {
        throw new Error('Guess must come from the owning device.');
      }
      submitOutsiderGuess(room, player.id, String(payload.guessedTopic ?? ''));
      emitRoom(room);
      ack?.({ ok: true });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('room.player.ban.requested', (payload, ack) => {
    try {
      const room = requireRoom(payload.roomId);
      banPlayer(room, String(payload.hostPlayerId ?? ''), String(payload.targetPlayerId ?? ''), socket.id);
      emitRoom(room);
      ack?.({ ok: true });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('room.chat.sent', (payload, ack) => {
    try {
      const room = requireRoom(payload.roomId);
      const player = requirePlayer(room, payload.playerId);
      if (player.socketId !== socket.id) {
        throw new Error('Chat must come from the owning device.');
      }
      sendChatMessage(room, player, String(payload.text ?? ''));
      emitRoom(room);
      ack?.({ ok: true });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('room.leave.requested', (payload, ack) => {
    try {
      const room = requireRoom(payload.roomId);
      leaveRoom(room, String(payload.playerId ?? ''));
      ack?.({ ok: true });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('disconnect', () => {
    for (const room of rooms.values()) {
      const player = room.players.find((item) => item.socketId === socket.id);
      if (!player) {
        continue;
      }
      player.socketId = undefined;
      player.connectionState = 'disconnected';
      if (player.isHost) {
        migrateHost(room);
      }
      room.systemMessage = `${player.name} انقطع اتصاله.`;
      pushSystemMessage(room, `${player.name} انقطع اتصاله.`);
      emitRoom(room);
    }
  });
});

function createRoom(payload: Record<string, unknown>, socketId: string): ServerRoom {
  const roomId = randomId('room');
  const playerId = randomId('player');
  const roomCode = randomCode();
  const clientId = normalizeClientId(payload.clientId);
  const outsiderCount = normalizeOutsiderCount(payload.outsiderCount);
  const room: ServerRoom = {
    roomId,
    roomCode,
    shareLink: buildShareLink(roomCode),
    visibility: payload.visibility === 'publicRoom' ? 'publicRoom' : 'privateRoom',
    status: 'lobby',
    modeSlug: String(payload.modeSlug ?? 'classic'),
    packId: String(payload.packId ?? 'countries'),
    maxPlayers: Number(payload.maxPlayers ?? 8),
    outsiderCount,
    hostPlayerId: playerId,
    players: [
      {
        id: playerId,
        clientId,
        socketId,
        name: String(payload.displayName ?? 'المضيف'),
        avatarIndex: Number(payload.avatarIndex ?? 0),
        score: 0,
        isHost: true,
        isReady: true,
        connectionState: 'connected',
      },
    ],
    round: emptyRound(),
    chatMessages: [],
    bannedClientIds: [],
    systemMessage: 'تم إنشاء الغرفة. شارك الكود وابدأ التجهيز.',
  };
  room.round.topicPool = normalizeTopicPool(payload.topicPool);
  pushSystemMessage(room, 'تم إنشاء الغرفة. شارك الكود وابدأ التجهيز.');
  rooms.set(roomId, room);
  return room;
}

function joinRoom(payload: Record<string, unknown>, socketId: string): ServerRoom {
  const roomCode = String(payload.roomCode ?? '').trim().toUpperCase();
  const room = [...rooms.values()].find((item) => item.roomCode === roomCode);
  if (!room) {
    throw new Error('Room not found.');
  }
  if (room.players.length >= room.maxPlayers) {
    throw new Error('Room is full.');
  }
  const clientId = normalizeClientId(payload.clientId);
  if (room.bannedClientIds.includes(clientId)) {
    throw new Error('You were banned from this room.');
  }

  const displayName = String(payload.displayName ?? 'لاعب جديد');
  room.players.push({
    id: randomId('player'),
    clientId,
    socketId,
    name: displayName,
    avatarIndex: Number(payload.avatarIndex ?? 0),
    score: 0,
    isHost: false,
    isReady: false,
    connectionState: 'connected',
  });
  room.systemMessage = `${displayName} انضم إلى الغرفة.`;
  pushSystemMessage(room, `${displayName} انضم إلى الغرفة.`);
  return room;
}

function startGame(room: ServerRoom): void {
  const minimumPlayers = minimumPlayersForMode(room.modeSlug);
  if (room.players.length < minimumPlayers) {
    throw new Error(`At least ${minimumPlayers} players are required.`);
  }
  if (!room.players.every((player) => player.isReady || player.isHost)) {
    throw new Error('All players must be ready before starting.');
  }

  const outsiderCount = Math.min(
    Math.max(1, room.outsiderCount),
    maxOutsidersForPlayerCount(room.players.length),
  );
  const topic = pickTopic(room.round.topicPool, room.packId);
  const outsiders = [...room.players]
    .sort(() => Math.random() - 0.5)
    .slice(0, outsiderCount)
    .map((player) => player.id);
  room.status = 'inProgress';
  room.outsiderCount = outsiderCount;
  room.round = {
    roundNumber: room.round.roundNumber + 1,
    phase: 'privateReveal',
    activePlayerId: room.players[0]?.id ?? null,
    outsiderIds: outsiders,
    survivingOutsiderIds: outsiders,
    accusedPlayerIds: [],
    phaseEndsAt: secondsFromNow(45),
    requiredVotes: room.players.length,
    submittedVotes: 0,
    voteSelectionLimit: outsiderCount,
    outsiderSurvived: false,
    statusLine: 'تم توزيع الأدوار الخاصة. كل لاعب يرى هاتفه فقط.',
    topic,
    topicPool: room.round.topicPool,
    guessOptions: buildGuessOptions(room.round.topicPool, topic),
    votes: {},
    guessedTopicByPlayer: {},
  };
  room.systemMessage = 'بدأت الجولة. التزموا بالمزامنة الحية من الخادم.';
  pushSystemMessage(room, 'بدأت الجولة الحية.');
}

function advancePhase(room: ServerRoom): void {
  switch (room.round.phase) {
    case 'privateReveal':
      room.round.phase = 'clueTurns';
      room.round.statusLine = 'كل لاعب يتكلم من مكانه مع ترتيب دور واضح.';
      room.round.phaseEndsAt = secondsFromNow(60);
      break;
    case 'clueTurns':
      room.round.phase = 'discussion';
      room.round.statusLine = 'بدأ النقاش المشترك بين كل اللاعبين.';
      room.round.phaseEndsAt = secondsFromNow(45);
      break;
    case 'discussion':
      room.round.phase = 'voting';
      room.round.statusLine = 'التصويت الآن خاص على كل هاتف.';
      room.round.phaseEndsAt = secondsFromNow(35);
      room.round.requiredVotes = room.players.length;
      room.round.submittedVotes = 0;
      room.round.votes = {};
      room.round.accusedPlayerIds = [];
      break;
    case 'voting':
      resolveVotes(room);
      break;
    case 'voteReveal':
      if (room.round.survivingOutsiderIds.length > 0) {
        room.round.phase = 'outsiderGuess';
        room.round.activePlayerId = room.round.survivingOutsiderIds.find(
          (outsiderId) => !room.round.guessedTopicByPlayer[outsiderId],
        ) ?? room.round.survivingOutsiderIds[0];
        room.round.statusLine = 'الهاتف الخاص ببرا السالفة الناجي وحده يستقبل شاشة التخمين الآن.';
        room.round.phaseEndsAt = secondsFromNow(30);
      } else {
        room.round.phase = 'results';
        room.round.activePlayerId = null;
        room.round.statusLine = 'تم حسم الجولة بعد كشف كل برا السالفة.';
        room.round.phaseEndsAt = null;
      }
      break;
    case 'outsiderGuess': {
      const remaining = room.round.survivingOutsiderIds.filter(
        (outsiderId) => !room.round.guessedTopicByPlayer[outsiderId],
      );
      if (remaining.length > 0) {
        room.round.activePlayerId = remaining[0];
        room.round.statusLine = 'انتقل التخمين الآن إلى برا السالفة التالي.';
        room.round.phaseEndsAt = secondsFromNow(30);
      } else {
        room.round.phase = 'results';
        room.round.activePlayerId = null;
        room.round.statusLine = 'تم إنهاء الجولة وإرسال النقاط للجميع.';
        room.round.phaseEndsAt = null;
      }
      break;
    }
    case 'results':
    case 'lobby':
      break;
  }
  room.systemMessage = `انتقلت الغرفة إلى مرحلة ${room.round.phase}.`;
}

function submitVote(room: ServerRoom, playerId: string, suspectIdsInput: unknown): void {
  if (room.round.phase !== 'voting') {
    throw new Error('Voting is not open.');
  }
  const suspectIds = normalizeSuspectIds(suspectIdsInput);
  if (suspectIds.length !== room.round.voteSelectionLimit) {
    throw new Error(`You must select ${room.round.voteSelectionLimit} suspects.`);
  }
  if (new Set(suspectIds).size !== suspectIds.length) {
    throw new Error('Duplicate suspects are not allowed.');
  }
  if (suspectIds.includes(playerId)) {
    throw new Error('Player cannot vote for themselves.');
  }
  for (const suspectId of suspectIds) {
    requirePlayer(room, suspectId);
  }
  if (room.round.votes[playerId]) {
    throw new Error('Vote already submitted.');
  }
  room.round.votes[playerId] = suspectIds;
  room.round.submittedVotes = Object.keys(room.round.votes).length;
  room.systemMessage = 'وصل تصويت جديد إلى الخادم.';
  if (room.round.submittedVotes >= room.round.requiredVotes) {
    resolveVotes(room);
  }
}

function resolveVotes(room: ServerRoom): void {
  const counts = new Map<string, number>();
  for (const suspectIds of Object.values(room.round.votes)) {
    for (const suspectId of suspectIds) {
      counts.set(suspectId, (counts.get(suspectId) ?? 0) + 1);
    }
  }
  const accusedPlayerIds = buildAccusedPlayerIds(counts, room.round.voteSelectionLimit);
  const outsiderSet = new Set(room.round.outsiderIds);
  const survivingOutsiderIds = room.round.outsiderIds.filter(
    (outsiderId) => !accusedPlayerIds.includes(outsiderId),
  );

  const voteScoreDeltas: Record<string, number> = {};
  for (const player of room.players) {
    if (outsiderSet.has(player.id)) {
      voteScoreDeltas[player.id] = 0;
      continue;
    }
    voteScoreDeltas[player.id] = voteDelta(room.round.votes[player.id] ?? [], outsiderSet);
  }

  applyScoreDeltas(room, voteScoreDeltas);
  room.round.accusedPlayerIds = accusedPlayerIds;
  room.round.survivingOutsiderIds = survivingOutsiderIds;
  room.round.outsiderSurvived = survivingOutsiderIds.length > 0;
  room.round.phase = 'voteReveal';
  room.round.activePlayerId = survivingOutsiderIds[0] ?? null;
  room.round.statusLine =
    survivingOutsiderIds.length === 0
      ? 'تم كشف كل برا السالفة في التصويت.'
      : 'نجا بعض برا السالفة من التصويت وانتقلوا إلى التخمين.';
  room.round.phaseEndsAt = secondsFromNow(20);
  room.systemMessage = room.round.statusLine;
  pushSystemMessage(room, room.round.statusLine);
}

function submitOutsiderGuess(room: ServerRoom, playerId: string, guessedTopic: string): void {
  if (room.round.phase !== 'outsiderGuess') {
    throw new Error('Outsider guess phase is not open.');
  }
  if (room.round.activePlayerId !== playerId || !room.round.survivingOutsiderIds.includes(playerId)) {
    throw new Error('Only the active surviving outsider may guess.');
  }
  const isCorrect = guessedTopic === room.round.topic;
  room.round.guessedTopicByPlayer[playerId] = guessedTopic;
  applyScoreDeltas(room, {
    [playerId]: isCorrect ? 1 : -1,
  });
  const remainingGuessers = room.round.survivingOutsiderIds.filter(
    (outsiderId) => !room.round.guessedTopicByPlayer[outsiderId],
  );
  if (remainingGuessers.length > 0) {
    room.round.phase = 'outsiderGuess';
    room.round.activePlayerId = remainingGuessers[0];
    room.round.statusLine = 'انتقل التخمين الآن إلى برا السالفة التالي.';
    room.round.phaseEndsAt = secondsFromNow(30);
  } else {
    room.round.phase = 'results';
    room.round.activePlayerId = null;
    room.round.statusLine = isCorrect
      ? 'نجح أحد برا السالفة في التخمين الصحيح.'
      : 'انتهت تخمينات برا السالفة وتم إعلان النتائج.';
    room.round.phaseEndsAt = null;
  }
  room.systemMessage = 'وصل تخمين برا السالفة من هاتفه وتمت مزامنة النتيجة.';
}

function leaveRoom(room: ServerRoom, playerId: string): void {
  room.players = room.players.filter((player) => player.id !== playerId);
  delete room.round.votes[playerId];
  delete room.round.guessedTopicByPlayer[playerId];
  room.round.outsiderIds = room.round.outsiderIds.filter((id) => id !== playerId);
  room.round.survivingOutsiderIds = room.round.survivingOutsiderIds.filter((id) => id !== playerId);
  room.round.accusedPlayerIds = room.round.accusedPlayerIds.filter((id) => id !== playerId);

  if (room.players.length === 0) {
    rooms.delete(room.roomId);
    return;
  }

  if (!room.players.some((player) => player.id === room.hostPlayerId)) {
    migrateHost(room);
  }
  room.round.requiredVotes = room.players.length;
  room.round.submittedVotes = Object.keys(room.round.votes).length;
  room.systemMessage = 'غادر أحد اللاعبين الغرفة.';
  pushSystemMessage(room, 'غادر أحد اللاعبين الغرفة.');
  emitRoom(room);
}

function banPlayer(
  room: ServerRoom,
  hostPlayerId: string,
  targetPlayerId: string,
  hostSocketId: string,
): void {
  const host = requirePlayer(room, hostPlayerId);
  if (!host.isHost || host.socketId !== hostSocketId) {
    throw new Error('Only the host can ban players.');
  }
  if (host.id === targetPlayerId) {
    throw new Error('Host cannot ban themselves.');
  }
  const target = requirePlayer(room, targetPlayerId);
  if (!room.bannedClientIds.includes(target.clientId)) {
    room.bannedClientIds.push(target.clientId);
  }
  if (target.socketId) {
    io.to(target.socketId).emit('room.access.revoked', {
      message: 'You were banned from this room by the host.',
    });
  }
  leaveRoom(room, targetPlayerId);
  room.systemMessage = `تم حظر ${target.name} من الغرفة.`;
  pushSystemMessage(room, `قام المضيف بحظر ${target.name}.`);
}

function sendChatMessage(room: ServerRoom, player: ServerPlayer, text: string): void {
  const trimmed = text.trim();
  if (trimmed.length === 0) {
    return;
  }
  room.chatMessages.push({
    id: randomId('chat'),
    senderPlayerId: player.id,
    senderName: player.name,
    text: trimmed.slice(0, 240),
    sentAt: new Date().toISOString(),
    isSystem: false,
  });
  room.chatMessages = room.chatMessages.slice(-60);
  room.systemMessage = 'وصلت رسالة جديدة إلى الغرفة.';
}

function seedDemoPlayers(room: ServerRoom): void {
  const demoPlayers: ServerPlayer[] = [
    {
      id: 'demo-sara',
      clientId: 'demo-sara',
      name: 'Sara',
      avatarIndex: 1,
      score: 3,
      isHost: false,
      isReady: true,
      connectionState: 'connected',
    },
    {
      id: 'demo-omar',
      clientId: 'demo-omar',
      name: 'Omar',
      avatarIndex: 2,
      score: 1,
      isHost: false,
      isReady: true,
      connectionState: 'connected',
    },
    {
      id: 'demo-lina',
      clientId: 'demo-lina',
      name: 'Lina',
      avatarIndex: 3,
      score: 2,
      isHost: false,
      isReady: true,
      connectionState: 'connected',
    },
  ];

  const existingIds = new Set(room.players.map((player) => player.id));
  for (const demoPlayer of demoPlayers) {
    if (room.players.length >= room.maxPlayers) {
      break;
    }
    if (existingIds.has(demoPlayer.id)) {
      continue;
    }
    room.players.push(demoPlayer);
    existingIds.add(demoPlayer.id);
  }

  room.systemMessage = 'Demo players were added to preview the live room flow.';
  pushSystemMessage(room, 'تمت إضافة لاعبين تجريبيين للغرفة.');
}

function migrateHost(room: ServerRoom): void {
  const nextHost =
    room.players.find((player) => player.connectionState === 'connected') ?? room.players[0];
  room.hostPlayerId = nextHost.id;
  room.players = room.players.map((player) => ({
    ...player,
    isHost: player.id === nextHost.id,
  }));
}

function emitRoom(room: ServerRoom): void {
  for (const player of room.players) {
    if (!player.socketId) {
      continue;
    }
    io.to(player.socketId).emit('room.snapshot', buildRoomView(room, player.id));
  }
}

function buildRoomView(room: ServerRoom, playerId: string) {
  const isOutsider = room.round.outsiderIds.includes(playerId);
  const canGuessNow =
    room.round.phase === 'outsiderGuess' &&
    room.round.activePlayerId === playerId &&
    room.round.survivingOutsiderIds.includes(playerId);
  return {
    roomId: room.roomId,
    roomCode: room.roomCode,
    shareLink: room.shareLink,
    visibility: room.visibility,
    status: room.status,
    modeSlug: room.modeSlug,
    packId: room.packId,
    maxPlayers: room.maxPlayers,
    outsiderCount: room.outsiderCount,
    hostPlayerId: room.hostPlayerId,
    currentPlayerId: playerId,
    players: room.players.map((player) => ({
      id: player.id,
      name: player.name,
      avatarIndex: player.avatarIndex,
      score: player.score,
      isHost: player.isHost,
      isReady: player.isReady,
      connectionState: player.connectionState,
    })),
    round: {
      roundNumber: room.round.roundNumber,
      phase: room.round.phase,
      activePlayerId: room.round.activePlayerId,
      outsiderIds: room.round.outsiderIds,
      survivingOutsiderIds: room.round.survivingOutsiderIds,
      accusedPlayerIds: room.round.accusedPlayerIds,
      phaseEndsAt: room.round.phaseEndsAt,
      requiredVotes: room.round.requiredVotes,
      submittedVotes: room.round.submittedVotes,
      voteSelectionLimit: room.round.voteSelectionLimit,
      outsiderSurvived: room.round.outsiderSurvived,
      statusLine: room.round.statusLine,
    },
    privateView: {
      role: room.round.phase === 'lobby' ? null : (isOutsider ? 'outsider' : 'insider'),
      topicLabel: room.round.phase === 'lobby' || isOutsider ? null : room.round.topic,
      guessOptions: canGuessNow ? room.round.guessOptions : [],
      voteSubmitted: Boolean(room.round.votes[playerId]),
      guessedTopic: room.round.guessedTopicByPlayer[playerId] ?? null,
      submittedSuspectIds: room.round.votes[playerId] ?? [],
    },
    chatMessages: room.chatMessages,
    systemMessage: room.systemMessage,
  };
}

function requireRoom(roomId: string): ServerRoom {
  const room = rooms.get(roomId);
  if (!room) {
    throw new Error('Room not found.');
  }
  return room;
}

function requirePlayer(room: ServerRoom, playerId: string): ServerPlayer {
  const player = room.players.find((item) => item.id === playerId);
  if (!player) {
    throw new Error('Player not found.');
  }
  return player;
}

function applyScoreDeltas(room: ServerRoom, deltas: Record<string, number>): void {
  room.players = room.players.map((player) => ({
    ...player,
    score: player.score + (deltas[player.id] ?? 0),
  }));
}

function emptyRound(): ServerRound {
  return {
    roundNumber: 0,
    phase: 'lobby',
    activePlayerId: null,
    outsiderIds: [],
    survivingOutsiderIds: [],
    accusedPlayerIds: [],
    phaseEndsAt: null,
    requiredVotes: 0,
    submittedVotes: 0,
    voteSelectionLimit: 1,
    outsiderSurvived: false,
    statusLine: 'بانتظار بدء الغرفة',
    topic: null,
    topicPool: [],
    guessOptions: [],
    votes: {},
    guessedTopicByPlayer: {},
  };
}

function normalizeTopicPool(input: unknown): string[] {
  if (!Array.isArray(input)) {
    return [];
  }
  return input.map((item) => String(item).trim()).filter(Boolean);
}

function normalizeClientId(value: unknown): string {
  const clientId = String(value ?? '').trim();
  return clientId.length > 0 ? clientId : randomId('client');
}

function normalizeOutsiderCount(value: unknown): number {
  const count = Number(value ?? 1);
  if (!Number.isFinite(count)) {
    return 1;
  }
  return Math.min(3, Math.max(1, Math.floor(count)));
}

function normalizeSuspectIds(input: unknown): string[] {
  if (!Array.isArray(input)) {
    return [];
  }
  return input.map((item) => String(item)).filter(Boolean);
}

function pickTopic(topicPool: string[], packId: string): string {
  if (topicPool.length > 0) {
    return topicPool[Math.floor(Math.random() * topicPool.length)];
  }
  return packId === 'historical-people' ? 'صلاح الدين الأيوبي' : 'المغرب';
}

function buildGuessOptions(topicPool: string[], topic: string): string[] {
  const pool = topicPool.filter((item) => item !== topic);
  shuffle(pool);
  return [...new Set([topic, ...pool.slice(0, 14)])];
}

function pushSystemMessage(room: ServerRoom, text: string): void {
  room.chatMessages.push({
    id: randomId('system'),
    senderPlayerId: 'system',
    senderName: 'النظام',
    text,
    sentAt: new Date().toISOString(),
    isSystem: true,
  });
  room.chatMessages = room.chatMessages.slice(-60);
}

function minimumPlayersForMode(modeSlug: string): number {
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

function maxOutsidersForPlayerCount(playerCount: number): number {
  if (playerCount >= 9) {
    return 3;
  }
  if (playerCount >= 6) {
    return 2;
  }
  return 1;
}

function voteDelta(suspectIds: string[], outsiderSet: Set<string>): number {
  return suspectIds.reduce((sum, suspectId) => sum + (outsiderSet.has(suspectId) ? 1 : -1), 0);
}

function buildAccusedPlayerIds(counts: Map<string, number>, limit: number): string[] {
  const sorted = [...counts.entries()].sort((a, b) => {
    const byVotes = b[1] - a[1];
    if (byVotes !== 0) {
      return byVotes;
    }
    return a[0].localeCompare(b[0]);
  });
  if (sorted.length === 0) {
    return [];
  }
  const base = sorted.slice(0, limit);
  const cutoff = base[base.length - 1]?.[1];
  if (cutoff == null) {
    return [];
  }
  return sorted.filter((entry) => entry[1] >= cutoff).map((entry) => entry[0]);
}

function shuffle<T>(values: T[]): void {
  for (let index = values.length - 1; index > 0; index -= 1) {
    const nextIndex = Math.floor(Math.random() * (index + 1));
    [values[index], values[nextIndex]] = [values[nextIndex], values[index]];
  }
}

function randomId(prefix: string): string {
  return `${prefix}-${Math.random().toString(36).slice(2, 10)}`;
}

function randomCode(): string {
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  return Array.from({ length: 6 }, () => alphabet[Math.floor(Math.random() * alphabet.length)]).join('');
}

function secondsFromNow(seconds: number): string {
  return new Date(Date.now() + seconds * 1000).toISOString();
}

function messageFromError(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  return 'Unknown server error';
}

server.listen(port, '0.0.0.0', () => {
  console.log(`bara-alsalfa multiplayer server listening on http://0.0.0.0:${port}`);
});

function buildShareLink(roomCode: string): string {
  if (publicBaseUrl.length > 0) {
    return `${publicBaseUrl.replace(/\/$/, '')}/room/${roomCode}`;
  }
  return `bara://room/${roomCode}`;
}
