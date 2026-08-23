# Esquema histórico

`DATABASE_SCHEMA.sql` representa la línea base heredada de DentiCore y se
conserva únicamente como referencia del proyecto anterior.

El esquema ejecutable del producto DentiCore Connect se encuentra versionado
en:

- `backend/src/main/resources/db/migration/V1__legacy_baseline.sql`
- `backend/src/main/resources/db/migration/V2__denticore_connect_release_01.sql`

Spring Boot ejecuta esas migraciones con Flyway. El `docker-compose.yml` solo
inicia PostgreSQL; no monta ni ejecuta directamente los archivos de esta
carpeta.

No se deben aplicar cambios manuales sobre una base compartida ni modificar
una migración que ya haya sido ejecutada. Toda evolución posterior debe
incorporarse como una nueva migración versionada (`V3`, `V4`, etc.).
