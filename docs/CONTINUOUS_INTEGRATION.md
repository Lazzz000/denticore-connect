# Plan de integración continua

## 1. Objetivo

Detectar errores de compilación, pruebas y migraciones antes de integrar cambios al release.

## 2. Flujo vigente

El workflow `.github/workflows/backend-ci.yml`:

1. se ejecuta cuando cambian backend, Docker, Render o el propio workflow;
2. provisiona PostgreSQL 16;
3. configura Java 17 y caché Maven;
4. ejecuta `./mvnw --batch-mode test`;
5. permite que Flyway y JPA validen la compatibilidad durante las pruebas aplicables.

La contraseña de PostgreSQL y la firma JWT de CI se construyen de manera
efímera con identificadores de la ejecución; no existen secretos de prueba
persistentes dentro del workflow.

## 3. Flujo iOS

La compilación iOS requiere un runner macOS. En el Release 0.1 se mantiene como compuerta manual en Xcode:

- `⌘B` para build;
- `⌘U` para pruebas;
- ejecución del recorrido crítico en simulador.

Como mejora posterior se añadirá un workflow macOS con `xcodebuild` cuando el costo y la disponibilidad del runner lo permitan.

## 4. Estrategia de ramas

- `main`: línea estable heredada hasta formalizar el release.
- `release/denticore-connect-0.1`: integración general del release.
- `feature/backend-mobile-api`: desarrollo del backend móvil.
- `feature/ios-storyboard-mvp`: desarrollo e integración del cliente iOS.

Antes de etiquetar, el código del backend y del cliente debe quedar consolidado en una rama de release única.

## 5. Convención de commits

```text
tipo(alcance): descripción breve
```

Tipos habituales: `feat`, `fix`, `refactor`, `test`, `docs`, `ci`, `chore`.

## 6. Compuertas

- No integrar secretos ni credenciales demo.
- No integrar migraciones modificadas retroactivamente.
- Actualizar OpenAPI cuando cambie un endpoint.
- Exigir pruebas para reglas de autorización y agenda.
- Confirmar Xcode antes de crear una etiqueta candidata.

## 7. Versionado

- `v0.0.0-legacy-daw2`: línea base heredada.
- `v0.1.0-rc.1`: primera candidata verificable.
- `v0.1.0`: release académico estabilizado.
