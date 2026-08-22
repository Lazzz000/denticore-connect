INSERT INTO seguridad.rol (nombre, activo) VALUES
    ('ADMINISTRADOR', TRUE),
    ('ODONTOLOGO', TRUE),
    ('PACIENTE', TRUE)
ON CONFLICT (nombre) DO NOTHING;

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
