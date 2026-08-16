# Game Data Persistence Plan

Goal: when the player closes the app, the game data (player names, avatars,
scores, selected mode/pack, round number) is restored on the next launch and
kept **until the user explicitly deletes it** (or starts a new game).

---

## 1. Current state (problems)

1. **The game session is 100 % in memory.**
   `GameSessionState` lives only in the Riverpod `gameSessionProvider`
   (`lib/features/round/application/game_session_controller.dart`).
   Closing the app wipes players, names and scores. The Stats screen reads
   from the same provider, so stats disappear too.

2. **Existing stores write to a fragile location.**
   All local stores persist JSON files inside `Directory.systemTemp`
   (the OS cache), which Android may purge at any time and which
   "Clear cache" wipes:
   - `lib/data/local/local_settings_store.dart`
   - `lib/data/local/local_subject_store.dart`
   - `lib/data/local/local_topic_translation_store.dart`
   - `lib/data/local/local_multiplayer_config_store.dart`

---

## 2. Scope: Level 1 (this plan)

| Saved | Not saved (Level 2, future) |
|---|---|
| Players: `id`, `name`, `avatarIndex`, `score` | Current `phase` (reveal/voting/...) |
| `selectedMode` | Secret assignments / `outsiderIds` |
| `selectedPackId` | `votes`, `powerCards`, `currentTopic` |
| `discussionSeconds`, `scoringEnabled` | `outcome` |
| `powerCardsEnabled`, `activePowerCardIds` | |
| `outsidersKnowEachOther`, `outsiderCount` | |
| `roundNumber` | |

Resume experience: the player comes back with the same group, scores and
round number, starting a fresh round. No timers/secrets edge cases.

### Survival matrix (after implementation)

| Scenario | Data survives? |
|---|---|
| App closed / swiped away | ✅ |
| Phone reboot / app killed by the OS | ✅ |
| Days later | ✅ (until explicit delete / new game) |
| Android "Clear cache" | ✅ (documents dir is not cache) |
| Android "Clear data" / uninstall | ❌ (OS-level wipe, expected) |

---

## 3. Implementation steps

### Step 1 — Permanent storage location (foundation)

- Add dependency `path_provider` to `app/pubspec.yaml`.
- In every store listed above, replace `Directory.systemTemp` with
  `getApplicationDocumentsDirectory()` (resolved once, e.g. via a small
  shared helper `AppDirectories.documents`).
- Keep the existing file names so behaviour stays identical otherwise.

### Step 2 — JSON serialization on models

Add `toJson()` / `fromJson()` to:

- `PlayerProfile` (`lib/domain/models/player_profile.dart`)
- A new `PersistedGameSession` snapshot class (see Step 3) holding the
  fields listed in section 2. Enums are stored by `name`
  (`GameMode.classic.name`) and resolved with the same
  `firstWhere(..., orElse:)` pattern used by `AppVisualTheme.fromName`.

### Step 3 — `LocalGameSessionStore`

New file `lib/data/local/local_game_session_store.dart`, mirroring the
existing `SettingsStore` pattern:

```dart
abstract class GameSessionStore {
  Future<PersistedGameSession?> load(); // null = no saved game
  Future<void> save(PersistedGameSession session);
  Future<void> clear();                 // explicit delete
}
```

`LocalGameSessionStore` writes `bara_alsalfa_game_session.json` in the
documents directory. `load()` is defensive: missing/corrupt file → `null`
(exactly like `LocalSettingsStore` falls back to defaults).

### Step 4 — Auto-save from `GameSessionController`

- Inject the store via a new `gameSessionStoreProvider` (overridden in
  `main.dart`, same as `settingsStoreProvider`).
- After every state mutation (player added/removed, score change, setup
  change, round advance, reset), persist the snapshot. Centralise this in
  one private `_persist()` helper called at the end of each public method.
- `clearSavedSession()` calls `store.clear()` (used by the delete button
  and when a brand-new game is started from Setup).

### Step 5 — Restore at startup (`lib/main.dart`)

- `final savedSession = await gameSessionStore.load();`
- Override a new `initialGameSessionProvider` with the loaded snapshot
  (falls back to `GameSessionState.initial()` when `null`), exactly the
  way `initialAppSettingsProvider` is overridden today.

### Step 6 — UI: Continue & Delete

- **Home screen** (`home_screen.dart`): when a saved session exists
  (players non-empty AND it came from disk), show a "متابعة الجلسة"
  (Continue session) GlowCard above the actions, listing player names,
  scores and round number; tapping it jumps straight to the round flow.
- **Stats screen** (`stats_screen.dart`): the existing
  'تصفير النقاط' / delete action calls `clearSavedSession()` + resets the
  provider — this is the explicit user delete.
- **Setup screen**: starting a new game from here overwrites/clears the
  previous save.

### Step 7 — Tests

- Store round-trip: `save()` → `load()` returns identical data;
  `clear()` → `load()` returns `null`.
- Corrupt/missing file → `null` (no crash).
- Controller: adding a player / changing a score triggers a persisted
  snapshot (verify via the store with a temp file path, like
  `LocalSettingsStore(filePath:)` already allows).
- Existing tests must keep passing (`flutter test`).

---

## 4. File touch list

| File | Change |
|---|---|
| `app/pubspec.yaml` | + `path_provider` |
| `lib/data/local/local_settings_store.dart` | documents dir |
| `lib/data/local/local_subject_store.dart` | documents dir |
| `lib/data/local/local_topic_translation_store.dart` | documents dir |
| `lib/data/local/local_multiplayer_config_store.dart` | documents dir |
| `lib/data/local/local_game_session_store.dart` | **new** |
| `lib/domain/models/player_profile.dart` | + `toJson`/`fromJson` |
| `lib/features/round/application/game_session_controller.dart` | auto-save, `clearSavedSession`, initial-session provider |
| `lib/main.dart` | load + override |
| `lib/features/home/presentation/home_screen.dart` | Continue card |
| `lib/features/stats/presentation/stats_screen.dart` | Delete button |
| `test/` | new store/controller tests |

---

## 5. Future (Level 2+, not in this plan)

- Full mid-round resume (phase, secrets, votes, timers).
- Match history (one record per finished game) → all-time stats,
  hall of fame — at that point evaluate Hive/SQLite instead of JSON files.
- Saved player rosters ("المجموعة المعتادة") for one-tap game start.

## 6. Verification checklist

1. `flutter analyze` — no issues.
2. `flutter test` — all green (old + new).
3. Manual: start a game, add players, play a round, close the app,
   reopen → Continue card shows same names/scores → resume works.
4. Manual: delete from Stats → Continue card disappears, fresh state.
5. Manual: Android "Clear cache" → data still there.
