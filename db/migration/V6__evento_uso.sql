CREATE TABLE evento_uso (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo VARCHAR(40) NOT NULL,
    instante TIMESTAMPTZ NOT NULL DEFAULT now(),
    token_sesion UUID,
    cliente_id BIGINT REFERENCES cliente (id) ON DELETE CASCADE,
    receta_id BIGINT REFERENCES receta (id) ON DELETE
    SET NULL,
        oferta_id BIGINT REFERENCES oferta (id) ON DELETE
    SET NULL,
        entrada_calendario_id BIGINT REFERENCES entrada_calendario (id) ON DELETE
    SET NULL,
        resultado BOOLEAN,
        CONSTRAINT ck_evento_tipo CHECK (
            tipo IN (
                'BUSQUEDA_INICIADA',
                'RECETA_SELECCIONADA',
                'CHAT_IA_CONSULTADO',
                'MAPA_CONSULTADO',
                'OFERTA_PULSADA',
                'BIBLIOTECA_ABIERTA',
                'RECETA_CALENDARIZADA_ABIERTA'
            )
        ),
        CONSTRAINT ck_evento_token_o_cliente CHECK (
            token_sesion IS NOT NULL
            OR cliente_id IS NOT NULL
        ),
        CONSTRAINT ck_evento_resultado CHECK (
            resultado IS NULL
            OR tipo = 'MAPA_CONSULTADO'
        )
);
CREATE INDEX ix_evento_sesion ON evento_uso (token_sesion, instante);
CREATE INDEX ix_evento_receta_seleccionada ON evento_uso (receta_id, instante)
WHERE tipo = 'RECETA_SELECCIONADA';