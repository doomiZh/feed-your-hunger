ALTER TABLE usuario
    ADD COLUMN intentos_fallidos SMALLINT NOT NULL DEFAULT 0,
    ADD COLUMN tiempo_bloqueo TIMESTAMPTZ,
    ADD CONSTRAINT ck_usuario_intentos_fallidos CHECK (intentos_fallidos >= 0);
