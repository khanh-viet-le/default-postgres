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

## Example vector table

Replace `1536` with the output dimension of your embedding model:

```sql
CREATE TABLE IF NOT EXISTS document_chunks (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    document_id TEXT NOT NULL,
    chunk_text  TEXT NOT NULL,
    metadata    JSONB NOT NULL DEFAULT '{}'::jsonb,
    embedding   VECTOR(3) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- This is a 3-dimensional example. Replace VECTOR(3) with the output dimension of your embedding model.
-- Cosine-distance HNSW index; create after there is enough data to index.
CREATE INDEX IF NOT EXISTS document_chunks_embedding_hnsw_idx
    ON document_chunks USING hnsw (embedding vector_cosine_ops);

CREATE INDEX IF NOT EXISTS document_chunks_metadata_gin_idx
    ON document_chunks USING gin (metadata);
```

Cosine similarity search uses the cosine-distance operator `<=>`:

```sql
SELECT id, document_id, chunk_text, metadata,
       1 - (embedding <=> '[0.1, 0.2, 0.3]'::vector) AS cosine_similarity
FROM document_chunks
ORDER BY embedding <=> '[0.1, 0.2, 0.3]'::vector
LIMIT 5;
```

The example uses three dimensions so the sample query runs as written. Replace the dimension with your embedding model's output dimension, and ensure query embeddings use that same dimension.

## Stop / remove

- Stop services but keep data: `docker compose down`
- **Destructive:** remove the database volume too: `docker compose down -v`

Do not expose port 5432 to public interfaces without planning network restrictions, authentication, TLS, backups and monitoring. This setup is intended as a development starting point, not a complete production deployment.
