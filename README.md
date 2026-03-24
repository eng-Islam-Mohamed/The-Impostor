# The Impostor

Premium Flutter party game based on `برا السالفة`, with:

- Arabic-first local party mode
- full multilingual UI + in-game topic translation
- real-time multiplayer room backend
- Android 7+ support

## Deploy Multiplayer Server

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/eng-Islam-Mohamed/The-Impostor)

This repo already includes:

- [render.yaml](./render.yaml)
- [server/Dockerfile](./server/Dockerfile)
- [server/README.md](./server/README.md)

## Fastest Path To Online Multiplayer

1. Click the `Deploy to Render` button above.
2. Sign in to Render with GitHub.
3. Approve the Blueprint deploy.
4. Wait for the service to finish building.
5. Copy your public Render URL, for example:
   `https://bara-alsalfa-multiplayer.onrender.com`
6. In the app, open `غرفة أونلاين` -> `تعديل رابط الخادم`.
7. Paste the public URL and enable `Use live server`.

After that:

- players can join from different networks
- the PC can stay off
- online rooms stay backed by the hosted server

## Local Development

### Flutter app

```bash
cd app
flutter pub get
flutter run
```

### Multiplayer server

```bash
cd server
npm install
npm run dev
```

Health check:

```text
GET /health
```
