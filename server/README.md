# Bara Alsalfa Multiplayer Server

This is the live room backend for the Flutter app.

## Local run

```bash
npm install
npm run dev
```

Production-style local run:

```bash
npm run build
npm start
```

Default port:

```text
8080
```

Health check:

```text
GET /health
```

## Public hosting

The Flutter app already supports public multiplayer URLs, so once this server is deployed to an always-on host, players can join from different networks and the PC no longer needs to stay on.

Included deployment assets:

- `Dockerfile`
- `.dockerignore`
- `../render.yaml`

Useful environment variables:

```text
PORT=8080
PUBLIC_BASE_URL=https://your-public-server.example.com
CORS_ORIGIN=*
```

If you build the Flutter APK with a hosted server URL, you can inject it at build time:

```bash
flutter build apk --release --dart-define=MULTIPLAYER_SERVER_URL=https://your-public-server.example.com
```

## Notes

- The online hub inside the app can also edit the server URL manually.
- For quick LAN testing, the current default remains the local server URL unless you override it at build time or in-app.
- An always-on public deployment is the requirement for true internet multiplayer while the PC is off.
