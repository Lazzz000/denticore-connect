-- =================================================================================
-- 1. CREACIÓN DE ESQUEMAS
-- =================================================================================
CREATE SCHEMA IF NOT EXISTS catalogo;
CREATE SCHEMA IF NOT EXISTS clinica;
CREATE SCHEMA IF NOT EXISTS crm;
CREATE SCHEMA IF NOT EXISTS seguridad;
CREATE SCHEMA IF NOT EXISTS ventas;

-- =================================================================================
-- 2. CREACIÓN DE TABLAS (ORDENADAS POR DEPENDENCIA)
-- =================================================================================

-- ESQUEMA: seguridad
CREATE TABLE seguridad.rol (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE seguridad.usuario (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    dni VARCHAR(15) NOT NULL UNIQUE,
    tipo_documento_sunat CHAR(1) NOT NULL DEFAULT '1',
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    direccion_fiscal VARCHAR(250),
    correo VARCHAR(100),
    password_hash VARCHAR(255),
    google_subject_id VARCHAR(255),
    ruta_foto_perfil VARCHAR(500),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE seguridad.usuario_rol (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_usuario_rol_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id),
    CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol) REFERENCES seguridad.rol (id)
);

CREATE TABLE seguridad.odontologo (
    id_usuario INT NOT NULL PRIMARY KEY,
    cop VARCHAR(20) NOT NULL UNIQUE,
    firma_digital VARCHAR(500),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_odontologo_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id)
);

CREATE TABLE seguridad.paciente (
    id_usuario INT NOT NULL PRIMARY KEY,
    grupo_sanguineo VARCHAR(5),
    alergias TEXT,
    fecha_nacimiento DATE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_paciente_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id)
);

-- ESQUEMA: catalogo
CREATE TABLE catalogo.especialidad (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE catalogo.item_catalogo (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Producto', 'Servicio')),
    costo_referencial DECIMAL(10, 2) NOT NULL CHECK (costo_referencial >= 0),
    tipo_afectacion_id CHAR(2) NOT NULL DEFAULT '10',
    duracion_minutos INT NOT NULL DEFAULT 0 CHECK (duracion_minutos >= 0),
    id_especialidad INT,
    mostrar_en_web BOOLEAN NOT NULL DEFAULT TRUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_item_catalogo_especialidad FOREIGN KEY (id_especialidad) REFERENCES catalogo.especialidad (id)
);

CREATE TABLE catalogo.odontologo_especialidad (
    id_odontologo INT NOT NULL,
    id_especialidad INT NOT NULL,
    PRIMARY KEY (id_odontologo, id_especialidad),
    CONSTRAINT fk_odonto_espec_odontologo FOREIGN KEY (id_odontologo) REFERENCES seguridad.odontologo (id_usuario),
    CONSTRAINT fk_odonto_espec_especialidad FOREIGN KEY (id_especialidad) REFERENCES catalogo.especialidad (id)
);

-- ESQUEMA: crm
CREATE TABLE crm.lead_contacto (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    celular VARCHAR(20) NOT NULL,
    mensaje TEXT NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE crm.cita (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_odontologo INT NOT NULL,
    id_lead_contacto INT,
    fecha_hora TIMESTAMP NOT NULL,
    --CHECK ANTIGUO HEREDADO DE LA VERSION 1.0(C#-ASP.NET)
    --estado VARCHAR(20) NOT NULL CHECK (estado IN ('Cancelada', 'Atendida', 'EnSala', 'Confirmada', 'Pendiente')),
    --CHECK NUEVO VALIDADO CON LOGICA DE NEGOCIO DEPURADA
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('PENDIENTE', 'CONFIRMADA', 'EN_SALA', 'EN_CURSO', 'ATENDIDA', 'FINALIZADA', 'CANCELADA')),
    canal_origen VARCHAR(50) NOT NULL,
    monto_adelanto DECIMAL(10, 2) NOT NULL DEFAULT 0,
    referencia_adelanto VARCHAR(100),
    CONSTRAINT fk_cita_paciente FOREIGN KEY (id_paciente) REFERENCES seguridad.paciente (id_usuario),
    CONSTRAINT fk_cita_odontologo FOREIGN KEY (id_odontologo) REFERENCES seguridad.odontologo (id_usuario),
    CONSTRAINT fk_cita_lead_contacto FOREIGN KEY (id_lead_contacto) REFERENCES crm.lead_contacto (id)
);
CREATE INDEX ix_cita_fecha ON crm.cita (fecha_hora);

-- ESQUEMA: clinica
CREATE TABLE clinica.elemento_odontograma (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL CHECK (categoria IN ('Tratamiento', 'Diagnostico')),
    aplica_a VARCHAR(50) NOT NULL CHECK (aplica_a IN ('Diente', 'Cara')),
    color_hex VARCHAR(10) NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE clinica.historia_clinica (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_paciente INT NOT NULL UNIQUE,
    codigo_historial VARCHAR(50) NOT NULL UNIQUE,
    creado_por INT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificado_por INT,
    fecha_modificacion TIMESTAMP,
    CONSTRAINT fk_historia_paciente FOREIGN KEY (id_paciente) REFERENCES seguridad.paciente (id_usuario),
    CONSTRAINT fk_historia_creador FOREIGN KEY (creado_por) REFERENCES seguridad.usuario (id)
);

CREATE TABLE clinica.atencion_clinica (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_historia_clinica INT NOT NULL,
    id_cita INT UNIQUE,
    fecha_atencion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo_consulta TEXT NOT NULL,
    notas_clinicas TEXT,
    creado_por INT NOT NULL,
    fecha_modificacion TIMESTAMP,
    CONSTRAINT fk_atencion_historia FOREIGN KEY (id_historia_clinica) REFERENCES clinica.historia_clinica (id),
    CONSTRAINT fk_atencion_cita FOREIGN KEY (id_cita) REFERENCES crm.cita (id),
    CONSTRAINT fk_atencion_creador FOREIGN KEY (creado_por) REFERENCES seguridad.usuario (id)
);
CREATE INDEX ix_atencion_historia ON clinica.atencion_clinica (id_historia_clinica);

CREATE TABLE clinica.odontograma (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_atencion_clinica INT NOT NULL UNIQUE,
    tipo VARCHAR(50) NOT NULL,
    creado_por INT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP,
    CONSTRAINT fk_odontograma_atencion FOREIGN KEY (id_atencion_clinica) REFERENCES clinica.atencion_clinica (id),
    CONSTRAINT fk_odontograma_creador FOREIGN KEY (creado_por) REFERENCES seguridad.usuario (id)
);

CREATE TABLE clinica.detalle_odontograma (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_odontograma INT NOT NULL,
    id_elemento_clinico INT NOT NULL,
    numero_pieza INT NOT NULL,
    diagnostico VARCHAR(255) NOT NULL,
    estado_tratamiento VARCHAR(50) NOT NULL,
    CONSTRAINT fk_detalle_odonto_odonto FOREIGN KEY (id_odontograma) REFERENCES clinica.odontograma (id),
    CONSTRAINT fk_detalle_odonto_item FOREIGN KEY (id_elemento_clinico) REFERENCES clinica.elemento_odontograma (id)
);

-- ESQUEMA: ventas
CREATE TABLE ventas.transaccion_comercial (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_cita INT,
    tipo_documento VARCHAR(20) NOT NULL CHECK (tipo_documento IN ('ReciboInterno', 'Factura', 'Boleta', 'Cotizacion')),
    serie CHAR(4) NOT NULL DEFAULT 'F001',
    correlativo INT NOT NULL,
    fecha_emision TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sub_total DECIMAL(10, 2) NOT NULL,
    igv DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    monto_pagado DECIMAL(10, 2) NOT NULL DEFAULT 0,
    saldo_pendiente DECIMAL(10,2) GENERATED ALWAYS AS (total - monto_pagado) STORED,
    metodo_pago VARCHAR(50) NOT NULL DEFAULT 'Efectivo',
    external_payment_id VARCHAR(100),
    estado_pago VARCHAR(20),
    estado_sunat VARCHAR(50) NOT NULL DEFAULT 'PENDIENTE',
    codigo_hash VARCHAR(100),
    creado_por INT NOT NULL,
    fecha_modificacion TIMESTAMP,
    CONSTRAINT chk_transaccion_valores CHECK (sub_total >= 0 AND igv >= 0 AND monto_pagado >= 0),
    CONSTRAINT fk_transaccion_paciente FOREIGN KEY (id_paciente) REFERENCES seguridad.paciente (id_usuario),
    CONSTRAINT fk_transaccion_cita FOREIGN KEY (id_cita) REFERENCES crm.cita (id),
    CONSTRAINT fk_transaccion_creador FOREIGN KEY (creado_por) REFERENCES seguridad.usuario (id)
);
CREATE INDEX ix_ventas_fecha ON ventas.transaccion_comercial (fecha_emision);
CREATE INDEX ix_ventas_paciente ON ventas.transaccion_comercial (id_paciente);

CREATE TABLE ventas.detalle_transaccion (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_transaccion INT NOT NULL,
    id_item_catalogo INT NOT NULL,
    cantidad INT NOT NULL,
    precio_aplicado DECIMAL(10, 2) NOT NULL,
    numero_pieza INT,
    CONSTRAINT fk_detalle_transaccion_transaccion FOREIGN KEY (id_transaccion) REFERENCES ventas.transaccion_comercial (id),
    CONSTRAINT fk_detalle_transaccion_item FOREIGN KEY (id_item_catalogo) REFERENCES catalogo.item_catalogo (id)
);
