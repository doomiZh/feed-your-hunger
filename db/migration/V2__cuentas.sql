CREATE TABLE usuario (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    correo VARCHAR(254) NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT now(),
    rol VARCHAR(15) NOT NULL,
    CONSTRAINT uq_usuario_correo UNIQUE (correo),
    CONSTRAINT ck_usuario_correo_minusculas CHECK (correo = lower(correo)),
    CONSTRAINT ck_usuario_rol CHECK (rol IN ('CLIENTE', 'COMERCIO', 'ADMINISTRADOR')),
    CONSTRAINT uq_usuario_id_rol UNIQUE (id, rol)
);
CREATE TABLE cliente (
    id BIGINT PRIMARY KEY,
    rol VARCHAR(15) NOT NULL DEFAULT 'CLIENTE',
    nombre VARCHAR(100) NOT NULL,
    nacionalidad_pais CHAR(2) REFERENCES pais (codigo) ON DELETE RESTRICT,
    residencia_pais CHAR(2) REFERENCES pais (codigo) ON DELETE RESTRICT,
    residencia_municipio_id BIGINT,
    fecha_consentimiento TIMESTAMPTZ NOT NULL,
    CONSTRAINT ck_cliente_rol CHECK (rol = 'CLIENTE'),
    CONSTRAINT fk_cliente_usuario FOREIGN KEY (id, rol) REFERENCES usuario (id, rol) ON DELETE CASCADE,
    CONSTRAINT fk_cliente_residencia_municipio FOREIGN KEY (residencia_municipio_id, residencia_pais) REFERENCES municipio (id, pais_codigo) ON DELETE RESTRICT,
    CONSTRAINT ck_cliente_municipio_con_pais CHECK (
        residencia_municipio_id IS NULL
        OR residencia_pais IS NOT NULL
    )
);
CREATE TABLE comercio (
    id BIGINT PRIMARY KEY,
    rol VARCHAR(15) NOT NULL DEFAULT 'COMERCIO',
    nombre_comercio VARCHAR(150) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    ubicacion GEOGRAPHY(POINT, 4326) NOT NULL,
    estado VARCHAR(12) NOT NULL DEFAULT 'ACTIVO',
    logo_url VARCHAR(500),
    fecha_ultima_actualizacion TIMESTAMPTZ,
    CONSTRAINT ck_comercio_rol CHECK (rol = 'COMERCIO'),
    CONSTRAINT ck_comercio_estado CHECK (estado IN ('ACTIVO', 'SUSPENDIDO', 'BAJA')),
    CONSTRAINT fk_comercio_usuario FOREIGN KEY (id, rol) REFERENCES usuario (id, rol) ON DELETE CASCADE
);
CREATE INDEX ix_comercio_ubicacion ON comercio USING GIST (ubicacion);
CREATE TABLE administrador (
    id BIGINT PRIMARY KEY,
    rol VARCHAR(15) NOT NULL DEFAULT 'ADMINISTRADOR',
    CONSTRAINT ck_administrador_rol CHECK (rol = 'ADMINISTRADOR'),
    CONSTRAINT fk_administrador_usuario FOREIGN KEY (id, rol) REFERENCES usuario (id, rol) ON DELETE CASCADE
);