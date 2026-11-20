CREATE TABLE disponibilidad_comercio (
    comercio_id BIGINT NOT NULL REFERENCES comercio (id) ON DELETE CASCADE,
    ingrediente_id BIGINT NOT NULL REFERENCES ingrediente (id) ON DELETE RESTRICT,
    disponible BOOLEAN NOT NULL,
    precio NUMERIC(8, 2),
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (comercio_id, ingrediente_id),
    CONSTRAINT ck_disponibilidad_precio CHECK (
        precio IS NULL
        OR precio >= 0
    ),
    CONSTRAINT ck_disponibilidad_precio_si_disponible CHECK (
        NOT disponible
        OR precio IS NOT NULL
    )
);
CREATE INDEX ix_disponibilidad_ingrediente ON disponibilidad_comercio (ingrediente_id);
CREATE TABLE oferta (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    comercio_id BIGINT NOT NULL,
    ingrediente_id BIGINT NOT NULL,
    precio_ofertado NUMERIC(8, 2) NOT NULL,
    fecha_fin DATE NOT NULL,
    imagen_url VARCHAR(500),
    estado VARCHAR(10) NOT NULL DEFAULT 'VIGENTE',
    CONSTRAINT ck_oferta_precio CHECK (precio_ofertado > 0),
    CONSTRAINT ck_oferta_estado CHECK (estado IN ('VIGENTE', 'VENCIDA', 'RETIRADA')),
    CONSTRAINT fk_oferta_disponibilidad FOREIGN KEY (comercio_id, ingrediente_id) REFERENCES disponibilidad_comercio (comercio_id, ingrediente_id) ON DELETE CASCADE
);
CREATE INDEX ix_oferta_disponibilidad ON oferta (comercio_id, ingrediente_id);
CREATE INDEX ix_oferta_estado_fecha_fin ON oferta (estado, fecha_fin);
CREATE TABLE valoracion (
    cliente_id BIGINT NOT NULL REFERENCES cliente (id) ON DELETE CASCADE,
    receta_id BIGINT NOT NULL REFERENCES receta (id) ON DELETE CASCADE,
    puntuacion SMALLINT NOT NULL,
    fecha TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (cliente_id, receta_id),
    CONSTRAINT ck_valoracion_puntuacion CHECK (
        puntuacion BETWEEN 1 AND 5
    )
);
CREATE INDEX ix_valoracion_receta ON valoracion (receta_id);