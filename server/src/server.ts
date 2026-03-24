import cors from 'cors';
import express from 'express';
import http from 'http';
import { Server, type Socket } from 'socket.io';

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
  socketId?: string;
  name: string;
  avatarIndex: number;
  score: number;
  isHost: boolean;
  isReady: boolean;
  connectionState: ConnectionState;
}

interface ServerRound {
  roundNumber: number;
  phase: RoomPhase;
  activePlayerId: string | null;
  outsiderIds: string[];
  phaseEndsAt: string | null;
  requiredVotes: number;
  submittedVotes: number;
  mostVotedPlayerId: string | null;
  outsiderSurvived: boolean;
  statusLine: string;
  topic: string | null;
  topicPool: string[];
  guessOptions: string[];
  votes: Record<string, string>;
  voteScoreDeltas: Record<string, number>;
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
  hostPlayerId: string;
  players: ServerPlayer[];
  round: ServerRound;
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
      submitVote(room, player.id, payload.suspectId);
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
      submitOutsiderGuess(room, player.id, payload.guessedTopic);
      emitRoom(room);
      ack?.({ ok: true });
    } catch (error) {
      ack?.({ ok: false, message: messageFromError(error) });
    }
  });

  socket.on('room.leave.requested', (payload, ack) => {
    try {
      const room = requireRoom(payload.roomId);
      leaveRoom(room, payload.playerId);
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
      emitRoom(room);
    }
  });
});

function createRoom(
  payload: Record<string, unknown>,
  socketId: string,
): ServerRoom {
  const roomId = randomId('room');
  const playerId = randomId('player');
  const roomCode = randomCode();
  const room: ServerRoom = {
    roomId,
    roomCode,
    shareLink: buildShareLink(roomCode),
    visibility: payload.visibility === 'publicRoom' ? 'publicRoom' : 'privateRoom',
    status: 'lobby',
    modeSlug: String(payload.modeSlug ?? 'classic'),
    packId: String(payload.packId ?? 'countries'),
    maxPlayers: Number(payload.maxPlayers ?? 8),
    hostPlayerId: playerId,
    players: [
      {
        id: playerId,
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
    systemMessage: 'تم إنشاء الغرفة. شارك الكود وابدأ التجهيز.',
  };
  room.round.topicPool = normalizeTopicPool(payload.topicPool);
  rooms.set(roomId, room);
  return room;
}

function joinRoom(
  payload: Record<string, unknown>,
  socketId: string,
): ServerRoom {
  const roomCode = String(payload.roomCode ?? '').trim().toUpperCase();
  const room = [...rooms.values()].find((item) => item.roomCode === roomCode);
  if (!room) {
    throw new Error('Room not found.');
  }
  if (room.players.length >= room.maxPlayers) {
    throw new Error('Room is full.');
  }

  room.players.push({
    id: randomId('player'),
    socketId,
    name: String(payload.displayName ?? 'لاعب جديد'),
    avatarIndex: Number(payload.avatarIndex ?? 0),
    score: 0,
    isHost: false,
    isReady: false,
    connectionState: 'connected',
  });
  room.systemMessage = `${String(payload.displayName ?? 'لاعب')} انضم إلى الغرفة.`;
  return room;
}

function startGame(room: ServerRoom): void {
  if (room.players.length < 4) {
    throw new Error('At least 4 players are required.');
  }

  const topic = pickTopic(room.round.topicPool, room.packId);
  const outsider = room.players[Math.floor(Math.random() * room.players.length)];
  room.status = 'inProgress';
  room.round = {
    roundNumber: room.round.roundNumber + 1,
    phase: 'privateReveal',
    activePlayerId: room.players[0]?.id ?? null,
    outsiderIds: [outsider.id],
    phaseEndsAt: secondsFromNow(45),
    requiredVotes: room.players.length,
    submittedVotes: 0,
    mostVotedPlayerId: null,
    outsiderSurvived: false,
    statusLine: 'تم توزيع الأدوار الخاصة. كل لاعب يرى هاتفه فقط.',
    topic,
    topicPool: room.round.topicPool,
    guessOptions: buildGuessOptions(room.round.topicPool, topic),
    votes: {},
    voteScoreDeltas: {},
    guessedTopicByPlayer: {},
  };
  room.systemMessage = 'بدأت الجولة. التزموا بالمزامنة الحية من الخادم.';
}

function advancePhase(room: ServerRoom): void {
  switch (room.round.phase) {
    case 'privateReveal':
      room.round.phase = 'clueTurns';
      room.round.statusLine = 'كل لاعب يتكلم من هاتفه أو مكانه مع ترتيب واضح.';
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
      room.round.voteScoreDeltas = {};
      break;
    case 'voting':
      resolveVotes(room);
      break;
    case 'voteReveal':
      room.round.phase = room.round.outsiderSurvived ? 'outsiderGuess' : 'results';
      room.round.statusLine = room.round.outsiderSurvived
          ? 'الهاتف الخاص ببرا السالفة وحده يستقبل شاشة التخمين الآن.'
          : 'تم حسم الجولة بعد كشف برا السالفة.';
      room.round.phaseEndsAt = secondsFromNow(30);
      break;
    case 'outsiderGuess':
      room.round.phase = 'results';
      room.round.statusLine = 'تم إنهاء الجولة وإرسال النقاط للجميع.';
      room.round.phaseEndsAt = null;
      break;
    case 'results':
    case 'lobby':
      break;
  }
  room.systemMessage = `انتقلت الغرفة إلى مرحلة ${room.round.phase}.`;
}

function submitVote(room: ServerRoom, playerId: string, suspectId: string): void {
  if (room.round.phase !== 'voting') {
    throw new Error('Voting is not open.');
  }
  if (playerId === suspectId) {
    throw new Error('Player cannot vote for themselves.');
  }
  requirePlayer(room, suspectId);
  if (room.round.votes[playerId]) {
    throw new Error('Vote already submitted.');
  }
  room.round.votes[playerId] = suspectId;
  room.round.submittedVotes = Object.keys(room.round.votes).length;
  room.systemMessage = 'وصل تصويت جديد إلى الخادم.';
  if (room.round.submittedVotes >= room.round.requiredVotes) {
    resolveVotes(room);
  }
}

function resolveVotes(room: ServerRoom): void {
  const counts = new Map<string, number>();
  for (const suspectId of Object.values(room.round.votes)) {
    counts.set(suspectId, (counts.get(suspectId) ?? 0) + 1);
  }
  const leaders = [...counts.entries()].sort((a, b) => b[1] - a[1]);
  const topCount = leaders[0]?.[1] ?? 0;
  const tied = leaders.filter((entry) => entry[1] === topCount);
  const mostVotedPlayerId = tied.length === 1 ? tied[0][0] : null;
  const outsiderCaught =
    mostVotedPlayerId !== null && room.round.outsiderIds.includes(mostVotedPlayerId);

  const voteScoreDeltas: Record<string, number> = {};
  for (const player of room.players) {
    if (room.round.outsiderIds.includes(player.id)) {
      voteScoreDeltas[player.id] = 0;
      continue;
    }
    voteScoreDeltas[player.id] = room.round.outsiderIds.includes(room.round.votes[player.id] ?? '')
      ? 1
      : -1;
  }

  applyScoreDeltas(room, voteScoreDeltas);
  room.round.voteScoreDeltas = voteScoreDeltas;
  room.round.mostVotedPlayerId = mostVotedPlayerId;
  room.round.outsiderSurvived = !outsiderCaught;
  room.round.phase = 'voteReveal';
  room.round.statusLine = outsiderCaught
    ? 'تم كشف برا السالفة في التصويت.'
    : 'نجا برا السالفة من التصويت وانتقل إلى التخمين.';
  room.round.phaseEndsAt = secondsFromNow(20);
  room.systemMessage = room.round.statusLine;
}

function submitOutsiderGuess(room: ServerRoom, playerId: string, guessedTopic: string): void {
  if (room.round.phase !== 'outsiderGuess') {
    throw new Error('Outsider guess phase is not open.');
  }
  if (!room.round.outsiderIds.includes(playerId)) {
    throw new Error('Only the outsider may guess.');
  }
  const isCorrect = guessedTopic === room.round.topic;
  room.round.guessedTopicByPlayer[playerId] = guessedTopic;
  applyScoreDeltas(room, {
    [playerId]: isCorrect ? 1 : -1,
  });
  room.round.phase = 'results';
  room.round.statusLine = isCorrect
    ? 'خمن برا السالفة السالفة الصحيحة.'
    : 'فشل برا السالفة في التخمين النهائي.';
  room.round.phaseEndsAt = null;
  room.systemMessage = 'وصل تخمين برا السالفة من هاتفه وتمت مزامنة النتيجة.';
}

function leaveRoom(room: ServerRoom, playerId: string): void {
  room.players = room.players.filter((player) => player.id !== playerId);
  delete room.round.votes[playerId];
  delete room.round.guessedTopicByPlayer[playerId];

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
  emitRoom(room);
}

function seedDemoPlayers(room: ServerRoom): void {
  const demoPlayers: ServerPlayer[] = [
    {
      id: 'demo-sara',
      name: 'Sara',
      avatarIndex: 1,
      score: 3,
      isHost: false,
      isReady: true,
      connectionState: 'connected',
    },
    {
      id: 'demo-omar',
      name: 'Omar',
      avatarIndex: 2,
      score: 1,
      isHost: false,
      isReady: true,
      connectionState: 'connected',
    },
    {
      id: 'demo-lina',
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
}

function migrateHost(room: ServerRoom): void {
  const nextHost = room.players.find((player) => player.connectionState === 'connected') ?? room.players[0];
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
  return {
    roomId: room.roomId,
    roomCode: room.roomCode,
    shareLink: room.shareLink,
    visibility: room.visibility,
    status: room.status,
    modeSlug: room.modeSlug,
    packId: room.packId,
    maxPlayers: room.maxPlayers,
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
      phaseEndsAt: room.round.phaseEndsAt,
      requiredVotes: room.round.requiredVotes,
      submittedVotes: room.round.submittedVotes,
      mostVotedPlayerId: room.round.mostVotedPlayerId,
      outsiderSurvived: room.round.outsiderSurvived,
      statusLine: room.round.statusLine,
    },
    privateView: {
      role: room.round.phase === 'lobby' ? null : (isOutsider ? 'outsider' : 'insider'),
      topicLabel: room.round.phase === 'lobby' || isOutsider ? null : room.round.topic,
      guessOptions: isOutsider ? room.round.guessOptions : [],
      voteSubmitted: Boolean(room.round.votes[playerId]),
      guessedTopic: room.round.guessedTopicByPlayer[playerId] ?? null,
    },
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
    phaseEndsAt: null,
    requiredVotes: 0,
    submittedVotes: 0,
    mostVotedPlayerId: null,
    outsiderSurvived: false,
    statusLine: 'بانتظار بدء الغرفة',
    topic: null,
    topicPool: [],
    guessOptions: [],
    votes: {},
    voteScoreDeltas: {},
    guessedTopicByPlayer: {},
  };
}

function normalizeTopicPool(input: unknown): string[] {
  if (!Array.isArray(input)) {
    return [];
  }
  return input.map((item) => String(item).trim()).filter(Boolean);
}

function pickTopic(topicPool: string[], packId: string): string {
  if (topicPool.length > 0) {
    return topicPool[Math.floor(Math.random() * topicPool.length)];
  }
  return packId === 'historical-people' ? 'صلاح الدين الأيوبي' : 'المغرب';
}

function buildGuessOptions(topicPool: string[], topic: string): string[] {
  const options = [topic, ...topicPool.filter((item) => item !== topic)].slice(0, 15);
  return [...new Set(options)];
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
