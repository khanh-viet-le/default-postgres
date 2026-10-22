-- Vector similarity search for RAG
CREATE EXTENSION IF NOT EXISTS vector;

-- Useful building blocks for hybrid / lexical retrieval and text cleanup
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Cryptographic functions and UUID helpers (gen_random_uuid is built in on modern PostgreSQL)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Query monitoring; shared_preload_libraries is configured in compose.yaml
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

