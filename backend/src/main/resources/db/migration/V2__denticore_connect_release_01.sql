CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE SCHEMA IF NOT EXISTS organizacion;
CREATE SCHEMA IF NOT EXISTS agenda;

CREATE TABLE organizacion.clinica (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre_comercial VARCHAR(150) NOT NULL,
    razon_social VARCHAR(200),
    ruc VARCHAR(11) UNIQUE,
    zona_horaria VARCHAR(60) NOT NULL DEFAULT 'America/Lima',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE organizacion.sede (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_clinica INT NOT NULL,
    codigo VARCHAR(30) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    direccion VARCHAR(250),
    telefono VARCHAR(30),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sede_clinica FOREIGN KEY (id_clinica)
        REFERENCES organizacion.clinica (id),
    CONSTRAINT ux_sede_clinica_codigo UNIQUE (id_clinica, codigo)
);

CREATE TABLE seguridad.usuario_clinica (
    id_usuario INT NOT NULL,
    id_clinica INT NOT NULL,
    id_rol INT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_clinica, id_rol),
    CONSTRAINT fk_usuario_clinica_usuario FOREIGN KEY (id_usuario)
        REFERENCES seguridad.usuario (id),
    CONSTRAINT fk_usuario_clinica_clinica FOREIGN KEY (id_clinica)
        REFERENCES organizacion.clinica (id),
    CONSTRAINT fk_usuario_clinica_rol FOREIGN KEY (id_rol)
        REFERENCES seguridad.rol (id)
);

CREATE TABLE agenda.horario_odontologo (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_odontologo INT NOT NULL,
    id_sede INT NOT NULL,
    dia_semana SMALLINT NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    vigencia_desde DATE NOT NULL,
    vigencia_hasta DATE,
    intervalo_minutos SMALLINT NOT NULL DEFAULT 30
        CHECK (intervalo_minutos BETWEEN 5 AND 240),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_horario_rango CHECK (hora_inicio < hora_fin),
    CONSTRAINT chk_horario_vigencia CHECK (
        vigencia_hasta IS NULL OR vigencia_hasta >= vigencia_desde
    ),
    CONSTRAINT fk_horario_odontologo FOREIGN KEY (id_odontologo)
        REFERENCES seguridad.odontologo (id_usuario),
    CONSTRAINT fk_horario_sede FOREIGN KEY (id_sede)
        REFERENCES organizacion.sede (id)
);

CREATE TABLE agenda.bloqueo_horario (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_odontologo INT NOT NULL,
    id_sede INT NOT NULL,
    fecha_hora_inicio TIMESTAMPTZ NOT NULL,
    fecha_hora_fin TIMESTAMPTZ NOT NULL,
    motivo VARCHAR(200),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_por INT,
    CONSTRAINT chk_bloqueo_rango CHECK (fecha_hora_inicio < fecha_hora_fin),
    CONSTRAINT fk_bloqueo_odontologo FOREIGN KEY (id_odontologo)
        REFERENCES seguridad.odontologo (id_usuario),
    CONSTRAINT fk_bloqueo_sede FOREIGN KEY (id_sede)
        REFERENCES organizacion.sede (id),
    CONSTRAINT fk_bloqueo_creador FOREIGN KEY (creado_por)
        REFERENCES seguridad.usuario (id)
);

INSERT INTO organizacion.clinica (codigo, nombre_comercial, zona_horaria)
VALUES ('PILOTO-001', 'Clínica dental piloto', 'America/Lima')
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO organizacion.sede (id_clinica, codigo, nombre, direccion, activo)
SELECT id, 'SEDE-PRINCIPAL', 'Sede principal', 'Dirección de demostración, Lima', TRUE
FROM organizacion.clinica
WHERE codigo = 'PILOTO-001'
ON CONFLICT (id_clinica, codigo) DO NOTHING;

INSERT INTO catalogo.item_catalogo (
    codigo, nombre, tipo, costo_referencial, duracion_minutos, mostrar_en_web, activo
)
VALUES ('CONSULTA-GENERAL', 'Consulta odontológica general', 'Servicio', 0, 30, TRUE, TRUE)
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO seguridad.usuario_clinica (id_usuario, id_clinica, id_rol, activo)
SELECT ur.id_usuario, c.id, ur.id_rol, ur.activo
FROM seguridad.usuario_rol ur
CROSS JOIN organizacion.clinica c
WHERE c.codigo = 'PILOTO-001'
ON CONFLICT (id_usuario, id_clinica, id_rol) DO NOTHING;

ALTER TABLE crm.cita
    DROP CONSTRAINT IF EXISTS cita_estado_check;

UPDATE crm.cita SET estado = 'ATENDIDA' WHERE estado = 'FINALIZADA';
UPDATE crm.cita SET estado = 'CANCELADA_CLINICA' WHERE estado = 'CANCELADA';

ALTER TABLE crm.cita
    ADD CONSTRAINT cita_estado_check CHECK (
        estado IN (
            'PENDIENTE', 'CONFIRMADA', 'EN_SALA', 'EN_CURSO', 'ATENDIDA',
            'CANCELADA_PACIENTE', 'CANCELADA_CLINICA', 'NO_ASISTIO'
        )
    );

ALTER TABLE crm.cita
    ALTER COLUMN fecha_hora TYPE TIMESTAMPTZ
    USING fecha_hora AT TIME ZONE 'America/Lima';

ALTER TABLE crm.cita
    ADD COLUMN id_clinica INT,
    ADD COLUMN id_sede INT,
    ADD COLUMN id_servicio INT,
    ADD COLUMN fecha_hora_fin TIMESTAMPTZ,
    ADD COLUMN nota_paciente VARCHAR(300),
    ADD COLUMN motivo_cancelacion VARCHAR(300),
    ADD COLUMN cancelada_por INT,
    ADD COLUMN fecha_cancelacion TIMESTAMPTZ,
    ADD COLUMN creado_por INT,
    ADD COLUMN fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN fecha_modificacion TIMESTAMPTZ,
    ADD COLUMN version BIGINT NOT NULL DEFAULT 0;

UPDATE crm.cita c
SET id_clinica = cli.id,
    id_sede = s.id,
    id_servicio = srv.id,
    fecha_hora_fin = c.fecha_hora + INTERVAL '30 minutes',
    creado_por = c.id_paciente
FROM organizacion.clinica cli
JOIN organizacion.sede s ON s.id_clinica = cli.id AND s.codigo = 'SEDE-PRINCIPAL'
CROSS JOIN catalogo.item_catalogo srv
WHERE cli.codigo = 'PILOTO-001'
  AND srv.codigo = 'CONSULTA-GENERAL';

ALTER TABLE crm.cita
    ALTER COLUMN id_clinica SET NOT NULL,
    ALTER COLUMN id_sede SET NOT NULL,
    ALTER COLUMN id_servicio SET NOT NULL,
    ALTER COLUMN fecha_hora_fin SET NOT NULL,
    ALTER COLUMN creado_por SET NOT NULL,
    ADD CONSTRAINT fk_cita_clinica FOREIGN KEY (id_clinica)
        REFERENCES organizacion.clinica (id),
    ADD CONSTRAINT fk_cita_sede FOREIGN KEY (id_sede)
        REFERENCES organizacion.sede (id),
    ADD CONSTRAINT fk_cita_servicio FOREIGN KEY (id_servicio)
        REFERENCES catalogo.item_catalogo (id),
    ADD CONSTRAINT fk_cita_cancelada_por FOREIGN KEY (cancelada_por)
        REFERENCES seguridad.usuario (id),
    ADD CONSTRAINT fk_cita_creado_por FOREIGN KEY (creado_por)
        REFERENCES seguridad.usuario (id),
    ADD CONSTRAINT chk_cita_rango CHECK (fecha_hora < fecha_hora_fin);

CREATE TABLE crm.cita_evento (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cita INT NOT NULL,
    tipo_evento VARCHAR(30) NOT NULL
        CHECK (tipo_evento IN ('CREADA', 'REPROGRAMADA', 'CANCELADA')),
    inicio_anterior TIMESTAMPTZ,
    fin_anterior TIMESTAMPTZ,
    inicio_nuevo TIMESTAMPTZ,
    fin_nuevo TIMESTAMPTZ,
    motivo VARCHAR(300),
    id_usuario_actor INT NOT NULL,
    fecha_evento TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cita_evento_cita FOREIGN KEY (id_cita)
        REFERENCES crm.cita (id),
    CONSTRAINT fk_cita_evento_actor FOREIGN KEY (id_usuario_actor)
        REFERENCES seguridad.usuario (id)
);

CREATE INDEX ix_usuario_clinica_activo
    ON seguridad.usuario_clinica (id_usuario, id_clinica, activo);
CREATE INDEX ix_horario_busqueda
    ON agenda.horario_odontologo (id_odontologo, id_sede, dia_semana, activo);
CREATE INDEX ix_bloqueo_rango
    ON agenda.bloqueo_horario (id_odontologo, id_sede, fecha_hora_inicio, fecha_hora_fin);
CREATE INDEX ix_cita_paciente_clinica
    ON crm.cita (id_paciente, id_clinica, fecha_hora);
CREATE INDEX ix_cita_sede_fecha
    ON crm.cita (id_sede, fecha_hora);
CREATE INDEX ix_cita_evento_fecha
    ON crm.cita_evento (id_cita, fecha_evento);

ALTER TABLE crm.cita
    ADD CONSTRAINT ex_cita_odontologo_no_solapada
    EXCLUDE USING gist (
        id_odontologo WITH =,
        tstzrange(fecha_hora, fecha_hora_fin, '[)') WITH &&
    )
    WHERE (estado IN ('PENDIENTE', 'CONFIRMADA', 'EN_SALA', 'EN_CURSO'));
