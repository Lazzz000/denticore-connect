# Sistema de diseño iOS

## 1. Principios

- Claridad antes que decoración.
- Jerarquía visible y espacios consistentes.
- Componentes nativos y comportamiento familiar para iOS.
- Acciones clínicas sin ambigüedad.
- Accesibilidad y adaptación a modo claro/oscuro.
- Storyboard como composición principal del Release 0.1.

## 2. Identidad

| Token | Valor iOS | Uso |
|---|---|---|
| `primary` | RGB 22, 103, 171 | Navegación y acciones primarias |
| `accent` | RGB 38, 166, 154 | Apoyo de marca |
| `primaryDark` | RGB 12, 72, 122 | Variantes de identidad |
| `success` | `systemGreen` | Confirmación/atendida |
| `warning` | `systemOrange` | Pendiente/precaución |
| `danger` | `systemRed` | Error/cancelación |
| `canvas` | `systemGroupedBackground` | Fondo principal |
| `surface` | `secondarySystemBackground` | Controles y tarjetas |

Los colores semánticos del sistema se prefieren para conservar contraste en modo oscuro.

## 3. Tipografía

- Tipografía del sistema San Francisco.
- Dynamic Type mediante `preferredFont(forTextStyle:)`.
- Títulos: `.title1`, `.title2`, `.title3` según jerarquía.
- Texto: `.body`; soporte: `.subheadline` o `.footnote`.
- No fijar tamaños cuando la pantalla pueda usar estilos dinámicos.

## 4. Espaciado y forma

| Token | Valor |
|---|---:|
| Pequeño | 8 pt |
| Compacto | 12 pt |
| Estándar | 16 pt |
| Sección | 24 pt |
| Margen horizontal | 20 pt |
| Control principal | 52 pt |
| Radio compacto | 8 pt |
| Radio estándar | 12 pt |
| Radio grande | 18 pt |

## 5. Componentes

### Botón primario

- `UIButton.Configuration.filled()`.
- Fondo `primary`, texto blanco.
- Una única acción principal por pantalla.
- Estado deshabilitado durante solicitudes.

### Botón secundario

- Configuración `tinted`.
- Color de marca con fondo tenue.
- Se utiliza para permisos, reintentos o navegación complementaria.

### Acción destructiva

- Rojo semántico.
- Confirmación previa mediante alerta.
- No se usa para cerrar una pantalla sin pérdida.

### Acción en línea

- Configuración `plain` alineada al inicio.
- Se emplea para mostrar/ocultar DNI sin competir con la acción principal.

### Tablas

- Celdas prototype con `Reuse Identifier`.
- Configuración encapsulada en `configure(with:)`.
- Título, información secundaria y estado distinguibles.
- Selección conduce a detalle mediante segue.

## 6. Marca gráfica

El recurso `BrandLogo` incorpora variantes PNG de 128, 256 y 384 px para las escalas 1x, 2x y 3x, y reemplaza automáticamente `mouth.fill` en Login e Inicio. `AppIcon` contiene el icono de distribución de 1024 px sin canal alfa. Recomendaciones para futuras sustituciones:

- logo transparente, formato PDF vectorial de un solo scale o PNG `1x/2x/3x`;
- versión horizontal o isotipo legible sobre fondo claro y oscuro;
- no incrustar textos demasiado pequeños;
- el App Icon se gestiona por separado en `AppIcon` y debe entregarse como imagen cuadrada de 1024 × 1024 px sin transparencia.

## 7. Accesibilidad

- Área táctil mínima aproximada de 44 × 44 pt.
- Etiquetas y hints en acciones no evidentes.
- No usar solo color para comunicar el estado.
- Soportar textos largos y Dynamic Type.
- El DNI se anuncia como visible u oculto.
- Los indicadores de carga no bloquean indefinidamente una salida o reintento.

## 8. Patrones prohibidos

- Colores hexadecimales dispersos fuera de `DentiCoreTheme`.
- Tokens o contraseñas visibles.
- Navegación duplicada entre segue y `pushViewController` para el mismo flujo.
- Storyboard sin restricciones suficientes.
- Celdas que dependan de posiciones rígidas.
- Información clínica sensible dentro de notificaciones locales.
