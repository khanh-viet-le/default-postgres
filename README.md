# PostgreSQL 16 for a RAG service

Docker Compose setup using `pgvector/pgvector:0.8.7-pg16-bookworm`.

## Included

- PostgreSQL 16
- `vector` (`pgvector`) for embedding storage and nearest-neighbor search
- `pg_trgm` for trigram similarity and typo-tolerant text matching
- `unaccent` for optional accent-insensitive text processing
- `pgcrypto` for cryptographic helpers
- `pg_stat_statements` for query-performance monitoring
- Named volume for persistent database data
- Health check and localhost-only port binding

## Start

1. Copy `.env.example` to `.env`.
2. Change `POSTGRES_PASSWORD` to a long random password.
3. Run:

   ```bash
   docker compose up -d
   docker compose ps
   docker compose logs -f postgres
   ```

The init SQL runs only when PostgreSQL initializes an empty data directory for the first time. If the volume already exists, adding another `CREATE EXTENSION` line to the init file will not cause it to run automatically; run that SQL manually against the database instead.

## Connect

From a client on the host machine:

```text
Host:     127.0.0.1
Port:     5432
Database: ragdb
Username: rag_user
Password: value of POSTGRES_PASSWORD in .env
```

Connection URL on the host:

```text
postgresql://rag_user:<password>@127.0.0.1:5432/ragdb
```

If your RAG application is another service in this same Compose project, connect using hostname `postgres` and port `5432` rather than `127.0.0.1`.

## Verify extensions

```bash
docker compose exec postgres psql -U rag_user -d ragdb -c "SELECT extname, extversion FROM pg_extension ORDER BY extname;"
```

Check PostgreSQL version:

```bash
docker compose exec postgres psql -U rag_user -d ragdb -c "SELECT version();"
```

## Stop / remove

- Stop services but keep data: `docker compose down`
- **Destructive:** remove the database volume too: `docker compose down -v`