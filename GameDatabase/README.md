# GameDatabase (MongoDB)

This container provides MongoDB for the Fruit Ninja Online Web Game.

## Configuration

- Port: `5001` (default; configurable via `PORT`)

## Start

From the repo workspace root:

```bash
./GameDatabase/start.sh
```

## Health check

```bash
mongosh --host 127.0.0.1 --port 5001 --eval "db.runCommand({ ping: 1 })"
```

Expected output includes: `{ ok: 1 }`

## Connection helper

See `db_connection.txt` for the canonical mongosh connection string.
