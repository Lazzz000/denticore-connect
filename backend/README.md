# Backend DentiCore Connect

API monolítica modular en Java 17 y Spring Boot para identidad, catálogo, clínica, agenda y citas.

## Inicio local

Desde la raíz:

```bash
read -s POSTGRES_PASSWORD
read -s DENTICORE_LOCAL_JWT_SECRET
export POSTGRES_PASSWORD DENTICORE_LOCAL_JWT_SECRET
docker compose up -d
cd backend
DB_PASSWORD="$POSTGRES_PASSWORD" \
JWT_SIGNING_SECRET="$DENTICORE_LOCAL_JWT_SECRET" \
./mvnw spring-boot:run
```

Base URL: `http://localhost:8080/api/v1`.

## Migraciones

Flyway es la fuente de verdad:

- `V1__legacy_baseline.sql`
- `V2__denticore_connect_release_01.sql`

No ejecutar el script heredado sobre una base migrada. `ddl-auto=validate` verifica el mapeo JPA.

## Pruebas

```bash
./mvnw test
```

El contrato vigente está en `../docs/openapi.yaml` y el despliegue en `../render.yaml`.
