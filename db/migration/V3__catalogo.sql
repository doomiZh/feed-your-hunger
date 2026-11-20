CREATE TABLE categoria (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    permite_varias_opciones BOOLEAN NOT NULL,
    es_obligatoria BOOLEAN NOT NULL,
    combinacion_filtro VARCHAR(10) NOT NULL,
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre),
    CONSTRAINT ck_categoria_combinacion CHECK (combinacion_filtro IN ('ALGUNA', 'TODAS'))
);
CREATE TABLE opcion_categoria (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    categoria_id BIGINT NOT NULL REFERENCES categoria (id) ON DELETE CASCADE,
    nombre VARCHAR(80) NOT NULL,
    CONSTRAINT uq_opcion_categoria_nombre UNIQUE (categoria_id, nombre)
);
CREATE TABLE ingrediente (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    unidad_venta_referencia VARCHAR(15) NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'ACTIVO',
    precio_promedio NUMERIC(8, 2),
    fecha_calculo_precio TIMESTAMPTZ,
    CONSTRAINT uq_ingrediente_nombre UNIQUE (nombre),
    CONSTRAINT ck_ingrediente_unidad_venta CHECK (
        unidad_venta_referencia IN (
            'KILOGRAMO',
            'GRAMO',
            'LITRO',
            'MILILITRO',
            'DOCENA',
            'UNIDAD',
            'MANOJO',
            'PAQUETE'
        )
    ),
    CONSTRAINT ck_ingrediente_estado CHECK (estado IN ('ACTIVO', 'DESCONTINUADO')),
    CONSTRAINT ck_ingrediente_precio_promedio CHECK (
        precio_promedio IS NULL
        OR precio_promedio >= 0
    )
);
CREATE TABLE receta (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion_corta VARCHAR(300),
    imagen_url VARCHAR(500),
    raciones SMALLINT,
    tiempo_preparacion_min SMALLINT,
    procedimiento TEXT NOT NULL,
    origen_pais CHAR(2) NOT NULL REFERENCES pais (codigo) ON DELETE RESTRICT,
    origen_municipio_id BIGINT,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT now(),
    valoracion_promedio NUMERIC(3, 2),
    numero_valoraciones INTEGER NOT NULL DEFAULT 0,
    tendencia NUMERIC(10, 4),
    fecha_calculo_tendencia TIMESTAMPTZ,
    costo_estimado NUMERIC(10, 2),
    CONSTRAINT ck_receta_raciones CHECK (
        raciones IS NULL
        OR raciones > 0
    ),
    CONSTRAINT ck_receta_tiempo CHECK (
        tiempo_preparacion_min IS NULL
        OR tiempo_preparacion_min > 0
    ),
    CONSTRAINT ck_receta_valoracion_promedio CHECK (
        valoracion_promedio IS NULL
        OR valoracion_promedio BETWEEN 1 AND 5
    ),
    CONSTRAINT ck_receta_numero_valoraciones CHECK (numero_valoraciones >= 0),
    CONSTRAINT ck_receta_costo CHECK (
        costo_estimado IS NULL
        OR costo_estimado >= 0
    ),
    CONSTRAINT fk_receta_origen_municipio FOREIGN KEY (origen_municipio_id, origen_pais) REFERENCES municipio (id, pais_codigo) ON DELETE RESTRICT
);
CREATE TABLE receta_ingrediente (
    receta_id BIGINT NOT NULL REFERENCES receta (id) ON DELETE CASCADE,
    ingrediente_id BIGINT NOT NULL REFERENCES ingrediente (id) ON DELETE RESTRICT,
    cantidad NUMERIC(8, 2),
    unidad VARCHAR(15) NOT NULL,
    PRIMARY KEY (receta_id, ingrediente_id),
    CONSTRAINT ck_receta_ingrediente_unidad CHECK (
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
    CONSTRAINT ck_receta_ingrediente_cantidad_positiva CHECK (
        cantidad IS NULL
        OR cantidad > 0
    ),
    CONSTRAINT ck_receta_ingrediente_cantidad_nula CHECK (
        cantidad IS NOT NULL
        OR unidad = 'AL_GUSTO'
    )
);
CREATE TABLE receta_opcion (
    receta_id BIGINT NOT NULL REFERENCES receta (id) ON DELETE CASCADE,
    opcion_id BIGINT NOT NULL REFERENCES opcion_categoria (id) ON DELETE CASCADE,
    PRIMARY KEY (receta_id, opcion_id)
);
CREATE INDEX ix_receta_opcion_opcion ON receta_opcion (opcion_id);
CREATE INDEX ix_receta_valoracion_promedio ON receta (valoracion_promedio);
CREATE INDEX ix_receta_tendencia ON receta (tendencia);
CREATE INDEX ix_receta_costo_estimado ON receta (costo_estimado);
CREATE INDEX ix_receta_tiempo_preparacion ON receta (tiempo_preparacion_min);
CREATE INDEX ix_receta_origen_pais ON receta (origen_pais);
CREATE INDEX ix_receta_ingrediente_ingrediente ON receta_ingrediente (ingrediente_id);