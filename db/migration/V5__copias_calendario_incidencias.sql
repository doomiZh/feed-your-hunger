CREATE TABLE copia_personal_receta (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id BIGINT NOT NULL REFERENCES cliente (id) ON DELETE CASCADE,
    receta_origen_id BIGINT REFERENCES receta (id) ON DELETE
    SET NULL,
        nombre VARCHAR(150) NOT NULL,
        procedimiento_personalizado TEXT NOT NULL,
        raciones SMALLINT,
        fecha_guardado TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT ck_copia_raciones CHECK (
            raciones IS NULL
            OR raciones > 0
        ),
        CONSTRAINT uq_copia_cliente_receta UNIQUE (cliente_id, receta_origen_id)
);
CREATE INDEX ix_copia_receta_origen ON copia_personal_receta (receta_origen_id);
CREATE TABLE copia_ingrediente (
    copia_id BIGINT NOT NULL REFERENCES copia_personal_receta (id) ON DELETE CASCADE,
    ingrediente_id BIGINT NOT NULL REFERENCES ingrediente (id) ON DELETE RESTRICT,
    cantidad NUMERIC(8, 2),
    unidad VARCHAR(15) NOT NULL,
    PRIMARY KEY (copia_id, ingrediente_id),
    CONSTRAINT ck_copia_ingrediente_unidad CHECK (
        unidad IN (
            'GRAMO',
            'KILOGRAMO',
            'MILILITRO',
            'LITRO',
            'UNIDAD',
            'CUCHARADA',
            'CUCHARADITA',
            'TAZA',
            'PIZCA',
            'AL_GUSTO'
        )
    ),
    CONSTRAINT ck_copia_ingrediente_cantidad_positiva CHECK (
        cantidad IS NULL
        OR cantidad > 0
    ),
    CONSTRAINT ck_copia_ingrediente_cantidad_nula CHECK (
        cantidad IS NOT NULL
        OR unidad = 'AL_GUSTO'
    )
);
CREATE INDEX ix_copia_ingrediente_ingrediente ON copia_ingrediente (ingrediente_id);
CREATE TABLE entrada_calendario (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    copia_id BIGINT NOT NULL REFERENCES copia_personal_receta (id) ON DELETE CASCADE,
    fecha DATE NOT NULL,
    aviso_estado VARCHAR(10) NOT NULL DEFAULT 'PENDIENTE',
    fecha_aviso TIMESTAMPTZ,
    CONSTRAINT ck_entrada_aviso_estado CHECK (
        aviso_estado IN ('PENDIENTE', 'ENVIADO', 'FALLIDO')
    ),
    CONSTRAINT uq_entrada_copia_fecha UNIQUE (copia_id, fecha)
);
CREATE INDEX ix_entrada_pendientes ON entrada_calendario (fecha)
WHERE aviso_estado = 'PENDIENTE';
CREATE TABLE incidencia (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    comercio_id BIGINT NOT NULL REFERENCES comercio (id) ON DELETE CASCADE,
    administrador_id BIGINT REFERENCES administrador (id) ON DELETE
    SET NULL,
        asunto VARCHAR(150),
        estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
        fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT ck_incidencia_estado CHECK (
            estado IN ('PENDIENTE', 'ESPERANDO_COMERCIO', 'RESUELTA')
        )
);
CREATE INDEX ix_incidencia_comercio ON incidencia (comercio_id);
CREATE INDEX ix_incidencia_pendientes ON incidencia (estado)
WHERE estado = 'PENDIENTE';
CREATE TABLE mensaje_incidencia (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    incidencia_id BIGINT NOT NULL REFERENCES incidencia (id) ON DELETE CASCADE,
    autor VARCHAR(15) NOT NULL,
    autor_usuario_id BIGINT REFERENCES usuario (id) ON DELETE
    SET NULL,
        cuerpo TEXT NOT NULL,
        fecha_envio TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT ck_mensaje_autor CHECK (autor IN ('COMERCIO', 'ADMINISTRADOR'))
);
CREATE INDEX ix_mensaje_incidencia ON mensaje_incidencia (incidencia_id);
CREATE TABLE suscripcion_push (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id BIGINT NOT NULL REFERENCES cliente (id) ON DELETE CASCADE,
    endpoint VARCHAR(500) NOT NULL,
    clave_p256dh VARCHAR(255) NOT NULL,
    clave_auth VARCHAR(255) NOT NULL,
    fecha_alta TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_suscripcion_endpoint UNIQUE (endpoint)
);
CREATE INDEX ix_suscripcion_cliente ON suscripcion_push (cliente_id);
CREATE TABLE token_recuperacion (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES usuario (id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT now(),
    fecha_expiracion TIMESTAMPTZ NOT NULL,
    fecha_uso TIMESTAMPTZ,
    CONSTRAINT uq_token_hash UNIQUE (token_hash),
    CONSTRAINT ck_token_expiracion CHECK (fecha_expiracion > fecha_creacion)
);
CREATE INDEX ix_token_usuario ON token_recuperacion (usuario_id);