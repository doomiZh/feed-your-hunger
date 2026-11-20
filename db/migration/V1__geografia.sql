CREATE EXTENSION IF NOT EXISTS postgis;
CREATE TABLE pais (
    codigo CHAR(2) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    continente VARCHAR(30) NOT NULL,
    CONSTRAINT ck_pais_continente CHECK (
        continente IN (
            'AFRICA',
            'AMERICA DEL NORTE',
            'AMERICA DEL SUR',
            'AMERICA CENTRAL',
            'ASIA',
            'EUROPA',
            'OCEANIA'
        )
    )
);
CREATE TABLE municipio (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pais_codigo CHAR(2) NOT NULL REFERENCES pais (codigo) ON DELETE RESTRICT,
    nombre VARCHAR(100) NOT NULL,
    ubicacion GEOGRAPHY(POINT, 4326) NOT NULL,
    CONSTRAINT uq_municipio_pais_nombre UNIQUE (pais_codigo, nombre),
    CONSTRAINT uq_municipio_id_pais UNIQUE (id, pais_codigo)
);
CREATE INDEX ix_municipio_ubicacion ON municipio USING GIST (ubicacion);