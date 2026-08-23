INSERT INTO seguridad.rol (nombre, activo) VALUES
    ('ADMINISTRADOR', TRUE),
    ('ODONTOLOGO', TRUE),
    ('PACIENTE', TRUE)
ON CONFLICT (nombre) DO NOTHING;

-- Identidad comercial visible en el cliente móvil. Al ser una migración
-- repetible, también actualiza bases demo creadas en despliegues anteriores.
UPDATE organizacion.clinica
SET nombre_comercial = 'Clínica Dental Dr. Dave Cáceres'
WHERE codigo = 'PILOTO-001';

UPDATE organizacion.sede s
SET nombre = 'Sede San Juan de Lurigancho',
    direccion = 'San Juan de Lurigancho, Lima'
FROM organizacion.clinica c
WHERE s.id_clinica = c.id
  AND c.codigo = 'PILOTO-001'
  AND s.codigo = 'SEDE-PRINCIPAL';

INSERT INTO organizacion.sede (id_clinica, codigo, nombre, direccion, telefono, activo)
SELECT id, 'SEDE-NORTE', 'Sede Norte', 'Av. Los Jardines 245, Lima', '(01) 555-0102', TRUE
FROM organizacion.clinica
WHERE codigo = 'PILOTO-001'
ON CONFLICT (id_clinica, codigo) DO NOTHING;

INSERT INTO catalogo.especialidad (nombre, activo)
SELECT nombre, TRUE
FROM (VALUES
    ('Odontología general'),
    ('Ortodoncia'),
    ('Endodoncia'),
    ('Odontopediatría'),
    ('Periodoncia'),
    ('Rehabilitación oral')
) AS demo(nombre)
WHERE NOT EXISTS (
    SELECT 1 FROM catalogo.especialidad e WHERE lower(e.nombre) = lower(demo.nombre)
);

INSERT INTO catalogo.item_catalogo (
    codigo, nombre, tipo, costo_referencial, duracion_minutos,
    id_especialidad, mostrar_en_web, activo
)
SELECT demo.codigo, demo.nombre, 'Servicio', demo.costo, demo.duracion,
       e.id, TRUE, TRUE
FROM (VALUES
    ('GEN-EVAL', 'Evaluación odontológica integral', 80.00, 30, 'Odontología general'),
    ('GEN-LIMP', 'Profilaxis y limpieza dental', 120.00, 45, 'Odontología general'),
    ('ORT-EVAL', 'Evaluación de ortodoncia', 100.00, 30, 'Ortodoncia'),
    ('ORT-CONTROL', 'Control de ortodoncia', 90.00, 30, 'Ortodoncia'),
    ('END-EVAL', 'Evaluación endodóntica', 110.00, 30, 'Endodoncia'),
    ('END-TRAT', 'Tratamiento de conducto', 480.00, 90, 'Endodoncia'),
    ('PED-CONTROL', 'Control odontopediátrico', 85.00, 30, 'Odontopediatría'),
    ('PED-SELL', 'Aplicación de sellantes', 150.00, 45, 'Odontopediatría'),
    ('PER-EVAL', 'Evaluación periodontal', 100.00, 30, 'Periodoncia'),
    ('PER-RASP', 'Raspado y alisado radicular', 260.00, 60, 'Periodoncia'),
    ('REH-EVAL', 'Evaluación de rehabilitación oral', 120.00, 45, 'Rehabilitación oral'),
    ('REH-CORONA', 'Preparación para corona dental', 650.00, 90, 'Rehabilitación oral')
) AS demo(codigo, nombre, costo, duracion, especialidad)
JOIN catalogo.especialidad e ON e.nombre = demo.especialidad
ON CONFLICT (codigo) DO NOTHING;

-- Profesionales y agenda ficticios para el flujo demostrativo de reserva móvil.
INSERT INTO seguridad.usuario (
    nombre_usuario, dni, tipo_documento_sunat, nombres, apellidos,
    correo, password_hash, activo
)
VALUES
    ('demo.ana.torres', '73000001', '1', 'Ana Lucía', 'Torres Quiroz',
     'ana.torres@demo.denticore.pe', NULL, TRUE),
    ('demo.luis.mendoza', '73000002', '1', 'Luis Alberto', 'Mendoza Ruiz',
     'luis.mendoza@demo.denticore.pe', NULL, TRUE),
    ('demo.carla.rios', '73000003', '1', 'Carla Fernanda', 'Ríos Salazar',
     'carla.rios@demo.denticore.pe', NULL, TRUE)
ON CONFLICT (dni) DO UPDATE SET
    nombres = EXCLUDED.nombres,
    apellidos = EXCLUDED.apellidos,
    correo = EXCLUDED.correo,
    activo = TRUE;

INSERT INTO seguridad.odontologo (id_usuario, cop, activo)
SELECT id, demo.cop, TRUE
FROM seguridad.usuario u
JOIN (VALUES
    ('73000001', 'COP-DEM-001'),
    ('73000002', 'COP-DEM-002'),
    ('73000003', 'COP-DEM-003')
) AS demo(dni, cop) ON demo.dni = u.dni
ON CONFLICT (id_usuario) DO UPDATE SET activo = TRUE;

INSERT INTO seguridad.usuario_rol (id_usuario, id_rol, activo)
SELECT u.id, r.id, TRUE
FROM seguridad.usuario u
CROSS JOIN seguridad.rol r
WHERE u.dni IN ('73000001', '73000002', '73000003')
  AND r.nombre = 'ODONTOLOGO'
ON CONFLICT (id_usuario, id_rol) DO UPDATE SET activo = TRUE;

INSERT INTO seguridad.usuario_clinica (
    id_usuario, id_clinica, id_rol, activo, fecha_creacion
)
SELECT u.id, c.id, r.id, TRUE, CURRENT_TIMESTAMP
FROM seguridad.usuario u
CROSS JOIN organizacion.clinica c
CROSS JOIN seguridad.rol r
WHERE u.dni IN ('73000001', '73000002', '73000003')
  AND c.codigo = 'PILOTO-001'
  AND r.nombre = 'ODONTOLOGO'
ON CONFLICT (id_usuario, id_clinica, id_rol) DO UPDATE SET activo = TRUE;

INSERT INTO catalogo.odontologo_especialidad (id_odontologo, id_especialidad)
SELECT u.id, e.id
FROM seguridad.usuario u
JOIN (VALUES
    ('73000001', 'Odontología general'),
    ('73000001', 'Ortodoncia'),
    ('73000001', 'Odontopediatría'),
    ('73000002', 'Odontología general'),
    ('73000002', 'Endodoncia'),
    ('73000002', 'Periodoncia'),
    ('73000003', 'Odontología general'),
    ('73000003', 'Ortodoncia'),
    ('73000003', 'Rehabilitación oral')
) AS demo(dni, especialidad) ON demo.dni = u.dni
JOIN catalogo.especialidad e ON e.nombre = demo.especialidad
ON CONFLICT (id_odontologo, id_especialidad) DO NOTHING;

INSERT INTO agenda.horario_odontologo (
    id_odontologo, id_sede, dia_semana, hora_inicio, hora_fin,
    vigencia_desde, vigencia_hasta, intervalo_minutos, activo
)
SELECT u.id, s.id, dias.dia, TIME '09:00', TIME '18:00',
       CURRENT_DATE, NULL, 30, TRUE
FROM seguridad.usuario u
CROSS JOIN organizacion.sede s
CROSS JOIN generate_series(1, 6) AS dias(dia)
CROSS JOIN organizacion.clinica c
WHERE u.dni IN ('73000001', '73000002', '73000003')
  AND c.codigo = 'PILOTO-001'
  AND c.id = s.id_clinica
  AND s.codigo = 'SEDE-PRINCIPAL'
  AND NOT EXISTS (
      SELECT 1
      FROM agenda.horario_odontologo h
      WHERE h.id_odontologo = u.id
        AND h.id_sede = s.id
        AND h.dia_semana = dias.dia
        AND h.hora_inicio = TIME '09:00'
        AND h.hora_fin = TIME '18:00'
  );
